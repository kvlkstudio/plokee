import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'crypto.dart';
import 'models.dart';
import 'settings_store.dart';
import 'transfer.dart';

/// An authenticated WebSocket link to one paired device.
class PeerConnection {
  final String peerId;
  final WebSocket socket;

  /// What the peer said it understands in the handshake. An older build
  /// advertises nothing, which is how the one-frame fallback is chosen.
  final Set<String> caps;

  /// Serializes everything written to [socket].
  ///
  /// A streamed segment holds the sink while it runs (that is what gives it
  /// backpressure), and dart:io throws the moment anything else tries to write
  /// meanwhile. Queueing keeps a clip copied mid-transfer waiting its turn
  /// instead of blowing up the connection.
  Future<void> _tail = Future<void>.value();

  /// Serializes whole transfers against each other.
  ///
  /// The receiver assembles one streamed clip at a time, so two transfers must
  /// not interleave — while a small clip copied mid-transfer is welcome to slip
  /// between segments, which is why this is a second queue and not just a
  /// longer turn on the first.
  Future<void> _streamTail = Future<void>.value();
  bool _closed = false;

  PeerConnection(this.peerId, this.socket, this.caps);

  bool get supportsStreaming => caps.contains(capStream);

  Future<void> run(Future<void> Function() action) {
    final next = _tail.then((_) async {
      if (_closed) return;
      await action();
    });
    // Keep the chain alive: a failed send must not poison later ones.
    _tail = next.catchError((_) {});
    return next;
  }

  /// Runs [action] with no other transfer in progress on this connection.
  Future<void> runExclusive(Future<void> Function() action) {
    final next = _streamTail.then((_) async {
      if (_closed) return;
      await action();
    });
    _streamTail = next.catchError((_) {});
    return next;
  }

  void close() {
    _closed = true;
    socket.close();
  }
}

/// Runs the local HTTP/WebSocket server, dials paired peers and
/// fans clipboard updates out to every connected device.
class SyncEngine {
  static const int portRangeStart = 45655;
  static const int portRangeEnd = 45675;

  /// How often each socket sends a WebSocket ping.
  ///
  /// Without it a peer that vanishes (phone sleeps, Wi-Fi drops, app killed)
  /// leaves a half-open socket that never fires `onDone`, so we keep thinking
  /// we are connected and never redial. A ping turns a dead link into a clean
  /// close within a couple of intervals, which the reconnect loop then heals.
  static const Duration keepAliveInterval = Duration(seconds: 10);

  /// Nothing unauthenticated is allowed to be big: a `/pair` body is a few
  /// hundred bytes of JSON and a `hello` frame smaller still, so anything past
  /// this is either broken or an attempt to make us allocate.
  static const int maxHandshakeBytes = 16 * 1024;

  /// How much of a streamed clip goes out before the write queue is handed
  /// back, so a clip copied during a long transfer is not stuck behind it.
  static const int segmentBytes = 4 * 1024 * 1024;

  final SettingsStore settings;
  final CryptoService crypto;
  final DeviceInfo Function() localInfo;

  /// Where files from a streamed clip are written as they arrive.
  final Future<Directory> Function() incomingDir;

  /// Incoming pairing request that needs user confirmation.
  final Future<bool> Function(PairRequest request) onPairRequest;

  /// A verified clipboard payload arrived from [peer].
  final void Function(Peer peer, ClipPayload payload) onRemoteClip;

  /// Connection set changed (for UI status).
  final void Function() onConnectionsChanged;

  /// A transfer started, advanced or finished.
  final void Function()? onTransfersChanged;

  /// Ports this engine binds and probes. Only tests move it, so that two
  /// suites running side by side cannot discover each other's engines.
  final int portStart;
  final int portEnd;

  HttpServer? _server;
  int port = 0;
  final Map<String, PeerConnection> _connections = {};
  final Set<String> _dialing = {};

  /// Transfers in flight, both directions, keyed by transfer id.
  final Map<String, TransferProgress> transfers = {};
  DateTime _lastProgressNotify = DateTime.fromMillisecondsSinceEpoch(0);

  /// Newest clip copied on this device, kept so a peer that connects later
  /// can still receive it. See [_replayLastClip].
  ClipPayload? _lastLocalClip;

  /// Clips already handed upwards, as `origin:ts`, oldest first.
  ///
  /// A peer replays its newest clip on every connect, so the same payload
  /// legitimately arrives again after each reconnect. This has to be checked
  /// here rather than further up: by the time a streamed clip reaches the app
  /// its files are already written, and a duplicate rejected there would leave
  /// a second copy of a multi-gigabyte file in the download folder.
  final Set<String> _delivered = {};
  static const int _deliveredRemembered = 32;

  /// True if this clip is new, recording it as seen.
  bool _claim(String origin, int ts) {
    if (!_delivered.add('$origin:$ts')) return false;
    if (_delivered.length > _deliveredRemembered) {
      _delivered.remove(_delivered.first); // insertion-ordered
    }
    return true;
  }

  bool _alreadyDelivered(String origin, int ts) =>
      _delivered.contains('$origin:$ts');

  SyncEngine({
    required this.settings,
    required this.crypto,
    required this.localInfo,
    required this.onPairRequest,
    required this.onRemoteClip,
    required this.onConnectionsChanged,
    this.onTransfersChanged,
    this.portStart = portRangeStart,
    this.portEnd = portRangeEnd,
    Future<Directory> Function()? incomingDir,
  }) : incomingDir = incomingDir ?? (() async => Directory.systemTemp);

  bool isConnected(String peerId) => _connections.containsKey(peerId);
  int get connectedCount => _connections.length;

  Future<void> start() async {
    for (var p = portStart; p <= portEnd; p++) {
      try {
        _server = await HttpServer.bind(InternetAddress.anyIPv4, p);
        port = p;
        break;
      } on SocketException {
        continue;
      }
    }
    if (_server == null) {
      throw StateError('No free port in $portStart-$portEnd');
    }
    _server!.listen(_handleRequest, onError: (_) {});
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      switch (request.uri.path) {
        case '/info':
          _writeJson(request.response, localInfo().toJson());
          break;
        case '/pair':
          await _handlePair(request);
          break;
        case '/ws':
          await _handleWebSocket(request);
          break;
        default:
          request.response.statusCode = HttpStatus.notFound;
          await request.response.close();
      }
    } catch (_) {
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {}
    }
  }

  void _writeJson(HttpResponse response, Map<String, dynamic> json) {
    response.headers.contentType = ContentType.json;
    response.write(jsonEncode(json));
    response.close();
  }

  /// Reads a request body, giving up once it passes [maxHandshakeBytes].
  ///
  /// `/pair` is reachable by anything on the LAN before any trust exists, so
  /// the body has to be bounded while it streams — checking afterwards would
  /// mean it was already in memory.
  static Future<String?> _readBoundedBody(HttpRequest request) async {
    final buffer = <int>[];
    await for (final chunk in request) {
      buffer.addAll(chunk);
      if (buffer.length > maxHandshakeBytes) return null;
    }
    try {
      return utf8.decode(buffer);
    } catch (_) {
      return null;
    }
  }

  // ---- Pairing (responder side) ----

  Future<void> _handlePair(HttpRequest request) async {
    // The socket the requester reached us on is where we can reach it back —
    // stored now so the reconnect loop has a target before discovery re-fires.
    final remoteAddress = request.connectionInfo?.remoteAddress.address;
    final body = await _readBoundedBody(request);
    final info = body == null
        ? null
        : DeviceInfo.tryParse(jsonDecode(body) as Map<String, dynamic>);
    if (info == null) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    final secret = await crypto.deriveSharedSecret(
      remotePublicKeyBase64: info.publicKey,
      myId: settings.deviceId,
      remoteId: info.id,
    );
    final code = await CryptoService.verificationCode(secret);

    final accepted = await onPairRequest(PairRequest(
      requester: info,
      code: code,
      respond: (_) {},
    )).timeout(const Duration(seconds: 60), onTimeout: () => false);

    if (accepted) {
      await settings.addPeer(Peer(
        id: info.id,
        name: info.name,
        platform: info.platform,
        secret: base64Encode(secret),
        lastAddress: remoteAddress,
        lastPort: info.port,
      ));
      _writeJson(request.response, {'accepted': true, ...localInfo().toJson()});
    } else {
      _writeJson(request.response, {'accepted': false});
    }
  }

  /// Initiates pairing with a discovered device (requester side).
  /// Returns the verification code to display and a future resolving once
  /// the remote user accepts or declines.
  Future<(String, Future<bool>)> requestPairing(FoundDevice device) async {
    final secret = await crypto.deriveSharedSecret(
      remotePublicKeyBase64: device.info.publicKey,
      myId: settings.deviceId,
      remoteId: device.info.id,
    );
    final code = await CryptoService.verificationCode(secret);

    final result = () async {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 5);
      try {
        final req = await client.postUrl(Uri.parse(
            'http://${device.address}:${device.info.port}/pair'));
        req.headers.contentType = ContentType.json;
        req.write(jsonEncode(localInfo().toJson()));
        final res = await req.close().timeout(const Duration(seconds: 70));
        final body = await utf8.decoder.bind(res).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        if (json['accepted'] == true) {
          await settings.addPeer(Peer(
            id: device.info.id,
            name: device.info.name,
            platform: device.info.platform,
            secret: base64Encode(secret),
            lastAddress: device.address,
            lastPort: device.info.port,
          ));
          return true;
        }
        return false;
      } catch (_) {
        return false;
      } finally {
        client.close(force: true);
      }
    }();
    return (code, result);
  }

  /// Looks up a device by [address] alone, for pairing without discovery.
  ///
  /// On networks that drop multicast between wireless clients, two phones never
  /// see each other over mDNS even though they can reach each other directly.
  /// The `/info` endpoint answers over plain unicast HTTP, so probing the port
  /// range turns a hand-typed IP into a [FoundDevice] the normal pairing flow
  /// accepts. Returns null if nothing on that address is a Plokee peer.
  ///
  /// Every port is probed at once: walked one at a time, a host that silently
  /// drops packets (a firewall, a wrong IP) costs one timeout per port and the
  /// user waits the better part of a minute for "not found".
  Future<FoundDevice?> probeDevice(String address) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 3)
      ..maxConnectionsPerHost = portEnd - portStart + 1;
    try {
      final attempts = [
        for (var p = portStart; p <= portEnd; p++)
          _probePort(client, address, p),
      ];
      // Lowest port first, so the answer does not depend on who replied
      // quickest — a device that binds two ports must resolve the same way
      // every time.
      for (final found in await Future.wait(attempts)) {
        if (found != null) return found;
      }
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<FoundDevice?> _probePort(
      HttpClient client, String address, int p) async {
    try {
      final req = await client.getUrl(Uri.parse('http://$address:$p/info'));
      final res = await req.close().timeout(const Duration(seconds: 3));
      if (res.statusCode != HttpStatus.ok) {
        await res.drain<void>();
        return null;
      }
      final body = await utf8.decoder.bind(res).join();
      final info = DeviceInfo.tryParse(jsonDecode(body) as Map<String, dynamic>);
      // Skip ourselves — every port we bind answers /info too.
      if (info == null || info.id == settings.deviceId) return null;
      return FoundDevice(info: info, address: address);
    } catch (_) {
      // Refused, filtered or not a Plokee peer.
      return null;
    }
  }

  // ---- WebSocket transport ----

  Future<void> _handleWebSocket(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    socket.pingInterval = keepAliveInterval;
    _PeerSession(engine: this, socket: socket, dialer: false).listen();
  }

  /// Dials a paired peer at [addresses] (best candidate first) on [peerPort].
  ///
  /// A discovered host often publishes several addresses and only some of them
  /// route from here, so every candidate is tried before giving up.
  Future<void> connectTo(
      Peer peer, List<String> addresses, int peerPort) async {
    if (_connections.containsKey(peer.id) || _dialing.contains(peer.id)) {
      return;
    }
    // Deterministic dialer: only the lexicographically smaller id dials,
    // so two devices don't hold duplicate connections.
    if (settings.deviceId.compareTo(peer.id) >= 0) return;
    _dialing.add(peer.id);
    try {
      for (final address in addresses) {
        if (_connections.containsKey(peer.id)) return;
        if (await _dial(peer, address, peerPort)) return;
      }
    } finally {
      _dialing.remove(peer.id);
    }
  }

  /// One dial attempt, resolving true only once the peer has authenticated.
  ///
  /// A socket that opens proves nothing: a mis-resolved address can point at
  /// another Plokee instance — or at this very device — which accepts the
  /// connection and then rejects the handshake. Only an authenticated channel
  /// counts, so a failed candidate hands over to the next one.
  Future<bool> _dial(Peer peer, String address, int peerPort) async {
    try {
      final socket = await WebSocket.connect('ws://$address:$peerPort/ws')
          .timeout(const Duration(seconds: 5));
      socket.pingInterval = keepAliveInterval;
      final session = _PeerSession(
        engine: this,
        socket: socket,
        dialer: true,
        expectedPeer: peer,
      );
      session.listen();
      await session.sendHello(peer);
      return await session.authenticated;
    } catch (_) {
      // Unreachable address or a refused connection: fall through to the next
      // candidate, and let discovery retry the whole set later.
      return false;
    }
  }

  void _register(Peer peer, WebSocket socket, Set<String> caps) {
    _connections[peer.id]?.close();
    final connection = PeerConnection(peer.id, socket, caps);
    _connections[peer.id] = connection;
    onConnectionsChanged();
    _replayLastClip(connection);
  }

  /// Hands a freshly connected peer the clip it missed while it was away.
  ///
  /// [broadcastClip] only reaches sockets that are live at the time, so a
  /// device that was asleep never learns what was copied meanwhile. Replaying
  /// on connect closes that gap — see [clipReplayWindow] for why only the
  /// newest clip, and only a recent one, is worth resending.
  void _replayLastClip(PeerConnection connection) {
    final payload = _lastLocalClip;
    if (payload == null || !settings.syncEnabled) return;
    final age = DateTime.now().millisecondsSinceEpoch - payload.ts;
    // Same clock wrote ts and reads it here, so the comparison is sound.
    if (age < 0 || age > clipReplayWindow.inMilliseconds) return;
    unawaited(_sendClipTo(connection, payload));
  }

  void _unregister(String? peerId, WebSocket socket) {
    if (peerId == null) return;
    if (_connections[peerId]?.socket == socket) {
      _connections.remove(peerId)?._closed = true;
      onConnectionsChanged();
    }
  }

  /// Encrypts and sends a local clipboard update to every connected peer.
  ///
  /// Peers are served concurrently: a phone on a weak link receiving a large
  /// file must not hold up the laptop next to it.
  Future<void> broadcastClip(ClipPayload payload) async {
    _lastLocalClip = payload;
    await Future.wait([
      for (final conn in List.of(_connections.values)) _sendClipTo(conn, payload)
    ]);
  }

  /// Sends one payload over one connection, inline or streamed.
  Future<void> _sendClipTo(
      PeerConnection connection, ClipPayload payload) async {
    final peer = settings.peerById(connection.peerId);
    if (peer == null) return;
    if (!peer.rules.allowsSend(payload.kind)) return;
    final secret = base64Decode(peer.secret);

    final size = payload.byteSize;
    if (size > inlineClipBytes && connection.supportsStreaming) {
      await _streamClipTo(connection, peer, payload, secret);
      return;
    }
    if (size > legacyMaxClipBytes) {
      // Only reachable for a peer too old to stream; it would buffer the whole
      // base64 blob and most likely die trying.
      return;
    }
    try {
      final inline = await payload.materialized();
      final clear = jsonEncode(inline.toJson());
      await connection.run(() async {
        final box = await CryptoService.encrypt(secret, clear);
        connection.socket.add(jsonEncode({'type': 'clip', 'box': box}));
      });
    } catch (_) {
      // Source file vanished, or the socket closed under us; the peer
      // reconnects and catches up then.
    }
  }

  /// Streams a payload chunk by chunk, reading it off disk as it goes.
  Future<void> _streamClipTo(PeerConnection connection, Peer peer,
      ClipPayload payload, Uint8List secret) async {
    final manifest = ClipManifest.of(payload, _newTransferId());
    final progress = TransferProgress.of(
      manifest,
      peerId: peer.id,
      peerName: peer.name,
      incoming: false,
    );
    await connection.runExclusive(() async {
      transfers[manifest.id] = progress;
      _notifyTransfers(force: true);
      final frames =
          StreamIterator<Uint8List>(_chunkFrames(payload, secret, progress));
      try {
        await connection.run(() async {
          connection.socket.add(jsonEncode({
            'type': 'xfer',
            'box': await CryptoService.encrypt(
                secret, jsonEncode(manifest.toJson()))
          }));
        });
        // One turn on the write queue per segment rather than one for the whole
        // file: a 4 GB transfer would otherwise hold the socket for as long as
        // it takes, and text copied meanwhile would not reach the peer until it
        // finished. Within a segment, addStream is what keeps memory flat — the
        // sink pauses the generator whenever the socket cannot keep up, however
        // slow the peer is.
        var exhausted = false;
        Stream<Uint8List> segment() async* {
          var sent = 0;
          while (sent < segmentBytes) {
            if (!await frames.moveNext()) {
              exhausted = true;
              return;
            }
            yield frames.current;
            sent += frames.current.length;
          }
        }

        while (!exhausted) {
          await connection.run(() => connection.socket.addStream(segment()));
        }
        await connection.run(() async {
          connection.socket.add(jsonEncode({
            'type': 'xfer_done',
            'box': await CryptoService.encrypt(
                secret, jsonEncode({'id': manifest.id}))
          }));
        });
      } catch (_) {
        // Socket died or the file was removed mid-read. The receiver never
        // sees xfer_done and drops its partial files.
      } finally {
        await frames.cancel();
        transfers.remove(manifest.id);
        _notifyTransfers(force: true);
      }
    });
  }


  /// Sealed chunk frames for [payload], in manifest order.
  Stream<Uint8List> _chunkFrames(
      ClipPayload payload, Uint8List secret, TransferProgress progress) async* {
    final sources = switch (payload.kind) {
      ClipKind.text => <Stream<List<int>>>[
          Stream.value(utf8.encode(payload.text!))
        ],
      ClipKind.image => <Stream<List<int>>>[Stream.value(payload.imageBytes!)],
      ClipKind.files => [for (final f in payload.files) f.openRead()],
    };

    for (var i = 0; i < sources.length; i++) {
      var offset = 0;
      await for (final block in sources[i]) {
        // A block off disk is whatever size the OS handed back, and an
        // in-memory source is one block of everything; cap both so no single
        // frame can be large.
        for (var start = 0; start < block.length; start += transferChunkBytes) {
          final end = min(start + transferChunkBytes, block.length);
          final piece = block is Uint8List
              ? Uint8List.sublistView(block, start, end)
              : Uint8List.fromList(block.sublist(start, end));
          yield await encodeChunkFrame(secret, i, offset, piece);
          offset += piece.length;
          progress.done += piece.length;
          _notifyTransfers();
        }
      }
    }
  }

  static String _newTransferId() {
    final rng = Random.secure();
    return List.generate(16, (_) => rng.nextInt(16).toRadixString(16)).join();
  }

  /// Publishes transfer progress, throttled — a chunk lands every few
  /// milliseconds and rebuilding the UI that often is pure waste.
  void _notifyTransfers({bool force = false}) {
    final now = DateTime.now();
    if (!force && now.difference(_lastProgressNotify).inMilliseconds < 120) {
      return;
    }
    _lastProgressNotify = now;
    onTransfersChanged?.call();
  }

  void disconnectPeer(String peerId) {
    _connections.remove(peerId)?.close();
    onConnectionsChanged();
  }

  Future<void> stop() async {
    for (final c in _connections.values) {
      c.close();
    }
    _connections.clear();
    transfers.clear();
    await _server?.close(force: true);
    _server = null;
  }
}

/// One socket's lifetime: handshake, then clip traffic in both forms.
///
/// A WebSocket is a single-subscription stream, so each socket gets exactly
/// one listener acting as a small state machine. Handling is asynchronous
/// (decrypt, then a disk write), and the subscription is paused for the
/// duration of each frame — without that, a fast sender would queue events in
/// memory faster than they can be written, which is the very thing streaming
/// exists to avoid.
class _PeerSession {
  final SyncEngine engine;
  final WebSocket socket;
  final bool dialer;
  final Peer? expectedPeer;

  final Completer<bool> _authenticated = Completer<bool>();
  Peer? _peer;
  Uint8List? _secret;
  StreamSubscription? _sub;
  Timer? _authTimer;

  InboundTransfer? _inbound;
  TransferProgress? _inboundProgress;

  _PeerSession({
    required this.engine,
    required this.socket,
    required this.dialer,
    this.expectedPeer,
  });

  Future<bool> get authenticated => _authenticated.future;

  void listen() {
    _authTimer = Timer(const Duration(seconds: 10), () {
      if (_peer == null) socket.close();
    });
    final sub = socket.listen(null, cancelOnError: true);
    _sub = sub;
    sub
      ..onData((data) => sub.pause(_handle(data)))
      ..onDone(_finish)
      ..onError((_) => _finish());
  }

  Future<void> _handle(dynamic data) async {
    try {
      if (_peer == null) {
        await _handleHandshake(data);
        return;
      }
      if (data is String) {
        await _handleControl(data);
      } else if (data is Uint8List) {
        await _handleChunk(data);
      } else if (data is List<int>) {
        await _handleChunk(Uint8List.fromList(data));
      }
    } catch (_) {
      // Malformed, undecryptable, or unwritable: never fatal for the process,
      // but the frame is dropped.
    }
  }

  // ---- Handshake ----

  Future<void> sendHello(Peer peer) async {
    final secret = base64Decode(peer.secret);
    final nonce = CryptoService.randomNonceBase64();
    socket.add(jsonEncode({
      'type': 'hello',
      'id': engine.settings.deviceId,
      'nonce': nonce,
      'mac': await CryptoService.handshakeMac(
          secret, nonce, engine.settings.deviceId),
      'caps': [capStream],
    }));
  }

  Future<void> _handleHandshake(dynamic data) async {
    if (data is! String || data.length > SyncEngine.maxHandshakeBytes) {
      socket.close();
      return;
    }
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      final peer = dialer
          ? await _verifyAck(json)
          : await _verifyHelloAndAck(json);
      if (peer == null) throw const FormatException('rejected');
      _peer = peer;
      _secret = base64Decode(peer.secret);
      _authTimer?.cancel();
      engine._register(peer, socket, _capsOf(json));
      if (!_authenticated.isCompleted) _authenticated.complete(true);
    } catch (_) {
      socket.close();
    }
  }

  static Set<String> _capsOf(Map<String, dynamic> json) => {
        for (final c in (json['caps'] as List<dynamic>? ?? const []))
          if (c is String) c,
      };

  /// Responder side: check the peer's proof, then prove ourselves back.
  Future<Peer?> _verifyHelloAndAck(Map<String, dynamic> json) async {
    if (json['type'] != 'hello') return null;
    final peerId = json['id'];
    if (peerId is! String) return null;
    final peer = engine.settings.peerById(peerId);
    if (peer == null) return null;
    final secret = base64Decode(peer.secret);
    final expected = await CryptoService.handshakeMac(
        secret, json['nonce'] as String, peerId);
    if (expected != json['mac']) return null;

    final myNonce = CryptoService.randomNonceBase64();
    socket.add(jsonEncode({
      'type': 'hello_ack',
      'id': engine.settings.deviceId,
      'nonce': myNonce,
      'mac': await CryptoService.handshakeMac(
          secret, myNonce, engine.settings.deviceId),
      'caps': [capStream],
    }));
    return peer;
  }

  /// Dialer side: the answer must come from the device we dialled.
  Future<Peer?> _verifyAck(Map<String, dynamic> json) async {
    final peer = expectedPeer;
    if (peer == null) return null;
    if (json['type'] != 'hello_ack' || json['id'] != peer.id) return null;
    final secret = base64Decode(peer.secret);
    final expected = await CryptoService.handshakeMac(
        secret, json['nonce'] as String, peer.id);
    return expected == json['mac'] ? peer : null;
  }

  // ---- Clip traffic ----

  Future<void> _handleControl(String data) async {
    final json = jsonDecode(data) as Map<String, dynamic>;
    final secret = _secret!;
    switch (json['type']) {
      case 'clip':
        final clear = await CryptoService.decrypt(secret, json['box'] as String);
        final payload =
            ClipPayload.tryParse(jsonDecode(clear) as Map<String, dynamic>);
        if (payload != null) _deliver(payload);
      case 'xfer':
        final clear = await CryptoService.decrypt(secret, json['box'] as String);
        await _beginInbound(
            ClipManifest.tryParse(jsonDecode(clear) as Map<String, dynamic>));
      case 'xfer_done':
        final clear = await CryptoService.decrypt(secret, json['box'] as String);
        await _finishInbound(
            (jsonDecode(clear) as Map<String, dynamic>)['id'] as String?);
      case 'xfer_cancel':
        await _dropInbound();
    }
  }

  Future<void> _beginInbound(ClipManifest? manifest) async {
    // Only one transfer at a time per socket: the sender serializes them, so a
    // second manifest means the first will never finish.
    await _dropInbound();
    if (manifest == null) return;
    // Refuse before a single byte touches the disk, not after: this is where a
    // rejected clip costs nothing, and where a replay of one already applied
    // would otherwise be written out a second time.
    if (!_peer!.rules.allowsReceive(manifest.kind)) return;
    if (!engine.settings.syncEnabled) return;
    if (engine._alreadyDelivered(manifest.origin, manifest.ts)) return;
    _inbound = InboundTransfer(
      manifest: manifest,
      dir: await engine.incomingDir(),
    );
    _inboundProgress = TransferProgress.of(
      manifest,
      peerId: _peer!.id,
      peerName: _peer!.name,
      incoming: true,
    );
    engine.transfers[manifest.id] = _inboundProgress!;
    engine._notifyTransfers(force: true);
  }

  Future<void> _handleChunk(Uint8List frame) async {
    final inbound = _inbound;
    if (inbound == null) return;
    final chunk = await decodeChunkFrame(_secret!, frame);
    if (chunk == null || !await inbound.accept(chunk)) {
      await _dropInbound();
      return;
    }
    _inboundProgress?.done = inbound.received;
    engine._notifyTransfers();
  }

  Future<void> _finishInbound(String? id) async {
    final inbound = _inbound;
    if (inbound == null) return;
    if (id != inbound.manifest.id) {
      await _dropInbound();
      return;
    }
    _inbound = null;
    engine.transfers.remove(inbound.manifest.id);
    _inboundProgress = null;
    engine._notifyTransfers(force: true);
    final payload = await inbound.finish();
    if (payload != null) _deliver(payload);
  }

  Future<void> _dropInbound() async {
    final inbound = _inbound;
    _inbound = null;
    if (inbound != null) {
      engine.transfers.remove(inbound.manifest.id);
      _inboundProgress = null;
      engine._notifyTransfers(force: true);
      await inbound.abort();
    }
  }

  void _deliver(ClipPayload payload) {
    final peer = _peer;
    if (peer == null) return;
    if (!peer.rules.allowsReceive(payload.kind)) return;
    if (!engine._claim(payload.origin, payload.ts)) return;
    engine.onRemoteClip(peer, payload);
  }

  void _finish() {
    _authTimer?.cancel();
    _sub?.cancel();
    unawaited(_dropInbound());
    engine._unregister(_peer?.id, socket);
    if (!_authenticated.isCompleted) _authenticated.complete(false);
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'crypto.dart';
import 'models.dart';
import 'settings_store.dart';

/// An authenticated WebSocket link to one paired device.
class PeerConnection {
  final String peerId;
  final WebSocket socket;

  PeerConnection(this.peerId, this.socket);

  void close() {
    socket.close();
  }
}

/// Runs the local HTTP/WebSocket server, dials paired peers and
/// fans clipboard updates out to every connected device.
class SyncEngine {
  static const int portRangeStart = 45655;
  static const int portRangeEnd = 45675;

  final SettingsStore settings;
  final CryptoService crypto;
  final DeviceInfo Function() localInfo;

  /// Incoming pairing request that needs user confirmation.
  final Future<bool> Function(PairRequest request) onPairRequest;

  /// A verified clipboard payload arrived from [peer].
  final void Function(Peer peer, ClipPayload payload) onRemoteClip;

  /// Connection set changed (for UI status).
  final void Function() onConnectionsChanged;

  HttpServer? _server;
  int port = 0;
  final Map<String, PeerConnection> _connections = {};
  final Set<String> _dialing = {};

  /// Newest clip copied on this device, kept so a peer that connects later
  /// can still receive it. See [_replayLastClip].
  ClipPayload? _lastLocalClip;

  SyncEngine({
    required this.settings,
    required this.crypto,
    required this.localInfo,
    required this.onPairRequest,
    required this.onRemoteClip,
    required this.onConnectionsChanged,
  });

  bool isConnected(String peerId) => _connections.containsKey(peerId);
  int get connectedCount => _connections.length;

  Future<void> start() async {
    for (var p = portRangeStart; p <= portRangeEnd; p++) {
      try {
        _server = await HttpServer.bind(InternetAddress.anyIPv4, p);
        port = p;
        break;
      } on SocketException {
        continue;
      }
    }
    if (_server == null) {
      throw StateError('No free port in $portRangeStart-$portRangeEnd');
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

  // ---- Pairing (responder side) ----

  Future<void> _handlePair(HttpRequest request) async {
    final body = await utf8.decoder.bind(request).join();
    final info = DeviceInfo.tryParse(jsonDecode(body) as Map<String, dynamic>);
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

  // ---- WebSocket transport ----
  //
  // A WebSocket is a single-subscription stream, so each socket gets exactly
  // one listener acting as a small state machine: the first frame must be an
  // authenticated hello, everything after that is encrypted clip traffic.

  Future<void> _handleWebSocket(HttpRequest request) async {
    if (!WebSocketTransformer.isUpgradeRequest(request)) {
      request.response.statusCode = HttpStatus.badRequest;
      await request.response.close();
      return;
    }
    final socket = await WebSocketTransformer.upgrade(request);
    Peer? authed;
    final authTimeout = Timer(const Duration(seconds: 10), () {
      if (authed == null) socket.close();
    });

    socket.listen((data) async {
      if (authed != null) {
        await _handleClipFrame(authed!, data);
        return;
      }
      try {
        final hello = jsonDecode(data as String) as Map<String, dynamic>;
        if (hello['type'] != 'hello') throw const FormatException();
        final peerId = hello['id'] as String;
        final peer = settings.peerById(peerId);
        if (peer == null) throw const FormatException('unknown peer');
        final secret = base64Decode(peer.secret);
        final expected = await CryptoService.handshakeMac(
            secret, hello['nonce'] as String, peerId);
        if (expected != hello['mac']) throw const FormatException('bad mac');

        // Prove our own identity back.
        final myNonce = CryptoService.randomNonceBase64();
        socket.add(jsonEncode({
          'type': 'hello_ack',
          'id': settings.deviceId,
          'nonce': myNonce,
          'mac': await CryptoService.handshakeMac(
              secret, myNonce, settings.deviceId),
        }));
        authed = peer;
        authTimeout.cancel();
        _register(peer, socket);
      } catch (_) {
        socket.close();
      }
    }, onDone: () {
      authTimeout.cancel();
      _unregister(authed?.id, socket);
    }, onError: (_) {
      authTimeout.cancel();
      _unregister(authed?.id, socket);
    });
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
    final authenticated = Completer<bool>();
    void finish(bool ok) {
      if (!authenticated.isCompleted) authenticated.complete(ok);
    }

    try {
      final socket = await WebSocket.connect('ws://$address:$peerPort/ws')
          .timeout(const Duration(seconds: 5));
      final secret = base64Decode(peer.secret);
      final nonce = CryptoService.randomNonceBase64();

      var acked = false;
      final ackTimeout = Timer(const Duration(seconds: 5), () {
        if (!acked) socket.close();
      });

      socket.listen((data) async {
        if (acked) {
          await _handleClipFrame(peer, data);
          return;
        }
        try {
          final ack = jsonDecode(data as String) as Map<String, dynamic>;
          if (ack['type'] != 'hello_ack' || ack['id'] != peer.id) {
            throw const FormatException();
          }
          final expected = await CryptoService.handshakeMac(
              secret, ack['nonce'] as String, peer.id);
          if (expected != ack['mac']) throw const FormatException('bad mac');
          acked = true;
          ackTimeout.cancel();
          _register(peer, socket);
          finish(true);
        } catch (_) {
          socket.close();
        }
      }, onDone: () {
        ackTimeout.cancel();
        _unregister(acked ? peer.id : null, socket);
        finish(false);
      }, onError: (_) {
        ackTimeout.cancel();
        _unregister(acked ? peer.id : null, socket);
        finish(false);
      });

      socket.add(jsonEncode({
        'type': 'hello',
        'id': settings.deviceId,
        'nonce': nonce,
        'mac': await CryptoService.handshakeMac(
            secret, nonce, settings.deviceId),
      }));
      return await authenticated.future;
    } catch (_) {
      // Unreachable address or a refused connection: fall through to the next
      // candidate, and let discovery retry the whole set later.
      return false;
    }
  }

  Future<void> _handleClipFrame(Peer peer, dynamic data) async {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      if (json['type'] != 'clip') return;
      final secret = base64Decode(peer.secret);
      final clear = await CryptoService.decrypt(secret, json['box'] as String);
      final payload =
          ClipPayload.tryParse(jsonDecode(clear) as Map<String, dynamic>);
      if (payload != null) {
        onRemoteClip(peer, payload);
      }
    } catch (_) {
      // Undecryptable or malformed frame: drop it.
    }
  }

  void _register(Peer peer, WebSocket socket) {
    _connections[peer.id]?.close();
    final connection = PeerConnection(peer.id, socket);
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
    _sendClipTo(connection, jsonEncode(payload.toJson()));
  }

  void _unregister(String? peerId, WebSocket socket) {
    if (peerId == null) return;
    if (_connections[peerId]?.socket == socket) {
      _connections.remove(peerId);
      onConnectionsChanged();
    }
  }

  /// Encrypts and sends a local clipboard update to every connected peer.
  /// Returns false if the clip exceeds [maxClipBytes] and was not sent.
  Future<bool> broadcastClip(ClipPayload payload) async {
    final clear = jsonEncode(payload.toJson());
    if (clear.length > maxClipBytes) return false;
    _lastLocalClip = payload;
    for (final conn in List.of(_connections.values)) {
      await _sendClipTo(conn, clear);
    }
    return true;
  }

  /// Encrypts [clear] under [connection]'s pairing secret and sends it.
  Future<void> _sendClipTo(PeerConnection connection, String clear) async {
    final peer = settings.peerById(connection.peerId);
    if (peer == null) return;
    try {
      final box = await CryptoService.encrypt(base64Decode(peer.secret), clear);
      connection.socket.add(jsonEncode({'type': 'clip', 'box': box}));
    } catch (_) {
      // Socket closed under us; the peer reconnects and catches up then.
    }
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
    await _server?.close(force: true);
  }
}

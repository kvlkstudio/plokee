import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'clipboard_service.dart';
import 'crypto.dart';
import 'discovery.dart';
import 'foreground_service.dart';
import 'history_store.dart';
import 'localization.dart';
import 'models.dart';
import 'settings_store.dart';
import 'sync_engine.dart';

/// Central application state: wires discovery, sync, clipboard and settings
/// together and exposes them to the UI.
class AppState extends ChangeNotifier with WidgetsBindingObserver {
  late final SettingsStore settings;
  late final CryptoService crypto;
  late final SyncEngine engine;
  late final DiscoveryService discovery;
  late final ClipboardService clipboard;
  HistoryStore? _historyStore;

  /// Set by the UI layer: shows a confirmation dialog for an incoming
  /// pairing request and resolves with the user's decision.
  Future<bool> Function(PairRequest request)? pairRequestHandler;

  final Map<String, FoundDevice> found = {};
  final List<ClipItem> history = [];
  static const int historyLimit = 100;

  Timer? _pruneTimer;
  Timer? _historySaveTimer;
  Directory? _saveDir;

  /// True once the late fields (settings, engine, …) are safe to touch.
  bool initialized = false;
  bool started = false;
  String? startupError;

  Future<void> init() async {
    settings = await SettingsStore.load();
    // Apply the saved language before anything builds strings (tray menu and
    // the Android notification read it through localeOverride).
    localeOverride = parseLocaleCode(settings.localeCode);
    crypto = await CryptoService.fromSeed(settings.keySeed);

    // Restore the saved clipboard history before showing the UI.
    try {
      final store = HistoryStore(await _historyDir());
      _historyStore = store;
      history.addAll(await store.load());
    } catch (_) {
      // A corrupt or unreadable history just starts empty.
    }

    engine = SyncEngine(
      settings: settings,
      crypto: crypto,
      localInfo: _localInfo,
      onPairRequest: (req) async {
        final handler = pairRequestHandler;
        if (handler == null) return false;
        final ok = await handler(req);
        if (ok) notifyListeners();
        return ok;
      },
      onRemoteClip: _onRemoteClip,
        onConnectionsChanged: notifyListeners,
    );

    discovery = DiscoveryService(
      localInfo: _localInfo,
      onDeviceSeen: _onDeviceSeen,
    );

    clipboard = ClipboardService(
      onLocalClip: _onLocalClip,
      initialSignature: settings.lastClipSignature,
      onSignatureChanged: settings.setLastClipSignature,
    );
    initialized = true;
    notifyListeners();

    try {
      await engine.start();
      // Before discovery: dialling known peers must not wait on a browse that
      // may be slow (Bonjour) or unavailable entirely.
      _reconnectKnownPeers();
      await discovery.start();
      await clipboard.start();
      started = true;
    } catch (e) {
      startupError = e.toString();
    }

    WidgetsBinding.instance.addObserver(this);
    _pruneTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final before = found.length;
      found.removeWhere((_, d) => d.isStale);
      if (found.length != before) notifyListeners();
    });
    _syncForegroundService();
    notifyListeners();
  }

  /// Dials peers at their last known address without waiting for discovery.
  ///
  /// Discovery stays the source of truth — it corrects the address when a peer
  /// moves — but this removes discovery as a single point of failure for
  /// already-paired devices, which matters most on iOS where Bonjour is the
  /// only channel. [SyncEngine.connectTo] swallows failures and enforces the
  /// deterministic-dialer rule, so a stale address costs nothing but a timeout.
  void _reconnectKnownPeers() {
    for (final peer in settings.peers) {
      final address = peer.lastAddress;
      final port = peer.lastPort;
      if (address == null || port == null) continue;
      if (engine.isConnected(peer.id)) continue;
      engine.connectTo(peer, [address], port);
    }
  }

  /// Runs the Android keep-alive service exactly when sync + background sync
  /// are both on. No-op on other platforms.
  void _syncForegroundService() {
    if (started && settings.syncEnabled && settings.backgroundSync) {
      ForegroundService.start();
    } else {
      ForegroundService.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Mobile: the OS only lets us touch the clipboard in the foreground,
    // so check it whenever the user brings the app back.
    if (state == AppLifecycleState.resumed &&
        isMobilePlatform &&
        started &&
        settings.autoReadOnResume &&
        settings.syncEnabled) {
      clipboard.checkNow();
    }
    // Going to the background is the last safe moment to persist before the
    // OS may kill us, so flush any pending history write now.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (_historySaveTimer?.isActive ?? false) {
        _historySaveTimer!.cancel();
        _historyStore?.save(List.of(history));
      }
    }
  }

  DeviceInfo _localInfo() => DeviceInfo(
        id: settings.deviceId,
        name: settings.deviceName,
        platform: currentPlatformName(),
        publicKey: crypto.publicKeyBase64,
        port: engine.port,
      );

  void _onDeviceSeen(DeviceInfo info, List<String> addresses) {
    final address = addresses.first;
    final existing = found[info.id];
    if (existing != null &&
        existing.address == address &&
        existing.info.name == info.name &&
        existing.info.port == info.port) {
      existing.lastSeen = DateTime.now();
    } else {
      found[info.id] = FoundDevice(info: info, address: address);
      notifyListeners();
    }
    final peer = settings.peerById(info.id);
    if (peer != null) {
      // Adopt the peer's current advertised name (e.g. after it switched
      // from a duplicate hostname to a real device name).
      settings.updatePeerName(info.id, info.name).then((changed) {
        if (changed) notifyListeners();
      });
      // Remember the address even while connected: it is what makes a later
      // cold start able to reconnect before discovery reports anything.
      settings.updatePeerAddress(info.id, address, info.port);
      if (!engine.isConnected(info.id)) {
        engine.connectTo(peer, addresses, info.port);
      }
    }
  }

  /// Where received files are stored: Downloads/Plokee on desktop,
  /// app documents on mobile.
  Future<Directory> saveDir() async {
    if (_saveDir != null) return _saveDir!;
    Directory base;
    try {
      base = isMobilePlatform
          ? await getApplicationDocumentsDirectory()
          : (await getDownloadsDirectory() ??
              await getApplicationDocumentsDirectory());
    } catch (_) {
      base = Directory.systemTemp;
    }
    _saveDir = Directory('${base.path}${Platform.pathSeparator}Plokee');
    return _saveDir!;
  }

  /// Private per-app directory for the persisted history and its images.
  Future<Directory> _historyDir() async {
    Directory base;
    try {
      base = await getApplicationSupportDirectory();
    } catch (_) {
      base = Directory.systemTemp;
    }
    return Directory('${base.path}${Platform.pathSeparator}Plokee');
  }

  ClipPayload _payloadFrom(LocalClip clip) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    return switch (clip.kind) {
      ClipKind.text =>
        ClipPayload.text(clip.text!, ts: ts, origin: settings.deviceId),
      ClipKind.image =>
        ClipPayload.image(clip.image!, ts: ts, origin: settings.deviceId),
      ClipKind.files =>
        ClipPayload.files(clip.files, ts: ts, origin: settings.deviceId),
    };
  }

  void _onLocalClip(LocalClip clip) {
    _addHistory(ClipItem(
      kind: clip.kind,
      text: clip.text,
      imageBytes: clip.image,
      fileNames: clip.files.map((f) => f.name).toList(),
      filePaths: clip.sourcePaths,
      time: DateTime.now(),
      sourceName: settings.deviceName,
      remote: false,
    ));
    if (settings.syncEnabled) {
      engine.broadcastClip(_payloadFrom(clip));
    }
  }

  /// Clips already applied, as `origin:ts`, oldest first.
  ///
  /// A peer replays its newest clip every time we connect to it, so the same
  /// payload legitimately arrives again after every reconnect. Applying it
  /// twice would rewrite the clipboard behind the user's back and, for files,
  /// save a second copy alongside the first.
  final Set<String> _appliedClips = {};
  static const int _appliedClipsRemembered = 16;

  Future<void> _onRemoteClip(Peer peer, ClipPayload payload) async {
    if (!settings.syncEnabled) return;
    if (!_appliedClips.add('${payload.origin}:${payload.ts}')) return;
    if (_appliedClips.length > _appliedClipsRemembered) {
      _appliedClips.remove(_appliedClips.first); // insertion-ordered
    }
    final result =
        await clipboard.applyRemote(payload, saveDir: await saveDir());
    _addHistory(ClipItem(
      kind: payload.kind,
      text: payload.text,
      imageBytes: payload.imageBytes,
      fileNames: payload.files.map((f) => f.name).toList(),
      filePaths: result.savedPaths,
      time: DateTime.now(),
      sourceName: peer.name,
      remote: true,
    ));
  }

  /// Writes an image entry's bytes to disk so it survives a restart, then
  /// records the path on the stored item.
  Future<void> _persistImage(ClipItem item) async {
    final store = _historyStore;
    if (store == null || item.imageBytes == null) return;
    final path = await store.persistImage(
        item.imageBytes!, item.time.millisecondsSinceEpoch);
    if (path == null) return;
    final index = history.indexOf(item);
    if (index >= 0) {
      history[index] = item.copyWith(imagePath: path);
      _scheduleHistorySave();
    }
  }

  void _addHistory(ClipItem item) {
    if (history.isNotEmpty &&
        history.first.kind == item.kind &&
        history.first.preview == item.preview) {
      return;
    }
    history.insert(0, item);
    if (history.length > historyLimit) {
      history.removeRange(historyLimit, history.length);
    }
    notifyListeners();
    // Images get written to disk first (which records their path), which
    // itself schedules a save; other kinds just schedule the save.
    if (item.kind == ClipKind.image && item.imagePath == null) {
      _persistImage(item);
    } else {
      _scheduleHistorySave();
    }
  }

  /// Coalesces rapid history changes into one write.
  void _scheduleHistorySave() {
    _historySaveTimer?.cancel();
    _historySaveTimer = Timer(const Duration(milliseconds: 400), () {
      _historyStore?.save(List.of(history));
    });
  }

  Future<void> clearHistory() async {
    history.clear();
    notifyListeners();
    _historySaveTimer?.cancel();
    await _historyStore?.clear();
  }

  /// Devices visible on the network that we are not paired with yet.
  List<FoundDevice> get unpairedFound => found.values
      .where((d) => settings.peerById(d.info.id) == null)
      .toList()
    ..sort((a, b) => a.info.name.compareTo(b.info.name));

  bool isPeerOnline(String peerId) =>
      engine.isConnected(peerId) || found.containsKey(peerId);

  Future<(String, Future<bool>)> startPairing(FoundDevice device) async {
    final result = await engine.requestPairing(device);
    unawaited(result.$2.then((_) => notifyListeners()));
    return result;
  }

  /// Mobile "Send clipboard" button / auto-check on resume.
  /// Returns true if something new was sent.
  Future<bool> sendClipboardNow() async {
    final clip = await clipboard.checkNow();
    return clip != null;
  }

  /// Re-applies a history entry to the clipboard and rebroadcasts it.
  Future<void> copyFromHistory(ClipItem item) async {
    final ts = DateTime.now().millisecondsSinceEpoch;
    ClipPayload? payload;
    switch (item.kind) {
      case ClipKind.text:
        payload =
            ClipPayload.text(item.text!, ts: ts, origin: settings.deviceId);
      case ClipKind.image:
        final bytes = item.imageBytes;
        if (bytes == null) return; // on-disk copy is gone, same as lost files
        payload =
            ClipPayload.image(bytes, ts: ts, origin: settings.deviceId);
      case ClipKind.files:
        final files = <ClipFile>[];
        final livePaths = <String>[];
        for (final path in item.filePaths) {
          final file = File(path);
          if (await file.exists()) {
            livePaths.add(path);
            files.add(ClipFile(
                name: file.uri.pathSegments.last,
                bytes: await file.readAsBytes()));
          }
        }
        if (files.isEmpty) return; // sources are gone
        payload =
            ClipPayload.files(files, ts: ts, origin: settings.deviceId);
        // Files already exist locally: put the paths back on the clipboard
        // instead of saving fresh copies.
        await clipboard.reapplyFiles(livePaths, payload.signature);
        if (settings.syncEnabled) {
          await engine.broadcastClip(payload);
        }
        return;
    }
    await clipboard.applyRemote(payload, saveDir: await saveDir());
    if (settings.syncEnabled) {
      await engine.broadcastClip(payload);
    }
  }

  Future<void> unpair(String peerId) async {
    engine.disconnectPeer(peerId);
    await settings.removePeer(peerId);
    notifyListeners();
  }

  Future<void> setSyncEnabled(bool enabled) async {
    await settings.setSyncEnabled(enabled);
    _syncForegroundService();
    notifyListeners();
  }

  Future<void> setBackgroundSync(bool enabled) async {
    await settings.setBackgroundSync(enabled);
    _syncForegroundService();
    notifyListeners();
  }

  /// Sets the UI language. [code] is a value from [localeCodeOf], or null to
  /// follow the system language.
  Future<void> setLocale(String? code) async {
    await settings.setLocaleCode(code);
    localeOverride = parseLocaleCode(code);
    // The running notification keeps its old text; it is rebuilt in the new
    // language the next time the service starts.
    _syncForegroundService();
    notifyListeners();
  }

  Future<void> setAutoReadOnResume(bool enabled) async {
    await settings.setAutoReadOnResume(enabled);
    notifyListeners();
  }

  Future<void> setDeviceName(String name) async {
    await settings.setDeviceName(name.trim());
    discovery.announce();
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pruneTimer?.cancel();
    // Flush any pending history write before shutting down.
    if (_historySaveTimer?.isActive ?? false) {
      _historySaveTimer!.cancel();
      _historyStore?.save(List.of(history));
    }
    discovery.stop();
    clipboard.stop();
    engine.stop();
    ForegroundService.stop();
    super.dispose();
  }
}

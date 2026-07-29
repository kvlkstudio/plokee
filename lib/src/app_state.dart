import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:path_provider/path_provider.dart';

import 'android_controls.dart';
import 'clipboard_service.dart';
import 'crypto.dart';
import 'discovery.dart';
import 'foreground_service.dart';
import 'history_store.dart';
import 'ios_extensions.dart';
import 'localization.dart';
import 'models.dart';
import 'settings_store.dart';
import 'sync_engine.dart';
import 'transfer.dart';

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
  Timer? _reconnectTimer;
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
      incomingDir: saveDir,
      onPairRequest: (req) async {
        final handler = pairRequestHandler;
        if (handler == null) return false;
        final ok = await handler(req);
        if (ok) notifyListeners();
        return ok;
      },
      onRemoteClip: _onRemoteClip,
      onConnectionsChanged: () {
        // The Android notification and the iOS widget both show how many
        // devices are connected, so both are rewritten when that changes.
        _syncForegroundService();
        _scheduleWidgetUpdate();
        notifyListeners();
      },
      onTransfersChanged: notifyListeners,
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

    // Sync can be paused and resumed from outside the UI on Android: the
    // quick settings tile and the notification's own button.
    AndroidControls.listen(onSyncChanged: (enabled) {
      if (settings.syncEnabled != enabled) setSyncEnabled(enabled);
    });
    FlutterForegroundTask.addTaskDataCallback(_onServiceAction);

    await _startServices();

    WidgetsBinding.instance.addObserver(this);
    _pruneTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      final before = found.length;
      found.removeWhere((_, d) => d.isStale);
      if (found.length != before) notifyListeners();
    });
    // Keep paired devices connected without leaning on discovery to re-fire.
    // On the iOS↔Android link there is no UDP heartbeat and Bonjour resolves a
    // service just once, so a dropped socket would otherwise never redial.
    _reconnectTimer = Timer.periodic(
        const Duration(seconds: 5), (_) => _reconnectKnownPeers());
    _syncForegroundService();
    notifyListeners();
  }

  /// Brings up the server, discovery and the clipboard watcher.
  ///
  /// Startup is genuinely fallible — every port in the range can be taken by a
  /// copy of the app that has not finished exiting, and on a machine that is
  /// still bringing up Wi-Fi there may be no interface to bind at all. Failing
  /// permanently on that leaves a dead app until the user restarts it, so the
  /// attempt is simply repeated in the background while the error stays on
  /// screen.
  Future<void> _startServices() async {
    try {
      await engine.start();
      // Before discovery: dialling known peers must not wait on a browse that
      // may be slow (Bonjour) or unavailable entirely.
      _reconnectKnownPeers();
      await discovery.start();
      await clipboard.start();
      started = true;
      startupError = null;
      unawaited(_drainExtensions());
      _scheduleWidgetUpdate();
      _startRetryTimer?.cancel();
      _startRetryTimer = null;
      _syncForegroundService();
    } catch (e) {
      startupError = e.toString();
      _startRetryTimer ??=
          Timer.periodic(const Duration(seconds: 10), (_) => _startServices());
    }
    notifyListeners();
  }

  Timer? _startRetryTimer;

  /// Picks up everything that reached Plokee while it was not the app in
  /// front: files and text from the iOS Share sheet, and requests from
  /// Shortcuts. No-op on every other platform.
  Future<void> _drainExtensions() async {
    for (final command in await IosExtensions.takeCommands()) {
      switch (command) {
        case ShortcutCommand.sendClipboard:
          await sendClipboardNow();
        case ShortcutCommand.enableSync:
          if (!settings.syncEnabled) await setSyncEnabled(true);
        case ShortcutCommand.disableSync:
          if (settings.syncEnabled) await setSyncEnabled(false);
      }
    }
    for (final item in await IosExtensions.drainInbox()) {
      await _acceptShared(item);
    }
  }

  /// Treats something shared into Plokee exactly like something copied here:
  /// it goes on the clipboard, into history, and out to the paired devices.
  Future<void> _acceptShared(InboxItem item) async {
    final dir = await saveDir();
    final ts = _nextClipTs();
    ClipPayload payload;
    if (item.kind == ClipKind.files) {
      final files = await _adoptSharedFiles(item, dir);
      if (files.isEmpty) return;
      payload = ClipPayload.files(files, ts: ts, origin: settings.deviceId);
    } else {
      final text = item.text;
      if (text == null || text.isEmpty) return;
      payload = ClipPayload.text(text, ts: ts, origin: settings.deviceId);
    }
    final result = await clipboard.applyRemote(payload, saveDir: dir);
    _addHistory(ClipItem(
      kind: payload.kind,
      text: payload.text,
      fileNames: payload.files.map((f) => f.name).toList(),
      filePaths: result.savedPaths,
      time: DateTime.now(),
      sourceName: settings.deviceName,
      remote: false,
    ));
    if (settings.syncEnabled) await engine.broadcastClip(payload);
  }

  /// Moves shared files out of the extension's container into the save
  /// directory, so they outlive the drop and the container does not grow.
  Future<List<ClipFile>> _adoptSharedFiles(
      InboxItem item, Directory dir) async {
    final adopted = <ClipFile>[];
    await dir.create(recursive: true);
    for (final file in item.files) {
      final target = uniqueFilePath(dir, file.name);
      try {
        await File(file.path!).rename(target);
      } catch (_) {
        // The App Group container is a different volume on some devices, and
        // rename cannot cross one; fall back to copying.
        try {
          await File(file.path!).copy(target);
        } catch (_) {
          continue;
        }
      }
      adopted.add(ClipFile.onDisk(
        name: target.split(Platform.pathSeparator).last,
        path: target,
        size: file.size,
      ));
    }
    final drop = item.dir;
    if (drop != null) {
      try {
        await Directory(drop).delete(recursive: true);
      } catch (_) {}
    }
    return adopted;
  }

  Timer? _widgetTimer;

  /// Refreshes the iOS home screen widget, coalescing bursts of changes.
  void _scheduleWidgetUpdate() {
    if (!Platform.isIOS || !initialized) return;
    _widgetTimer?.cancel();
    _widgetTimer = Timer(const Duration(seconds: 1), () async {
      final l10n = await loadAppLocalizations();
      await IosExtensions.publishState(
        status: settings.syncEnabled
            ? l10n.notificationConnected(
                engine.connectedCount, settings.peers.length)
            : l10n.traySyncIsPaused,
        syncEnabled: settings.syncEnabled,
        recent: [
          for (final item in history.take(4))
            (
              title: item.kind == ClipKind.image
                  ? l10n.imageWithSize(item.formattedImageSize)
                  : item.preview,
              subtitle: item.remote ? item.sourceName : '',
            ),
        ],
      );
    });
  }

  /// Transfers running right now, newest first, for the progress list.
  List<TransferProgress> get activeTransfers =>
      engine.transfers.values.toList();

  /// Failed dials per peer, and when that peer may be tried again.
  ///
  /// A peer that is switched off, or whose stored address now belongs to
  /// somebody else, fails every single time. At a flat five seconds that is a
  /// connect attempt and a five-second timeout forever, on a phone, on
  /// battery — so the interval grows with each failure and collapses back the
  /// moment there is a reason to believe the peer is reachable again (it is
  /// rediscovered, or the app returns to the foreground).
  final Map<String, int> _dialAttempts = {};
  final Map<String, DateTime> _nextDial = {};

  static Duration _dialBackoff(int failures) {
    const base = Duration(seconds: 5);
    const ceiling = Duration(seconds: 60);
    final delay = base * (1 << failures.clamp(0, 4));
    return delay > ceiling ? ceiling : delay;
  }

  void _resetBackoff(String peerId) {
    _dialAttempts.remove(peerId);
    _nextDial.remove(peerId);
  }

  /// Dials every paired-but-disconnected peer without waiting for discovery.
  ///
  /// Runs once at startup and then on a timer. Discovery stays the source of
  /// truth for a peer that moves, but it is not a reliable *retry* signal: UDP
  /// re-announces every few seconds, yet Bonjour resolves a service only once,
  /// so the iOS↔Android link (Bonjour-only, no UDP) would never redial after a
  /// drop. Polling here closes that gap. A currently-discovered address wins
  /// over the persisted one; [SyncEngine.connectTo] no-ops when already
  /// connected or dialling and enforces the deterministic-dialer rule.
  void _reconnectKnownPeers() {
    final now = DateTime.now();
    for (final peer in settings.peers) {
      if (engine.isConnected(peer.id)) {
        _resetBackoff(peer.id);
        continue;
      }
      final due = _nextDial[peer.id];
      if (due != null && now.isBefore(due)) continue;
      final seen = found[peer.id];
      final address = seen?.address ?? peer.lastAddress;
      final port = seen?.info.port ?? peer.lastPort;
      if (address == null || port == null) continue;
      final failures = _dialAttempts[peer.id] ?? 0;
      _dialAttempts[peer.id] = failures + 1;
      _nextDial[peer.id] = now.add(_dialBackoff(failures));
      unawaited(engine.connectTo(peer, [address], port).then((_) {
        if (engine.isConnected(peer.id)) _resetBackoff(peer.id);
      }));
    }
  }

  /// Runs the Android keep-alive service exactly when background sync is on,
  /// and keeps its notification showing the truth. No-op on other platforms.
  ///
  /// The service keeps running while sync is paused: its notification is the
  /// only way back from a pause made through the quick settings tile, and
  /// stopping it would also drop every connection the user is about to resume.
  void _syncForegroundService() => unawaited(_applyForegroundService());

  Future<void> _applyForegroundService() async {
    if (started && settings.backgroundSync) {
      await ForegroundService.start(
        syncEnabled: settings.syncEnabled,
        status: await _serviceStatusText(),
      );
    } else {
      await ForegroundService.stop();
    }
  }

  Future<String?> _serviceStatusText() async {
    if (!initialized) return null;
    final total = settings.peers.length;
    if (total == 0) return null;
    final l10n = await loadAppLocalizations();
    return l10n.notificationConnected(engine.connectedCount, total);
  }

  /// Reacts to a notification button press relayed from the service isolate.
  void _onServiceAction(Object data) {
    switch (data) {
      case notificationActionPause:
        setSyncEnabled(false);
      case notificationActionResume:
        setSyncEnabled(true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && started) {
      // Coming back from suspension means every socket that the OS tore down
      // while we were away is dead. Waiting out a backoff here would leave the
      // app looking disconnected for up to a minute in the very moment the
      // user is watching it, so retry immediately instead.
      _dialAttempts.clear();
      _nextDial.clear();
      _reconnectKnownPeers();
      discovery.announce();
      // The tile may have been tapped while this activity was gone, in which
      // case the in-memory setting is stale.
      unawaited(AndroidControls.syncEnabled().then((tile) {
        if (tile != null && tile != settings.syncEnabled) setSyncEnabled(tile);
      }));
      // Anything shared into Plokee, or asked of it by a Shortcut, while it
      // was in the background.
      unawaited(_drainExtensions());
      // Mobile: the OS only lets us touch the clipboard in the foreground,
      // so check it whenever the user brings the app back.
      if (isMobilePlatform &&
          settings.autoReadOnResume &&
          settings.syncEnabled) {
        clipboard.checkNow();
      }
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
      // Hearing from a peer is the one solid sign it is reachable again, so
      // whatever backoff it had accumulated no longer applies.
      _resetBackoff(info.id);
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

  int _lastClipTs = 0;

  /// A clip timestamp that never repeats.
  ///
  /// `origin:ts` is what tells a receiver a replayed clip from a genuinely new
  /// one, so two clips issued in the same millisecond would make the second
  /// look like a repeat of the first and be dropped. Human copying is never
  /// that fast, but "send clipboard" fired from a Shortcut alongside a share
  /// can be.
  int _nextClipTs() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _lastClipTs = now > _lastClipTs ? now : _lastClipTs + 1;
    return _lastClipTs;
  }

  ClipPayload _payloadFrom(LocalClip clip) {
    final ts = _nextClipTs();
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

  /// A clip arriving from a peer. Replays of an already-applied clip are
  /// filtered out by the engine, which has to reject them before writing
  /// anything to disk.
  Future<void> _onRemoteClip(Peer peer, ClipPayload payload) async {
    if (!settings.syncEnabled) return;
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
    _scheduleWidgetUpdate();
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

  /// Paired devices worth listing: connected now, or at least visible on the
  /// network this moment.
  ///
  /// A peer that is neither is a dead duplicate — most often a device that was
  /// reinstalled (a fresh install gets a new device id, so its old paired
  /// record is orphaned) or simply switched off. Pairing still persists in
  /// storage so it reconnects the instant it returns, but showing it as a
  /// permanent "offline" row just clutters the list with ghosts.
  List<Peer> get visiblePeers => settings.peers
      .where((p) => engine.isConnected(p.id) || found.containsKey(p.id))
      .toList();

  Future<(String, Future<bool>)> startPairing(FoundDevice device) async {
    final result = await engine.requestPairing(device);
    unawaited(result.$2.then((_) => notifyListeners()));
    return result;
  }

  /// Finds a device by a hand-typed [address], for pairing on networks that
  /// hide devices from each other (see [SyncEngine.probeDevice]).
  Future<FoundDevice?> findDeviceAt(String address) =>
      engine.probeDevice(address.trim());

  /// This device's own LAN addresses, best first, to show the user what to
  /// type on the other device. Empty if it has no usable IPv4 address.
  Future<List<String>> localAddresses() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
      return rankLanAddresses(
        interfaces.expand((i) => i.addresses).map((a) => a.address),
      );
    } catch (_) {
      return const [];
    }
  }

  /// Mobile "Send clipboard" button / auto-check on resume.
  /// Returns true if something new was sent.
  Future<bool> sendClipboardNow() async {
    final clip = await clipboard.checkNow();
    return clip != null;
  }

  /// Re-applies a history entry to the clipboard and rebroadcasts it.
  Future<void> copyFromHistory(ClipItem item) async {
    final ts = _nextClipTs();
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
            files.add(ClipFile.onDisk(
              name: file.uri.pathSegments.last,
              path: path,
              size: await file.length(),
            ));
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
    _resetBackoff(peerId);
    notifyListeners();
  }

  /// Replaces what this device syncs with one paired device. Takes effect on
  /// the next clip; nothing in flight is interrupted.
  Future<void> setPeerRules(String peerId, SyncRules rules) async {
    await settings.updatePeerRules(peerId, rules);
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
    FlutterForegroundTask.removeTaskDataCallback(_onServiceAction);
    _pruneTimer?.cancel();
    _reconnectTimer?.cancel();
    _startRetryTimer?.cancel();
    _widgetTimer?.cancel();
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

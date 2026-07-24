import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import 'crypto.dart';
import 'device_name.dart';
import 'models.dart';

/// Persistent identity and paired-device storage.
class SettingsStore {
  static const _kDeviceId = 'device_id';
  static const _kDeviceName = 'device_name';
  static const _kDeviceNameCustom = 'device_name_custom';
  static const _kKeySeed = 'key_seed';
  static const _kPeers = 'peers';
  static const _kSyncEnabled = 'sync_enabled';
  static const _kAutoRead = 'auto_read_on_resume';
  static const _kLastClipSig = 'last_clip_signature';
  static const _kBackgroundSync = 'background_sync';
  static const _kLocale = 'locale_code';

  final SharedPreferences? _prefs;

  late final String deviceId;
  late final Uint8List keySeed;
  String deviceName;
  bool syncEnabled;

  /// Mobile: read the clipboard automatically when the app returns to the
  /// foreground (on iOS this may show the system paste banner).
  bool autoReadOnResume;

  /// Android: run a keep-alive foreground service so sync survives the app
  /// being backgrounded. Shows a persistent notification; users can opt out.
  bool backgroundSync;

  /// Signature of the last clip we saw locally or applied from a peer.
  /// Persisted so a restart (e.g. Android killing the app in the background)
  /// doesn't mistake an already-synced clipboard for a fresh local copy and
  /// re-broadcast it.
  String? lastClipSignature;

  /// Language chosen in Settings, e.g. 'ru' or 'zh_Hant'.
  /// Null means follow the system language.
  String? localeCode;

  final List<Peer> peers = [];

  /// iOS shows a system paste banner on every unprompted clipboard read,
  /// so auto-read defaults to off there; elsewhere it is silent and safe.
  static bool get _autoReadDefault => !Platform.isIOS;

  SettingsStore._(this._prefs)
      : deviceName = '',
        syncEnabled = true,
        autoReadOnResume = _autoReadDefault,
        backgroundSync = true;

  /// Non-persistent store for tests and headless tooling.
  factory SettingsStore.inMemory({
    required String deviceId,
    required String deviceName,
  }) {
    final store = SettingsStore._(null);
    store.deviceId = deviceId;
    store.keySeed = CryptoService.randomSeed();
    store.deviceName = deviceName;
    return store;
  }

  static Future<SettingsStore> load() async {
    final prefs = await SharedPreferences.getInstance();
    final store = SettingsStore._(prefs);

    var id = prefs.getString(_kDeviceId);
    if (id == null) {
      final rng = Random.secure();
      id = List.generate(16, (_) => rng.nextInt(16).toRadixString(16)).join();
      await prefs.setString(_kDeviceId, id);
    }
    store.deviceId = id;

    var seed = prefs.getString(_kKeySeed);
    if (seed == null) {
      seed = base64Encode(CryptoService.randomSeed());
      await prefs.setString(_kKeySeed, seed);
    }
    store.keySeed = base64Decode(seed);

    // Use the OS-provided device name unless the user set one explicitly.
    // This also re-derives the name for existing installs that were seeded
    // with a plain (often duplicate) hostname before this was added.
    final savedName = prefs.getString(_kDeviceName);
    final nameIsCustom = prefs.getBool(_kDeviceNameCustom) ?? false;
    if (savedName != null && nameIsCustom) {
      store.deviceName = savedName;
    } else {
      store.deviceName = await defaultDeviceName();
      await prefs.setString(_kDeviceName, store.deviceName);
    }

    store.syncEnabled = prefs.getBool(_kSyncEnabled) ?? true;
    store.autoReadOnResume = prefs.getBool(_kAutoRead) ?? _autoReadDefault;
    store.backgroundSync = prefs.getBool(_kBackgroundSync) ?? true;
    store.lastClipSignature = prefs.getString(_kLastClipSig);
    store.localeCode = prefs.getString(_kLocale);

    final peersJson = prefs.getString(_kPeers);
    if (peersJson != null) {
      final list = jsonDecode(peersJson) as List<dynamic>;
      store.peers.addAll(
          list.map((e) => Peer.fromJson(e as Map<String, dynamic>)));
    }
    return store;
  }

  Future<void> setDeviceName(String name) async {
    deviceName = name;
    await _prefs?.setString(_kDeviceName, name);
    await _prefs?.setBool(_kDeviceNameCustom, true);
  }

  Future<void> setSyncEnabled(bool enabled) async {
    syncEnabled = enabled;
    await _prefs?.setBool(_kSyncEnabled, enabled);
  }

  Future<void> setAutoReadOnResume(bool enabled) async {
    autoReadOnResume = enabled;
    await _prefs?.setBool(_kAutoRead, enabled);
  }

  Future<void> setBackgroundSync(bool enabled) async {
    backgroundSync = enabled;
    await _prefs?.setBool(_kBackgroundSync, enabled);
  }

  Future<void> setLocaleCode(String? code) async {
    localeCode = code;
    if (code == null) {
      await _prefs?.remove(_kLocale);
    } else {
      await _prefs?.setString(_kLocale, code);
    }
  }

  Future<void> setLastClipSignature(String signature) async {
    lastClipSignature = signature;
    await _prefs?.setString(_kLastClipSig, signature);
  }

  Peer? peerById(String id) {
    for (final p in peers) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> addPeer(Peer peer) async {
    peers.removeWhere((p) => p.id == peer.id);
    peers.add(peer);
    await _savePeers();
  }

  /// Keeps a paired device's display name in sync with the name it now
  /// advertises. Returns true if anything changed.
  Future<bool> updatePeerName(String id, String name) async {
    final trimmed = name.trim();
    final peer = peerById(id);
    if (peer == null || trimmed.isEmpty || peer.name == trimmed) return false;
    peer.name = trimmed;
    await _savePeers();
    return true;
  }

  /// Remembers where a peer was last reached, for reconnecting without
  /// discovery. Writes only on change to avoid churning shared_preferences.
  Future<void> updatePeerAddress(String id, String address, int port) async {
    final peer = peerById(id);
    if (peer == null) return;
    if (peer.lastAddress == address && peer.lastPort == port) return;
    peer.lastAddress = address;
    peer.lastPort = port;
    await _savePeers();
  }

  Future<void> removePeer(String id) async {
    peers.removeWhere((p) => p.id == id);
    await _savePeers();
  }

  Future<void> _savePeers() async => _prefs?.setString(
      _kPeers, jsonEncode(peers.map((p) => p.toJson()).toList()));
}

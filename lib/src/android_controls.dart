import 'dart:io';

import 'package:flutter/services.dart';

/// The Android quick settings tile, seen from Dart.
///
/// The tile deliberately does not talk to the running app to decide anything —
/// it flips the same stored preference the app reads, so the two agree whether
/// or not a process is alive. This channel exists only so that a *running* app
/// finds out at the moment of the tap instead of at its next read.
class AndroidControls {
  static const MethodChannel _channel =
      MethodChannel('com.kvlkstudio.plokee/tile');

  static bool get _supported => Platform.isAndroid;

  /// Calls [onSyncChanged] when the tile toggles sync. No-op elsewhere.
  static void listen({required void Function(bool enabled) onSyncChanged}) {
    if (!_supported) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'syncChanged') {
        onSyncChanged(call.arguments as bool? ?? true);
      }
      return null;
    });
  }

  /// The value the tile would show right now, read from native storage.
  ///
  /// Used on resume: if the tile was tapped while the activity was gone, the
  /// in-memory copy of the setting is stale and this is what corrects it.
  static Future<bool?> syncEnabled() async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<bool>('isSyncEnabled');
    } catch (_) {
      // Older build without the channel.
      return null;
    }
  }
}

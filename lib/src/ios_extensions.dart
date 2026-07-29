import 'dart:io';

import 'package:flutter/services.dart';

import 'models.dart';

/// Something handed to Plokee from outside the app: the Share sheet, or a
/// Shortcut asking for an action.
class InboxItem {
  final ClipKind kind;
  final String? text;
  final List<ClipFile> files;

  /// Container directory holding [files], to be cleaned up once they are
  /// somewhere safer.
  final String? dir;

  InboxItem({required this.kind, this.text, this.files = const [], this.dir});
}

/// A request left by a Shortcut while the app was not running.
enum ShortcutCommand { sendClipboard, enableSync, disableSync }

/// The iOS Share Extension, Shortcuts and the widget, seen from Dart.
///
/// Extensions run in their own processes and cannot call into the app, so
/// everything crosses through files in the shared App Group container: the
/// extension writes, the app reads on launch and on every return to the
/// foreground. See `ios/Runner/PlokeeBridge.swift`.
class IosExtensions {
  static const MethodChannel _channel =
      MethodChannel('com.kvlkstudio.plokee/extensions');

  static bool get _supported => Platform.isIOS;

  /// Everything the Share sheet has dropped since the last call. The inbox is
  /// emptied by the read, so each item is returned exactly once.
  static Future<List<InboxItem>> drainInbox() async {
    if (!_supported) return const [];
    try {
      final raw = await _channel.invokeListMethod<Object?>('drainInbox');
      return [
        for (final entry in raw ?? const []) ?_parseItem(entry),
      ];
    } catch (_) {
      return const [];
    }
  }

  static InboxItem? _parseItem(Object? entry) {
    if (entry is! Map) return null;
    final map = entry.cast<Object?, Object?>();
    final paths = (map['paths'] as List<Object?>? ?? const [])
        .whereType<String>()
        .toList();
    if (paths.isNotEmpty) {
      final files = <ClipFile>[];
      for (final path in paths) {
        final file = File(path);
        if (!file.existsSync()) continue;
        files.add(ClipFile.onDisk(
          name: file.uri.pathSegments.last,
          path: path,
          size: file.lengthSync(),
        ));
      }
      if (files.isEmpty) return null;
      return InboxItem(
          kind: ClipKind.files, files: files, dir: map['dir'] as String?);
    }
    final text = map['text'] as String?;
    if (text == null || text.isEmpty) return null;
    return InboxItem(kind: ClipKind.text, text: text);
  }

  /// Requests left by Shortcuts, oldest first. Cleared by the read.
  static Future<List<ShortcutCommand>> takeCommands() async {
    if (!_supported) return const [];
    try {
      final raw = await _channel.invokeListMethod<Object?>('takeCommands');
      return [
        for (final entry in raw ?? const [])
          if (entry is Map) ?_parseCommand(entry.cast<Object?, Object?>()),
      ];
    } catch (_) {
      return const [];
    }
  }

  static ShortcutCommand? _parseCommand(Map<Object?, Object?> map) =>
      switch (map['command']) {
        'sendClipboard' => ShortcutCommand.sendClipboard,
        'setSync' => map['enabled'] == false
            ? ShortcutCommand.disableSync
            : ShortcutCommand.enableSync,
        _ => null,
      };

  /// Publishes what the home screen widget shows. Strings arrive already
  /// translated: the app owns the translations, the widget only renders.
  static Future<void> publishState({
    required String status,
    required bool syncEnabled,
    required List<({String title, String subtitle})> recent,
  }) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod<void>('publishState', {
        'status': status,
        'syncEnabled': syncEnabled,
        'recent': [
          for (final clip in recent)
            {'title': clip.title, 'subtitle': clip.subtitle},
        ],
      });
    } catch (_) {
      // Older build without the channel, or no App Group entitlement.
    }
  }
}

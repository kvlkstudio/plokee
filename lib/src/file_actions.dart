import 'dart:io';

import 'package:flutter/services.dart';

/// Desktop-only helpers for handing a saved clip over to the OS.

/// macOS reveals through the host app (NSWorkspace), not a spawned process.
const MethodChannel _macChannel = MethodChannel(
  'com.kvlkstudio.plokee/file_actions',
);

/// Whether [revealInFileManager] can do anything on this platform.
bool get canRevealInFileManager =>
    Platform.isMacOS || Platform.isWindows || Platform.isLinux;

/// Shows [path] in the platform file manager, selecting the file where the
/// platform supports it. Returns false if the platform has no file manager to
/// talk to or the call failed.
Future<bool> revealInFileManager(String path) async {
  try {
    if (Platform.isMacOS) {
      // NSWorkspace.activateFileViewerSelecting: works under App Sandbox and
      // avoids spawning a helper binary, which App Review dislikes.
      final revealed = await _macChannel.invokeMethod<bool>(
        'revealInFinder',
        path,
      );
      return revealed ?? false;
    }
    if (Platform.isWindows) {
      // explorer.exe exits with 1 even when it opened the window, so the exit
      // code says nothing useful here.
      await Process.run('explorer', ['/select,$path']);
      return true;
    }
    if (Platform.isLinux) {
      // No portable "select this file", so open the containing folder.
      final result = await Process.run('xdg-open', [File(path).parent.path]);
      return result.exitCode == 0;
    }
  } catch (_) {
    // Missing binary or a sandbox denial: fall through to the failure toast.
  }
  return false;
}

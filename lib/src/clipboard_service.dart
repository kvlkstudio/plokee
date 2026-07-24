import 'dart:async';
import 'dart:io';

import 'package:clipboard_watcher/clipboard_watcher.dart';
import 'package:flutter/services.dart';
import 'package:pasteboard/pasteboard.dart';

import 'models.dart';

/// What was read from the local clipboard.
class LocalClip {
  final ClipKind kind;
  final String? text;
  final Uint8List? image;
  final List<ClipFile> files;
  final List<String> sourcePaths;

  LocalClip.text(this.text)
      : kind = ClipKind.text,
        image = null,
        files = const [],
        sourcePaths = const [];

  LocalClip.image(this.image)
      : kind = ClipKind.image,
        text = null,
        files = const [],
        sourcePaths = const [];

  LocalClip.files(this.files, this.sourcePaths)
      : kind = ClipKind.files,
        text = null,
        image = null;

  String get signature => switch (kind) {
        ClipKind.text => 't:${text.hashCode}:${text!.length}',
        ClipKind.image =>
          'i:${Object.hashAll(image!.take(64))}:${image!.length}',
        ClipKind.files =>
          'f:${files.map((f) => '${f.name}:${f.bytes.length}').join(',')}',
      };
}

/// Result of applying a remote clip to the local clipboard.
class ApplyResult {
  final bool appliedToClipboard;
  final List<String> savedPaths;

  ApplyResult({required this.appliedToClipboard, this.savedPaths = const []});
}

/// Watches the system clipboard (desktop) and reads/writes rich content.
///
/// On mobile there is no watcher — the OS only allows clipboard access in
/// the foreground — so [checkNow] is called on app resume or manually.
class ClipboardService with ClipboardListener {
  final void Function(LocalClip clip) onLocalClip;

  /// Called whenever the last-seen signature changes, so it can be persisted
  /// and survive an app restart (see [SettingsStore.lastClipSignature]).
  final void Function(String signature)? onSignatureChanged;

  String? _lastSignature;

  ClipboardService({
    required this.onLocalClip,
    String? initialSignature,
    this.onSignatureChanged,
  }) : _lastSignature = initialSignature;

  /// Updates the echo-suppression signature and persists it.
  void _setSignature(String? signature) {
    _lastSignature = signature;
    if (signature != null) onSignatureChanged?.call(signature);
  }

  bool get _watcherSupported =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  Future<void> start() async {
    if (_watcherSupported) {
      // Remember what's already on the clipboard so we don't rebroadcast it.
      // Skipped on mobile: an unprompted read at launch would trigger the
      // iOS paste-permission banner — there we rely on the persisted
      // signature restored via the constructor instead.
      final initial = await _read();
      if (initial != null) _setSignature(initial.signature);
      clipboardWatcher.addListener(this);
      await clipboardWatcher.start();
    }
  }

  Future<void> stop() async {
    _debounce?.cancel();
    if (_watcherSupported) {
      clipboardWatcher.removeListener(this);
      await clipboardWatcher.stop();
    }
  }

  Timer? _debounce;

  @override
  void onClipboardChanged() {
    // Writers often populate the pasteboard in several steps (e.g. TIFF
    // first, PNG after); reading mid-write yields partial duplicates.
    // Wait for the burst to settle before reading.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), checkNow);
  }

  /// Reads the clipboard and fires [onLocalClip] if the content is new.
  /// Returns the clip when something new was found.
  Future<LocalClip?> checkNow() async {
    final clip = await _read();
    if (clip == null) return null;
    final sig = clip.signature;
    if (sig == _lastSignature) return null;
    _setSignature(sig);
    onLocalClip(clip);
    return clip;
  }

  /// Priority: files (desktop) > image > text.
  Future<LocalClip?> _read() async {
    if (!isMobilePlatform) {
      try {
        final paths = await Pasteboard.files();
        if (paths.isNotEmpty) {
          final files = <ClipFile>[];
          var total = 0;
          for (final path in paths) {
            final file = File(path);
            if (!await file.exists()) continue; // directories are skipped
            final length = await file.length();
            total += length;
            if (length > maxClipBytes || total > maxClipBytes) return null;
            files.add(ClipFile(
              name: file.uri.pathSegments.last,
              bytes: await file.readAsBytes(),
            ));
          }
          if (files.isNotEmpty) return LocalClip.files(files, paths);
        }
      } catch (_) {}
    }
    try {
      final image = await Pasteboard.image;
      if (image != null && image.isNotEmpty && image.length <= maxClipBytes) {
        return LocalClip.image(image);
      }
    } catch (_) {}
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text != null && text.isNotEmpty) return LocalClip.text(text);
    return null;
  }

  /// Writes a remote clip to the local clipboard without echoing it back.
  /// Files are saved into [saveDir] first; on desktop the saved files are
  /// also placed on the clipboard, on mobile they stay in history.
  Future<ApplyResult> applyRemote(ClipPayload payload,
      {required Directory saveDir}) async {
    // Provisional: covers the instant between the write and the read-back.
    _setSignature(payload.signature);
    try {
      switch (payload.kind) {
        case ClipKind.text:
          await Clipboard.setData(ClipboardData(text: payload.text!));
          return ApplyResult(appliedToClipboard: true);
        case ClipKind.image:
          try {
            await Pasteboard.writeImage(payload.imageBytes!);
            return ApplyResult(appliedToClipboard: true);
          } catch (_) {
            return ApplyResult(appliedToClipboard: false); // e.g. Linux
          }
        case ClipKind.files:
          final saved = <String>[];
          await saveDir.create(recursive: true);
          for (final f in payload.files) {
            final path = _uniquePath(saveDir, f.name);
            await File(path).writeAsBytes(f.bytes);
            saved.add(path);
          }
          var applied = false;
          if (!isMobilePlatform) {
            try {
              applied = await Pasteboard.writeFiles(saved);
            } catch (_) {}
          }
          return ApplyResult(appliedToClipboard: applied, savedPaths: saved);
      }
    } finally {
      await _resyncSignature();
    }
  }

  /// Replaces the echo-suppression signature with one computed from what is
  /// *actually* on the clipboard now.
  ///
  /// The payload's own signature only matches for text. A pasteboard re-encodes
  /// an image on the way in — a 40 KB PNG reads back as 45 KB — and files land
  /// under a different name when [_uniquePath] has to dodge a collision. So the
  /// signature of what we sent never equals the signature of what we can read,
  /// [checkNow] sees the applied clip as a fresh local copy, and rebroadcasts
  /// it. With three devices that ping-pongs forever, each hop re-encoding the
  /// image again.
  ///
  /// Every platform's clipboard write is synchronous, so reading straight back
  /// returns the final bytes — and the watcher's debounce means this lands
  /// before [checkNow] runs.
  ///
  /// Safe on iOS despite [start] avoiding an unprompted read: the paste banner
  /// only guards content put there by *another* app, and this reads back what
  /// we just wrote ourselves.
  Future<void> _resyncSignature() async {
    try {
      final actual = await _read();
      if (actual != null) _setSignature(actual.signature);
    } catch (_) {
      // Read failed: keep the provisional signature rather than none.
    }
  }

  /// Puts already-saved files back on the clipboard (desktop) without
  /// saving them again.
  Future<bool> reapplyFiles(List<String> paths, String signature) async {
    _setSignature(signature);
    if (isMobilePlatform) return false;
    try {
      return await Pasteboard.writeFiles(paths);
    } catch (_) {
      return false;
    }
  }

  String _uniquePath(Directory dir, String name) {
    var candidate = '${dir.path}${Platform.pathSeparator}$name';
    var i = 1;
    while (File(candidate).existsSync()) {
      final dot = name.lastIndexOf('.');
      final stem = dot > 0 ? name.substring(0, dot) : name;
      final ext = dot > 0 ? name.substring(dot) : '';
      candidate = '${dir.path}${Platform.pathSeparator}$stem ($i)$ext';
      i++;
    }
    return candidate;
  }
}

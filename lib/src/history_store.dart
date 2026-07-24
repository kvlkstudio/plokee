import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'models.dart';

/// Persists the clipboard history so it survives app restarts (notably on
/// Android, where the OS kills the app in the background).
///
/// Layout under [baseDir]:
///   history.json        — ordered metadata for every entry
///   history_images/     — one PNG per image entry, referenced by path
///
/// Image bytes live in files rather than the JSON so the index stays small.
class HistoryStore {
  final Directory baseDir;

  HistoryStore(this.baseDir);

  String get _sep => Platform.pathSeparator;
  File get _indexFile => File('${baseDir.path}${_sep}history.json');
  Directory get _imagesDir => Directory('${baseDir.path}${_sep}history_images');

  /// The name an image is stored under, with any directory part dropped.
  ///
  /// Images are referenced by name on disk, never by absolute path: a
  /// sandboxed container is not at a fixed location. iOS rebuilds the path on
  /// reinstall (`…/Containers/Data/Application/<new UUID>/…`), so a path
  /// written yesterday points at nothing today and *every* image in the
  /// history reads back as missing. A name resolved against the current
  /// directory survives that.
  String _imageName(String path) => path.split(_sep).last;

  /// Turns a stored reference back into a path in the container we're in now,
  /// tolerating absolute paths written by older versions.
  String _resolveImage(String stored) =>
      '${_imagesDir.path}$_sep${_imageName(stored)}';

  Future<List<ClipItem>> load() async {
    try {
      if (!await _indexFile.exists()) return [];
      final list = jsonDecode(await _indexFile.readAsString()) as List<dynamic>;
      final items = <ClipItem>[];
      for (final entry in list) {
        final map = entry as Map<String, dynamic>;
        Uint8List? bytes;
        final stored = map['imagePath'] as String?;
        if (stored != null) {
          final path = _resolveImage(stored);
          map['imagePath'] = path;
          final file = File(path);
          if (await file.exists()) bytes = await file.readAsBytes();
        }
        final item = ClipItem.tryFromJson(map, imageBytes: bytes);
        if (item != null) items.add(item);
      }
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<ClipItem> items) async {
    try {
      await baseDir.create(recursive: true);
      final json = jsonEncode([
        for (final item in items) _withRelativeImage(item.toJson()),
      ]);
      // Write atomically so a crash mid-write can't corrupt the index.
      final tmp = File('${_indexFile.path}.tmp');
      await tmp.writeAsString(json);
      await tmp.rename(_indexFile.path);
      await _pruneImages(items);
    } catch (_) {
      // History persistence is best-effort; never break the app over it.
    }
  }

  /// Writes an image to the images directory and returns its path.
  Future<String?> persistImage(Uint8List bytes, int timestamp) async {
    try {
      await _imagesDir.create(recursive: true);
      final path = '${_imagesDir.path}${_sep}img_$timestamp.png';
      await File(path).writeAsBytes(bytes);
      return path;
    } catch (_) {
      return null;
    }
  }

  /// Stores the image reference as a bare name — see [_imageName].
  Map<String, dynamic> _withRelativeImage(Map<String, dynamic> map) {
    final path = map['imagePath'] as String?;
    if (path == null) return map;
    return {...map, 'imagePath': _imageName(path)};
  }

  /// How long a freshly written image is protected from pruning.
  ///
  /// The file is written before the entry referencing it is saved, so a save
  /// triggered by *another* clip in that window would otherwise see a live
  /// image as an orphan and delete it.
  static const Duration _pruneGrace = Duration(minutes: 1);

  /// Deletes image files no longer referenced by any history entry.
  Future<void> _pruneImages(List<ClipItem> items) async {
    try {
      if (!await _imagesDir.exists()) return;
      final keep = items
          .map((i) => i.imagePath)
          .whereType<String>()
          .map(_imageName)
          .toSet();
      final now = DateTime.now();
      await for (final entity in _imagesDir.list()) {
        if (entity is! File) continue;
        if (keep.contains(_imageName(entity.path))) continue;
        if (now.difference(await entity.lastModified()) < _pruneGrace) continue;
        await entity.delete();
      }
    } catch (_) {}
  }

  Future<void> clear() async {
    try {
      if (await _indexFile.exists()) await _indexFile.delete();
      if (await _imagesDir.exists()) {
        await _imagesDir.delete(recursive: true);
      }
    } catch (_) {}
  }
}

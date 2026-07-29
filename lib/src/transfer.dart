import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'crypto.dart';
import 'models.dart';

/// Chunked clipboard transfers.
///
/// The one-frame path encodes a whole clip as base64 inside a JSON message,
/// which costs several times the payload in heap and put a hard ceiling on
/// what could be synced. Anything above [inlineClipBytes] takes this path
/// instead: a manifest, then the bytes as encrypted binary WebSocket frames
/// read straight off disk and written straight back to disk on the other side.
/// Nothing is ever held whole in memory, so file size stops being a limit.
///
/// Every chunk is sealed with the pairing secret exactly like a one-frame
/// clip, and its position travels *inside* the sealed part, so a reordered or
/// replayed frame is rejected rather than silently corrupting the file.

/// Bytes per chunk. Large enough that per-chunk crypto overhead disappears,
/// small enough that a stalled peer cannot pin much memory.
const int transferChunkBytes = 256 * 1024;

/// Binary frame kinds.
const int frameChunk = 0x01;

/// Header inside the sealed chunk: item index (u32) + offset (u64).
const int _chunkHeaderBytes = 12;

/// One file (or the single text/image blob) inside a transfer.
class TransferItem {
  final String name;
  final int size;

  const TransferItem({required this.name, required this.size});

  Map<String, dynamic> toJson() => {'name': name, 'size': size};

  static TransferItem? tryParse(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final name = json['name'];
    final size = json['size'];
    if (name is! String || size is! int || size < 0) return null;
    return TransferItem(name: name, size: size);
  }
}

/// What a streamed clip announces before its bytes start arriving.
class ClipManifest {
  final String id;
  final ClipKind kind;
  final int ts;
  final String origin;
  final List<TransferItem> items;

  const ClipManifest({
    required this.id,
    required this.kind,
    required this.ts,
    required this.origin,
    required this.items,
  });

  /// Describes [payload] without reading any of its contents.
  factory ClipManifest.of(ClipPayload payload, String id) => ClipManifest(
        id: id,
        kind: payload.kind,
        ts: payload.ts,
        origin: payload.origin,
        items: switch (payload.kind) {
          ClipKind.text => [
              TransferItem(name: '', size: utf8.encode(payload.text!).length),
            ],
          ClipKind.image => [
              TransferItem(name: '', size: payload.imageBytes!.length),
            ],
          ClipKind.files => [
              for (final f in payload.files)
                TransferItem(name: f.name, size: f.size),
            ],
        },
      );

  int get totalBytes => items.fold(0, (sum, i) => sum + i.size);

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'ts': ts,
        'origin': origin,
        'items': [for (final i in items) i.toJson()],
      };

  static ClipManifest? tryParse(Map<String, dynamic> json) {
    final kind =
        ClipKind.values.where((k) => k.name == json['kind']).firstOrNull;
    final id = json['id'];
    final ts = json['ts'];
    final origin = json['origin'];
    final rawItems = json['items'];
    if (kind == null || id is! String || ts is! int || origin is! String) {
      return null;
    }
    if (rawItems is! List || rawItems.isEmpty) return null;
    final items = <TransferItem>[];
    for (final raw in rawItems) {
      final item = TransferItem.tryParse(raw);
      if (item == null) return null;
      items.add(item);
    }
    // text and image are one blob by definition; a peer claiming otherwise is
    // either broken or trying something.
    if (kind != ClipKind.files && items.length != 1) return null;
    return ClipManifest(
        id: id, kind: kind, ts: ts, origin: origin, items: items);
  }
}

/// Live progress of one transfer, for the UI.
class TransferProgress {
  final String id;
  final String peerId;
  final String peerName;
  final bool incoming;
  final ClipKind kind;

  /// File name, or empty for text and images — the UI names those from [kind]
  /// so the label stays translated.
  final String label;
  final int total;
  int done;

  TransferProgress({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.incoming,
    required this.kind,
    required this.label,
    required this.total,
    this.done = 0,
  });

  factory TransferProgress.of(
    ClipManifest manifest, {
    required String peerId,
    required String peerName,
    required bool incoming,
  }) =>
      TransferProgress(
        id: manifest.id,
        peerId: peerId,
        peerName: peerName,
        incoming: incoming,
        kind: manifest.kind,
        label: manifest.kind != ClipKind.files
            ? ''
            : (manifest.items.length == 1
                ? manifest.items.first.name
                : '${manifest.items.first.name} +${manifest.items.length - 1}'),
        total: manifest.totalBytes,
      );

  double get fraction => total <= 0 ? 0 : (done / total).clamp(0.0, 1.0);
}

/// A decoded chunk frame.
class ChunkFrame {
  final int itemIndex;
  final int offset;
  final Uint8List data;

  const ChunkFrame(this.itemIndex, this.offset, this.data);
}

/// Seals [data] together with its position into one binary frame.
Future<Uint8List> encodeChunkFrame(
  Uint8List secret,
  int itemIndex,
  int offset,
  List<int> data,
) async {
  final body = Uint8List(_chunkHeaderBytes + data.length);
  final view = ByteData.sublistView(body);
  view.setUint32(0, itemIndex, Endian.big);
  view.setUint64(4, offset, Endian.big);
  body.setRange(_chunkHeaderBytes, body.length, data);
  final box = await CryptoService.encryptBytes(secret, body);
  final frame = Uint8List(1 + box.length);
  frame[0] = frameChunk;
  frame.setRange(1, frame.length, box);
  return frame;
}

/// Inverse of [encodeChunkFrame]. Returns null for anything that is not a
/// well-formed, correctly sealed chunk.
Future<ChunkFrame?> decodeChunkFrame(Uint8List secret, Uint8List frame) async {
  if (frame.isEmpty || frame[0] != frameChunk) return null;
  try {
    final body = await CryptoService.decryptBytes(
        secret, Uint8List.sublistView(frame, 1));
    if (body.length < _chunkHeaderBytes) return null;
    final view = ByteData.sublistView(body);
    return ChunkFrame(
      view.getUint32(0, Endian.big),
      view.getUint64(4, Endian.big),
      Uint8List.sublistView(body, _chunkHeaderBytes),
    );
  } catch (_) {
    return null;
  }
}

/// Strips everything that could make a peer-supplied name escape the download
/// directory or collide with a hidden file.
///
/// Names arrive from a paired device, which is trusted to sync clipboards —
/// not to choose where this machine writes. `../../.ssh/authorized_keys` has to
/// come out as a plain file name in the target directory and nothing else.
String sanitizeFileName(String name) {
  var cleaned = name.replaceAll(RegExp(r'[\\/\x00-\x1f]'), '_').trim();
  // Windows reserves these characters outright; keeping them would make the
  // write fail there and succeed elsewhere.
  cleaned = cleaned.replaceAll(RegExp(r'[<>:"|?*]'), '_');
  while (cleaned.startsWith('.')) {
    cleaned = cleaned.substring(1);
  }
  cleaned = cleaned.replaceAll(RegExp(r'[. ]+$'), '');
  if (cleaned.isEmpty) cleaned = 'file';
  // Leave room for the " (12)" a collision may append, and for the filesystem's
  // own 255-byte ceiling.
  if (cleaned.length > 200) cleaned = cleaned.substring(0, 200);
  return cleaned;
}

/// A free path for [name] in [dir], dodging existing files.
String uniqueFilePath(Directory dir, String name) {
  final safe = sanitizeFileName(name);
  var candidate = '${dir.path}${Platform.pathSeparator}$safe';
  var i = 1;
  while (File(candidate).existsSync()) {
    final dot = safe.lastIndexOf('.');
    final stem = dot > 0 ? safe.substring(0, dot) : safe;
    final ext = dot > 0 ? safe.substring(dot) : '';
    candidate = '${dir.path}${Platform.pathSeparator}$stem ($i)$ext';
    i++;
  }
  return candidate;
}

/// Assembles an incoming streamed clip, writing each item to disk as it
/// arrives so nothing accumulates in memory.
class InboundTransfer {
  final ClipManifest manifest;

  /// Where completed files land. Partial writes live here too, under a dotted
  /// name, so finishing one is a rename within the same filesystem.
  final Directory dir;

  final _partPaths = <String>[];
  IOSink? _sink;
  int _itemIndex = 0;
  int _itemBytes = 0;
  int _sinceFlush = 0;
  int received = 0;
  bool _failed = false;
  bool _started = false;

  /// Bytes buffered towards the disk before waiting for it to catch up. The
  /// network subscription stays paused across that wait, so a slow disk slows
  /// the sender down instead of filling memory.
  static const int _flushEveryBytes = 1024 * 1024;

  InboundTransfer({required this.manifest, required this.dir});

  bool get failed => _failed;

  String _partPath(int index) =>
      '${dir.path}${Platform.pathSeparator}.plokee-${manifest.id}-$index.part';

  /// Accepts one chunk. Returns false once the transfer is unusable, at which
  /// point the caller should [abort] it.
  Future<bool> accept(ChunkFrame chunk) async {
    if (_failed) return false;
    try {
      await _skipEmptyItems();
      if (_itemIndex >= manifest.items.length) return _fail();
      if (chunk.itemIndex != _itemIndex || chunk.offset != _itemBytes) {
        // Out of order or replayed: the stream is one sequential pass per item
        // in manifest order, so this can only mean the transfer is broken.
        return _fail();
      }
      final expected = manifest.items[_itemIndex].size;
      if (_itemBytes + chunk.data.length > expected) return _fail();

      _sink ??= _openPart(_itemIndex);
      _sink!.add(chunk.data);
      _itemBytes += chunk.data.length;
      _sinceFlush += chunk.data.length;
      received += chunk.data.length;

      if (_itemBytes == expected) {
        await _closeSink();
        _itemIndex++;
        _itemBytes = 0;
      } else if (_sinceFlush >= _flushEveryBytes) {
        _sinceFlush = 0;
        await _sink!.flush();
      }
      return true;
    } catch (_) {
      // Disk full, permission denied, target directory vanished.
      return _fail();
    }
  }

  /// Opens (and registers) the partial file for [index].
  IOSink _openPart(int index) {
    if (!_started) {
      dir.createSync(recursive: true);
      _started = true;
    }
    final path = _partPath(index);
    if (!_partPaths.contains(path)) _partPaths.add(path);
    _sinceFlush = 0;
    return File(path).openWrite();
  }

  /// Walks past items that carry no bytes: nothing will ever arrive for them,
  /// so they have to be created and stepped over here or the transfer stalls
  /// on the first empty file.
  Future<void> _skipEmptyItems() async {
    while (_itemIndex < manifest.items.length &&
        manifest.items[_itemIndex].size == 0 &&
        _itemBytes == 0) {
      await _openPart(_itemIndex).close();
      _itemIndex++;
    }
  }

  bool _fail() {
    _failed = true;
    return false;
  }

  Future<void> _closeSink() async {
    final sink = _sink;
    _sink = null;
    if (sink == null) return;
    await sink.flush();
    await sink.close();
  }

  /// Turns the finished parts into a payload. Returns null if the sender
  /// stopped short or anything failed on the way.
  Future<ClipPayload?> finish() async {
    if (_failed) return null;
    await _closeSink();
    await _skipEmptyItems();
    if (_itemIndex != manifest.items.length || _itemBytes != 0) return null;
    try {
      switch (manifest.kind) {
        case ClipKind.text:
          final bytes = await _itemBytesAt(0);
          return ClipPayload.text(utf8.decode(bytes),
              ts: manifest.ts, origin: manifest.origin);
        case ClipKind.image:
          final bytes = await _itemBytesAt(0);
          return ClipPayload.image(bytes,
              ts: manifest.ts, origin: manifest.origin);
        case ClipKind.files:
          final files = <ClipFile>[];
          for (var i = 0; i < manifest.items.length; i++) {
            final item = manifest.items[i];
            final target = uniqueFilePath(dir, item.name);
            await _partFile(i).rename(target);
            files.add(ClipFile.onDisk(
              name: target.split(Platform.pathSeparator).last,
              path: target,
              size: item.size,
            ));
          }
          _partPaths.clear();
          return ClipPayload.files(files,
              ts: manifest.ts, origin: manifest.origin);
      }
    } catch (_) {
      return null;
    } finally {
      // Anything the switch did not consume (a failed rename halfway through,
      // the temp file behind a text clip) must not be left behind.
      await abort();
    }
  }

  File _partFile(int index) => File(_partPath(index));

  Future<Uint8List> _itemBytesAt(int index) => _partFile(index).readAsBytes();

  /// Drops every partial file. Safe to call more than once.
  Future<void> abort() async {
    await _closeSink();
    for (final path in _partPaths) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Best effort: a leftover dotfile is better than a crash.
      }
    }
    _partPaths.clear();
  }
}

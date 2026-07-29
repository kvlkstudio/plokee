import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Protocol version. Bump on breaking changes.
const int protocolVersion = 1;
const String appId = 'plokee';

/// Clips at or below this size travel as a single JSON frame.
///
/// Anything bigger is streamed chunk by chunk instead (see `transfer.dart`),
/// which is what lets a file of any size sync without ever being held in
/// memory whole. Small clips — which is nearly all text — keep the cheaper
/// one-frame path.
const int inlineClipBytes = 256 * 1024;

/// Ceiling for the one-frame path when talking to a peer too old to stream.
///
/// Such a peer buffers the whole base64 payload in memory, so this stays at
/// the limit that shipped with it; larger clips are simply not sent to that
/// device. Peers that advertise [capStream] have no size limit at all.
const int legacyMaxClipBytes = 32 * 1024 * 1024;

/// Capability advertised in the WebSocket handshake by peers that understand
/// chunked transfers.
const String capStream = 'stream1';

/// How long a clip stays worth replaying to a peer that connects late.
///
/// A phone is disconnected whenever it is in a pocket — on iOS the OS suspends
/// the app outright — so a clip copied meanwhile never reaches it. Handing the
/// newest one over on connect is the closest thing to background sync those
/// platforms allow. Older than this it is left alone: overwriting what the
/// user copied on the phone itself, long after the fact, would be worse than
/// missing the sync.
const Duration clipReplayWindow = Duration(hours: 1);

/// Compact size label. Gigabytes are a routine sight now that transfers are
/// unbounded, so the ladder goes all the way up.
String formatByteSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }
  return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
}

String currentPlatformName() {
  if (Platform.isMacOS) return 'macos';
  if (Platform.isWindows) return 'windows';
  if (Platform.isLinux) return 'linux';
  if (Platform.isIOS) return 'ios';
  if (Platform.isAndroid) return 'android';
  return 'unknown';
}

bool get isMobilePlatform => Platform.isIOS || Platform.isAndroid;

/// Static identity of a device as announced over the network.
class DeviceInfo {
  final String id;
  final String name;
  final String platform;
  final String publicKey; // base64 X25519 public key
  final int port; // HTTP/WS port

  const DeviceInfo({
    required this.id,
    required this.name,
    required this.platform,
    required this.publicKey,
    required this.port,
  });

  Map<String, dynamic> toJson() => {
        'app': appId,
        'v': protocolVersion,
        'id': id,
        'name': name,
        'platform': platform,
        'pk': publicKey,
        'port': port,
      };

  static DeviceInfo? tryParse(Map<String, dynamic> json) {
    if (json['app'] != appId || json['v'] != protocolVersion) return null;
    final id = json['id'];
    final name = json['name'];
    final platform = json['platform'];
    final pk = json['pk'];
    final port = json['port'];
    if (id is! String || name is! String || platform is! String) return null;
    if (pk is! String || port is! int) return null;
    return DeviceInfo(
        id: id, name: name, platform: platform, publicKey: pk, port: port);
  }
}

/// A device seen via discovery but not necessarily paired.
class FoundDevice {
  final DeviceInfo info;
  final String address;
  DateTime lastSeen;

  FoundDevice({required this.info, required this.address})
      : lastSeen = DateTime.now();

  bool get isStale => DateTime.now().difference(lastSeen).inSeconds > 15;
}

/// What one paired device is allowed to exchange with this one.
///
/// The global sync switch is all-or-nothing, which is the wrong shape once a
/// laptop is paired with both a work phone and a home desktop: files should go
/// to one and not the other, and a device can be worth receiving from without
/// being worth sending to. Rules are per pairing and local — each side decides
/// for itself what it sends and what it accepts, and neither can widen the
/// other's.
class SyncRules {
  final bool send;
  final bool receive;
  final Set<ClipKind> kinds;

  const SyncRules({
    this.send = true,
    this.receive = true,
    this.kinds = const {ClipKind.text, ClipKind.image, ClipKind.files},
  });

  static const SyncRules defaults = SyncRules();

  bool get isDefault =>
      send && receive && kinds.length == ClipKind.values.length;

  bool allowsSend(ClipKind kind) => send && kinds.contains(kind);
  bool allowsReceive(ClipKind kind) => receive && kinds.contains(kind);

  SyncRules copyWith({bool? send, bool? receive, Set<ClipKind>? kinds}) =>
      SyncRules(
        send: send ?? this.send,
        receive: receive ?? this.receive,
        kinds: kinds ?? this.kinds,
      );

  SyncRules withKind(ClipKind kind, bool allowed) {
    final next = {...kinds};
    if (allowed) {
      next.add(kind);
    } else {
      next.remove(kind);
    }
    return copyWith(kinds: next);
  }

  Map<String, dynamic> toJson() => {
        'send': send,
        'receive': receive,
        'kinds': [for (final k in kinds) k.name],
      };

  factory SyncRules.fromJson(Map<String, dynamic> json) => SyncRules(
        send: json['send'] as bool? ?? true,
        receive: json['receive'] as bool? ?? true,
        kinds: {
          for (final name in (json['kinds'] as List<dynamic>? ?? const []))
            ...ClipKind.values.where((k) => k.name == name),
        },
      );
}

/// A paired (trusted) device persisted between launches.
class Peer {
  final String id;
  String name;
  final String platform;
  final String secret; // base64, HKDF-derived pairing secret

  /// What this device syncs with that one. See [SyncRules].
  SyncRules rules;

  /// Where this peer was last reached. Lets a reconnect be attempted straight
  /// away instead of waiting for discovery — which matters on iOS, where
  /// Bonjour is the only discovery channel. Null until the peer is seen once;
  /// stale after the peer's IP changes, at which point discovery corrects it.
  String? lastAddress;
  int? lastPort;

  Peer({
    required this.id,
    required this.name,
    required this.platform,
    required this.secret,
    this.lastAddress,
    this.lastPort,
    this.rules = SyncRules.defaults,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'platform': platform,
        'secret': secret,
        if (lastAddress != null) 'addr': lastAddress,
        if (lastPort != null) 'port': lastPort,
        if (!rules.isDefault) 'rules': rules.toJson(),
      };

  factory Peer.fromJson(Map<String, dynamic> json) => Peer(
        id: json['id'] as String,
        name: json['name'] as String,
        platform: json['platform'] as String,
        secret: json['secret'] as String,
        lastAddress: json['addr'] as String?,
        lastPort: json['port'] as int?,
        rules: json['rules'] is Map<String, dynamic>
            ? SyncRules.fromJson(json['rules'] as Map<String, dynamic>)
            : SyncRules.defaults,
      );
}

// ---- Clipboard payloads ----

enum ClipKind { text, image, files }

/// One file inside a `files` clip.
///
/// A file is normally referenced by [path] and read straight off disk when it
/// is sent, so a 4 GB video costs a 64 KB buffer rather than 4 GB of heap.
/// [bytes] is only populated for content that never had a file behind it (the
/// legacy one-frame path, and images taken from the pasteboard).
class ClipFile {
  final String name;
  final int size;
  final String? path;
  final Uint8List? bytes;

  ClipFile.inline({required this.name, required Uint8List this.bytes})
      : size = bytes.length,
        path = null;

  ClipFile.onDisk({
    required this.name,
    required String this.path,
    required this.size,
  }) : bytes = null;

  /// Reads the contents in chunks, from memory or from disk.
  Stream<List<int>> openRead() =>
      bytes != null ? Stream.value(bytes!) : File(path!).openRead();

  /// Whole contents in memory. Only call this for content known to be small —
  /// the whole point of [path] is not having to.
  Future<Uint8List> readAll() async =>
      bytes ?? await File(path!).readAsBytes();

  Map<String, dynamic> toJson() =>
      {'name': name, 'data': base64Encode(bytes!)};

  factory ClipFile.fromJson(Map<String, dynamic> json) => ClipFile.inline(
        name: json['name'] as String,
        bytes: base64Decode(json['data'] as String),
      );
}

/// The clipboard content exchanged between devices (sent encrypted).
class ClipPayload {
  final ClipKind kind;
  final String? text;
  final Uint8List? imageBytes; // PNG
  final List<ClipFile> files;
  final int ts;
  final String origin; // device id

  ClipPayload.text(String this.text,
      {required this.ts, required this.origin})
      : kind = ClipKind.text,
        imageBytes = null,
        files = const [];

  ClipPayload.image(Uint8List this.imageBytes,
      {required this.ts, required this.origin})
      : kind = ClipKind.image,
        text = null,
        files = const [];

  ClipPayload.files(this.files, {required this.ts, required this.origin})
      : kind = ClipKind.files,
        text = null,
        imageBytes = null;

  ClipPayload._({
    required this.kind,
    required this.text,
    required this.imageBytes,
    required this.files,
    required this.ts,
    required this.origin,
  });

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'ts': ts,
        'origin': origin,
        if (text != null) 'text': text,
        if (imageBytes != null) 'image': base64Encode(imageBytes!),
        if (files.isNotEmpty) 'files': files.map((f) => f.toJson()).toList(),
      };

  static ClipPayload? tryParse(Map<String, dynamic> json) {
    final kind = ClipKind.values
        .where((k) => k.name == json['kind'])
        .firstOrNull;
    if (kind == null) return null;
    try {
      return ClipPayload._(
        kind: kind,
        text: json['text'] as String?,
        imageBytes: json['image'] != null
            ? base64Decode(json['image'] as String)
            : null,
        files: (json['files'] as List<dynamic>? ?? const [])
            .map((f) => ClipFile.fromJson(f as Map<String, dynamic>))
            .toList(),
        ts: json['ts'] as int,
        origin: json['origin'] as String,
      );
    } catch (_) {
      return null;
    }
  }

  /// Stable signature used to suppress clipboard echo loops.
  String get signature => switch (kind) {
        ClipKind.text => 't:${text.hashCode}:${text!.length}',
        ClipKind.image =>
          'i:${Object.hashAll(imageBytes!.take(64))}:${imageBytes!.length}',
        ClipKind.files =>
          'f:${files.map((f) => '${f.name}:${f.size}').join(',')}',
      };

  /// Payload size in bytes, without materialising anything.
  ///
  /// Decides between the one-frame and the streamed path, so it must not
  /// itself read a file: for [ClipKind.files] the sizes come from the
  /// directory entry.
  int get byteSize => switch (kind) {
        // Encoding a plausible clipboard string to measure it is cheap; past
        // that an upper bound is enough, and utf8.encode on a huge one would
        // allocate exactly what the streamed path exists to avoid.
        ClipKind.text => text!.length <= inlineClipBytes
            ? utf8.encode(text!).length
            : text!.length * 4,
        ClipKind.image => imageBytes!.length,
        ClipKind.files => files.fold(0, (sum, f) => sum + f.size),
      };

  /// A copy whose file contents are in memory, so [toJson] can encode them.
  ///
  /// Only used on the one-frame path, which is bounded by
  /// [legacyMaxClipBytes]; the streamed path never needs this.
  Future<ClipPayload> materialized() async {
    if (kind != ClipKind.files) return this;
    return ClipPayload._(
      kind: kind,
      text: text,
      imageBytes: imageBytes,
      files: [
        for (final f in files)
          f.bytes != null
              ? f
              : ClipFile.inline(name: f.name, bytes: await f.readAll()),
      ],
      ts: ts,
      origin: origin,
    );
  }
}

/// One clipboard entry in local history.
class ClipItem {
  final ClipKind kind;
  final String? text;
  final Uint8List? imageBytes;
  final String? imagePath; // on-disk copy of the image, for persistence
  final int imageSize; // kept so the size shows even if bytes aren't loaded
  final List<String> fileNames;
  final List<String> filePaths; // local paths (saved or source)
  final DateTime time;
  final String sourceName;
  final bool remote;

  ClipItem({
    required this.kind,
    this.text,
    this.imageBytes,
    this.imagePath,
    int? imageSize,
    this.fileNames = const [],
    this.filePaths = const [],
    required this.time,
    required this.sourceName,
    required this.remote,
  }) : imageSize = imageSize ?? imageBytes?.length ?? 0;

  ClipItem copyWith({Uint8List? imageBytes, String? imagePath}) => ClipItem(
        kind: kind,
        text: text,
        imageBytes: imageBytes ?? this.imageBytes,
        imagePath: imagePath ?? this.imagePath,
        imageSize: imageSize,
        fileNames: fileNames,
        filePaths: filePaths,
        time: time,
        sourceName: sourceName,
        remote: remote,
      );

  String get preview {
    switch (kind) {
      case ClipKind.text:
        final t = (text ?? '').replaceAll(RegExp(r'\s+'), ' ').trim();
        return t.length > 200 ? '${t.substring(0, 200)}…' : t;
      case ClipKind.image:
        return 'Image (${formatByteSize(imageSize)})';
      case ClipKind.files:
        return fileNames.join(', ');
    }
  }

  /// The address this clip points at, when the whole clip is a single link or
  /// email address. Drives the "Open link" action in the history list.
  ///
  /// Only `http`, `https` and `mailto` are ever returned: clips can arrive from
  /// a paired device, and we don't want a remote peer to be able to hand us a
  /// `file:` or custom-scheme URL to launch.
  Uri? get linkUri {
    if (kind != ClipKind.text) return null;
    final value = (text ?? '').trim();
    // A link is a single token; anything with whitespace is prose that merely
    // happens to contain a URL, and offering "open" for it would be a guess.
    if (value.isEmpty || value.length > 2048 || RegExp(r'\s').hasMatch(value)) {
      return null;
    }

    if (RegExp(r'^[^@\s]+@[^@\s]+\.[a-z]{2,}$', caseSensitive: false)
        .hasMatch(value)) {
      return Uri(scheme: 'mailto', path: value);
    }

    final hasScheme =
        RegExp(r'^[a-z][a-z0-9+.\-]*://', caseSensitive: false).hasMatch(value);
    final candidate = hasScheme
        ? value
        : (value.startsWith('www.') ? 'https://$value' : null);
    if (candidate == null) return null;

    final uri = Uri.tryParse(candidate);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri;
  }

  /// Human-readable image size, so the UI can build a localized label.
  String get formattedImageSize => formatByteSize(imageSize);

  /// Serializes metadata for persistence. Image bytes are stored separately
  /// on disk (see [imagePath]); only the path is written here.
  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        if (text != null) 'text': text,
        if (imagePath != null) 'imagePath': imagePath,
        if (imageSize > 0) 'imageSize': imageSize,
        if (fileNames.isNotEmpty) 'fileNames': fileNames,
        if (filePaths.isNotEmpty) 'filePaths': filePaths,
        'time': time.millisecondsSinceEpoch,
        'sourceName': sourceName,
        'remote': remote,
      };

  /// Rebuilds an item from JSON. [imageBytes] is supplied separately by the
  /// history store after reading the referenced file (may be null if gone).
  static ClipItem? tryFromJson(Map<String, dynamic> json,
      {Uint8List? imageBytes}) {
    final kind = ClipKind.values
        .where((k) => k.name == json['kind'])
        .firstOrNull;
    if (kind == null) return null;
    try {
      return ClipItem(
        kind: kind,
        text: json['text'] as String?,
        imageBytes: imageBytes,
        imagePath: json['imagePath'] as String?,
        imageSize: json['imageSize'] as int?,
        fileNames:
            (json['fileNames'] as List<dynamic>? ?? const []).cast<String>(),
        filePaths:
            (json['filePaths'] as List<dynamic>? ?? const []).cast<String>(),
        time: DateTime.fromMillisecondsSinceEpoch(json['time'] as int),
        sourceName: json['sourceName'] as String,
        remote: json['remote'] as bool,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Incoming pairing request awaiting user confirmation.
class PairRequest {
  final DeviceInfo requester;
  final String code; // 6-digit verification code
  final void Function(bool accepted) respond;

  PairRequest({
    required this.requester,
    required this.code,
    required this.respond,
  });
}

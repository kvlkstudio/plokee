import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

/// Protocol version. Bump on breaking changes.
const int protocolVersion = 1;
const String appId = 'plokee';

/// Clips larger than this (payload JSON size) are not sent over the network.
const int maxClipBytes = 32 * 1024 * 1024;

/// How long a clip stays worth replaying to a peer that connects late.
///
/// A phone is disconnected whenever it is in a pocket — on iOS the OS suspends
/// the app outright — so a clip copied meanwhile never reaches it. Handing the
/// newest one over on connect is the closest thing to background sync those
/// platforms allow. Older than this it is left alone: overwriting what the
/// user copied on the phone itself, long after the fact, would be worse than
/// missing the sync.
const Duration clipReplayWindow = Duration(hours: 1);

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

/// A paired (trusted) device persisted between launches.
class Peer {
  final String id;
  String name;
  final String platform;
  final String secret; // base64, HKDF-derived pairing secret

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
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'platform': platform,
        'secret': secret,
        if (lastAddress != null) 'addr': lastAddress,
        if (lastPort != null) 'port': lastPort,
      };

  factory Peer.fromJson(Map<String, dynamic> json) => Peer(
        id: json['id'] as String,
        name: json['name'] as String,
        platform: json['platform'] as String,
        secret: json['secret'] as String,
        lastAddress: json['addr'] as String?,
        lastPort: json['port'] as int?,
      );
}

// ---- Clipboard payloads ----

enum ClipKind { text, image, files }

/// One file inside a `files` clip.
class ClipFile {
  final String name;
  final Uint8List bytes;

  ClipFile({required this.name, required this.bytes});

  Map<String, dynamic> toJson() =>
      {'name': name, 'data': base64Encode(bytes)};

  factory ClipFile.fromJson(Map<String, dynamic> json) => ClipFile(
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
        ClipKind.files => 'f:${files.map((f) => '${f.name}:${f.bytes.length}').join(',')}',
      };
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
        return 'Image (${_formatSize(imageSize)})';
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
  String get formattedImageSize => _formatSize(imageSize);

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

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

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:plokee/src/clipboard_service.dart';
import 'package:plokee/src/models.dart';

/// A clipboard that behaves like a real one: it re-encodes images on write.
///
/// This is what caused the echo loop between three devices — A's 40 KB PNG
/// came back off B's pasteboard as 45 KB, so B mistook the clip it had just
/// applied for something the user copied and broadcast it onward.
class _FakePasteboard {
  Uint8List? image;
  List<String> files = const [];
  String? text;

  /// Stands in for the platform's own PNG encoder: same picture, other bytes.
  static Uint8List reencode(Uint8List bytes) =>
      Uint8List.fromList([...bytes, ...List.filled(bytes.length ~/ 2, 7)]);

  void install() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('pasteboard'),
        (call) async {
      switch (call.method) {
        case 'image':
          return image;
        case 'files':
          return files;
        case 'writeImage':
          image = reencode(call.arguments as Uint8List);
          files = const [];
          return null;
        case 'writeFiles':
          files = (call.arguments as List).cast<String>();
          image = null;
          return null;
      }
      return null;
    });
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      switch (call.method) {
        case 'Clipboard.setData':
          text = (call.arguments as Map)['text'] as String?;
          image = null;
          files = const [];
          return null;
        case 'Clipboard.getData':
          return text == null ? null : {'text': text};
      }
      return null;
    });
  }

  void uninstall() {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(const MethodChannel('pasteboard'), null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakePasteboard pasteboard;
  late List<LocalClip> localClips;
  late ClipboardService service;
  late Directory saveDir;

  setUp(() async {
    pasteboard = _FakePasteboard()..install();
    localClips = [];
    service = ClipboardService(onLocalClip: localClips.add);
    saveDir = await Directory.systemTemp.createTemp('plokee_echo_test');
  });

  tearDown(() async {
    pasteboard.uninstall();
    if (saveDir.existsSync()) await saveDir.delete(recursive: true);
  });

  ClipPayload imagePayload(List<int> bytes) => ClipPayload.image(
        Uint8List.fromList(bytes),
        ts: DateTime.now().millisecondsSinceEpoch,
        origin: 'peer',
      );

  test('an applied image is not mistaken for a fresh local copy', () async {
    await service.applyRemote(imagePayload([1, 2, 3, 4]), saveDir: saveDir);
    // The clipboard now holds bytes that differ from the ones we were sent.
    expect(pasteboard.image, isNot(equals(Uint8List.fromList([1, 2, 3, 4]))));

    expect(await service.checkNow(), isNull);
    expect(localClips, isEmpty, reason: 'this would be the rebroadcast');
  });

  test('an applied text clip is not mistaken for a fresh local copy', () async {
    await service.applyRemote(
      ClipPayload.text('привет',
          ts: DateTime.now().millisecondsSinceEpoch, origin: 'peer'),
      saveDir: saveDir,
    );
    expect(await service.checkNow(), isNull);
    expect(localClips, isEmpty);
  });

  test('applied files are not mistaken for a fresh local copy, even when '
      'renamed around a collision', () async {
    // Occupy the name so _uniquePath has to save as "note (1).txt", which the
    // payload's own signature knows nothing about.
    await File('${saveDir.path}${Platform.pathSeparator}note.txt')
        .writeAsBytes([9, 9]);

    final result = await service.applyRemote(
      ClipPayload.files(
        [ClipFile(name: 'note.txt', bytes: Uint8List.fromList([1, 2, 3]))],
        ts: DateTime.now().millisecondsSinceEpoch,
        origin: 'peer',
      ),
      saveDir: saveDir,
    );
    expect(result.savedPaths.single, contains('note (1).txt'));

    expect(await service.checkNow(), isNull);
    expect(localClips, isEmpty);
  });

  test('a genuinely new clip still reaches onLocalClip', () async {
    await service.applyRemote(imagePayload([1, 2, 3, 4]), saveDir: saveDir);
    expect(localClips, isEmpty);

    // The user copies something else.
    pasteboard.image = Uint8List.fromList([42, 42, 42, 42, 42]);
    final clip = await service.checkNow();
    expect(clip, isNotNull);
    expect(clip!.kind, ClipKind.image);
    expect(localClips, hasLength(1));
  });
}

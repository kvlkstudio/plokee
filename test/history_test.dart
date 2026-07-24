import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:plokee/src/history_store.dart';
import 'package:plokee/src/models.dart';

void main() {
  ClipItem textItem(String text, {bool remote = false}) => ClipItem(
    kind: ClipKind.text,
    text: text,
    time: DateTime.fromMillisecondsSinceEpoch(1000),
    sourceName: 'Src',
    remote: remote,
  );

  test('ClipItem text round-trips through JSON', () {
    final item = textItem('привет 📋', remote: true);
    final back = ClipItem.tryFromJson(item.toJson());
    expect(back, isNotNull);
    expect(back!.kind, ClipKind.text);
    expect(back.text, 'привет 📋');
    expect(back.remote, isTrue);
    expect(back.sourceName, 'Src');
  });

  test('ClipItem image keeps size and path but not bytes in JSON', () {
    final item = ClipItem(
      kind: ClipKind.image,
      imageBytes: Uint8List.fromList(List.filled(2048, 7)),
      imagePath: '/tmp/x.png',
      time: DateTime.fromMillisecondsSinceEpoch(1),
      sourceName: 'Src',
      remote: false,
    );
    final json = item.toJson();
    expect(json.containsKey('image'), isFalse); // bytes never inlined
    expect(json['imagePath'], '/tmp/x.png');
    expect(json['imageSize'], 2048);

    final back = ClipItem.tryFromJson(json);
    expect(back!.preview, 'Image (2 KB)'); // size survives without bytes
    expect(back.imagePath, '/tmp/x.png');
  });

  test('tryFromJson rejects malformed entries', () {
    expect(ClipItem.tryFromJson({'kind': 'nope'}), isNull);
    expect(ClipItem.tryFromJson({'kind': 'text'}), isNull); // no time/source
  });

  test('HistoryStore saves and reloads entries with image bytes', () async {
    final dir = await Directory.systemTemp.createTemp('plokee_hist');
    addTearDown(() => dir.delete(recursive: true));
    final store = HistoryStore(dir);

    final bytes = Uint8List.fromList(List.generate(500, (i) => i % 256));
    final path = await store.persistImage(bytes, 42);
    expect(path, isNotNull);

    final items = [
      textItem('first'),
      ClipItem(
        kind: ClipKind.image,
        imageBytes: bytes,
        imagePath: path,
        time: DateTime.fromMillisecondsSinceEpoch(42),
        sourceName: 'Phone',
        remote: true,
      ),
    ];
    await store.save(items);

    final loaded = await store.load();
    expect(loaded.length, 2);
    expect(loaded[0].text, 'first');
    expect(loaded[1].kind, ClipKind.image);
    expect(
      loaded[1].imageBytes,
      equals(bytes),
      reason: 'image bytes should be read back from disk',
    );
  });

  test('HistoryStore prunes orphaned images on save', () async {
    final dir = await Directory.systemTemp.createTemp('plokee_hist');
    addTearDown(() => dir.delete(recursive: true));
    final store = HistoryStore(dir);

    final keep = await store.persistImage(Uint8List.fromList([1, 2]), 1);
    final orphan = await store.persistImage(Uint8List.fromList([3, 4]), 2);
    final fresh = await store.persistImage(Uint8List.fromList([5, 6]), 3);
    // Only images past the grace period are collected, so age this one.
    await File(orphan!)
        .setLastModified(DateTime.now().subtract(const Duration(hours: 1)));

    await store.save([
      ClipItem(
        kind: ClipKind.image,
        imageBytes: Uint8List.fromList([1, 2]),
        imagePath: keep,
        time: DateTime.fromMillisecondsSinceEpoch(1),
        sourceName: 'x',
        remote: false,
      ),
    ]);

    expect(await File(keep!).exists(), isTrue);
    expect(
      await File(orphan).exists(),
      isFalse,
      reason: 'image not referenced by any entry should be deleted',
    );
    expect(
      await File(fresh!).exists(),
      isTrue,
      reason: 'an image written moments ago belongs to an entry not yet saved',
    );
  });

  test('history survives the container moving underneath it', () async {
    // iOS rebuilds the sandbox path on reinstall, so yesterday's absolute
    // paths are dead ends today. Simulate it by moving the whole directory.
    final oldDir = await Directory.systemTemp.createTemp('plokee_hist_old');
    final bytes = Uint8List.fromList(List.generate(64, (i) => i));
    final path = await HistoryStore(oldDir).persistImage(bytes, 7);
    await HistoryStore(oldDir).save([
      ClipItem(
        kind: ClipKind.image,
        imageBytes: bytes,
        imagePath: path,
        time: DateTime.fromMillisecondsSinceEpoch(7),
        sourceName: 'Mac',
        remote: true,
      ),
    ]);

    final newDir = Directory('${oldDir.path}_moved');
    addTearDown(() => newDir.delete(recursive: true));
    await oldDir.rename(newDir.path);

    final loaded = await HistoryStore(newDir).load();
    expect(loaded, hasLength(1));
    expect(
      loaded.single.imageBytes,
      equals(bytes),
      reason: 'the image must be found by name in the current container',
    );
  });

  test('HistoryStore returns empty list when nothing saved', () async {
    final dir = await Directory.systemTemp.createTemp('plokee_hist');
    addTearDown(() => dir.delete(recursive: true));
    expect(await HistoryStore(dir).load(), isEmpty);
  });
}

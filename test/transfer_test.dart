import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:plokee/src/crypto.dart';
import 'package:plokee/src/models.dart';
import 'package:plokee/src/settings_store.dart';
import 'package:plokee/src/sync_engine.dart';
import 'package:plokee/src/transfer.dart';

/// Two engines, paired out of band, with B writing incoming files into its own
/// directory. Returns (engineA, engineB, incomingDirOfB).
Future<(SyncEngine, SyncEngine, Directory)> _pairedEngines({
  required void Function(Peer peer, ClipPayload payload) onClipAtB,
  SyncRules rulesAtB = SyncRules.defaults,
}) async {
  final storeA = SettingsStore.inMemory(deviceId: 'aaaa', deviceName: 'A');
  final storeB = SettingsStore.inMemory(deviceId: 'zzzz', deviceName: 'B');
  final cryptoA = await CryptoService.fromSeed(storeA.keySeed);
  final cryptoB = await CryptoService.fromSeed(storeB.keySeed);
  final incoming = await Directory.systemTemp.createTemp('plokee-in');
  // Off the shipping range: test files run side by side, and an engine here
  // would otherwise turn up in another file's probeDevice sweep.
  const portStart = 45700;
  const portEnd = 45720;

  late SyncEngine engineA;
  late SyncEngine engineB;
  engineA = SyncEngine(
    portStart: portStart,
    portEnd: portEnd,
    settings: storeA,
    crypto: cryptoA,
    localInfo: () => DeviceInfo(
        id: 'aaaa',
        name: 'A',
        platform: 'macos',
        publicKey: cryptoA.publicKeyBase64,
        port: engineA.port),
    onPairRequest: (_) async => false,
    onRemoteClip: (_, _) {},
    onConnectionsChanged: () {},
  );
  engineB = SyncEngine(
    portStart: portStart,
    portEnd: portEnd,
    settings: storeB,
    crypto: cryptoB,
    localInfo: () => DeviceInfo(
        id: 'zzzz',
        name: 'B',
        platform: 'linux',
        publicKey: cryptoB.publicKeyBase64,
        port: engineB.port),
    incomingDir: () async => incoming,
    onPairRequest: (_) async => false,
    onRemoteClip: onClipAtB,
    onConnectionsChanged: () {},
  );

  await engineA.start();
  await engineB.start();

  const secret = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
  await storeA
      .addPeer(Peer(id: 'zzzz', name: 'B', platform: 'linux', secret: secret));
  await storeB.addPeer(Peer(
      id: 'aaaa',
      name: 'A',
      platform: 'macos',
      secret: secret,
      rules: rulesAtB));
  // A holds the smaller id, so it is the side allowed to dial.
  await engineA.connectTo(storeA.peerById('zzzz')!, ['127.0.0.1'], engineB.port);
  await Future<void>.delayed(const Duration(milliseconds: 200));
  return (engineA, engineB, incoming);
}

void main() {
  group('chunk frames', () {
    final secret = Uint8List.fromList(List.generate(32, (i) => i));

    test('round-trip carries the position inside the sealed part', () async {
      final data = Uint8List.fromList(List.generate(1000, (i) => i % 256));
      final frame = await encodeChunkFrame(secret, 3, 4096, data);
      final decoded = await decodeChunkFrame(secret, frame);
      expect(decoded, isNotNull);
      expect(decoded!.itemIndex, 3);
      expect(decoded.offset, 4096);
      expect(decoded.data, equals(data));
    });

    test('a tampered frame decodes to nothing', () async {
      final frame = await encodeChunkFrame(secret, 0, 0, [1, 2, 3]);
      frame[frame.length - 1] ^= 0xff;
      expect(await decodeChunkFrame(secret, frame), isNull);
    });

    test('a frame sealed for another peer decodes to nothing', () async {
      final frame = await encodeChunkFrame(secret, 0, 0, [1, 2, 3]);
      final other = Uint8List.fromList(List.generate(32, (i) => 255 - i));
      expect(await decodeChunkFrame(other, frame), isNull);
    });
  });

  group('sanitizeFileName', () {
    test('a peer cannot name a file its way out of the directory', () {
      expect(sanitizeFileName('../../.ssh/authorized_keys'),
          isNot(contains('/')));
      expect(sanitizeFileName('../../.ssh/authorized_keys'),
          isNot(startsWith('.')));
      expect(sanitizeFileName(r'..\..\windows\system32\evil.dll'),
          isNot(contains(r'\')));
    });

    test('ordinary names survive intact', () {
      expect(sanitizeFileName('отчёт за 2026.pdf'), 'отчёт за 2026.pdf');
      expect(sanitizeFileName('archive.tar.gz'), 'archive.tar.gz');
    });

    test('a name that sanitizes to nothing still gets one', () {
      expect(sanitizeFileName('...'), isNotEmpty);
      expect(sanitizeFileName(''), isNotEmpty);
    });
  });

  test('a multi-chunk file syncs byte for byte', () async {
    // Comfortably over inlineClipBytes and over several chunks, so the whole
    // manifest/chunk/done path runs — including the sink backpressure that a
    // one-chunk payload would never exercise.
    final source = await Directory.systemTemp.createTemp('plokee-src');
    addTearDown(() => source.delete(recursive: true));
    final big = File('${source.path}${Platform.pathSeparator}big.bin');
    final bytes = Uint8List.fromList(
        List.generate(3 * 1024 * 1024, (i) => (i * 31) % 256));
    await big.writeAsBytes(bytes);

    final received = Completer<ClipPayload>();
    final (engineA, engineB, incoming) = await _pairedEngines(
      onClipAtB: (_, payload) {
        if (!received.isCompleted) received.complete(payload);
      },
    );
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
      await incoming.delete(recursive: true);
    });

    await engineA.broadcastClip(ClipPayload.files(
      [ClipFile.onDisk(name: 'big.bin', path: big.path, size: bytes.length)],
      ts: DateTime.now().millisecondsSinceEpoch,
      origin: 'aaaa',
    ));

    final payload = await received.future.timeout(const Duration(seconds: 30));
    expect(payload.kind, ClipKind.files);
    final arrived = payload.files.single;
    // The receiver never held it in memory: it hands back a path, not bytes.
    expect(arrived.bytes, isNull);
    expect(arrived.path, isNotNull);
    expect(arrived.size, bytes.length);
    expect(await File(arrived.path!).readAsBytes(), equals(bytes));
    // Nothing partial is left behind.
    expect(
      incoming.listSync().where((e) => e.path.endsWith('.part')),
      isEmpty,
    );
  });

  test('a file past the old 32 MB ceiling goes through', () async {
    // The limit this replaces. Kept as its own case because "big files work
    // now" is the whole point, and a 3 MB file would have worked before too.
    final source = await Directory.systemTemp.createTemp('plokee-src');
    addTearDown(() => source.delete(recursive: true));
    final big = File('${source.path}${Platform.pathSeparator}huge.bin');
    final size = legacyMaxClipBytes + 5 * 1024 * 1024;
    final block = Uint8List.fromList(List.generate(1 << 20, (i) => i % 251));
    final sink = big.openWrite();
    for (var written = 0; written < size; written += block.length) {
      sink.add(block);
    }
    await sink.flush();
    await sink.close();

    final received = Completer<ClipPayload>();
    final (engineA, engineB, incoming) = await _pairedEngines(
      onClipAtB: (_, payload) {
        if (!received.isCompleted) received.complete(payload);
      },
    );
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
      await incoming.delete(recursive: true);
    });

    await engineA.broadcastClip(ClipPayload.files(
      [
        ClipFile.onDisk(
            name: 'huge.bin', path: big.path, size: big.lengthSync())
      ],
      ts: DateTime.now().millisecondsSinceEpoch,
      origin: 'aaaa',
    ));

    final payload = await received.future.timeout(const Duration(minutes: 3));
    final arrived = File(payload.files.single.path!);
    expect(await arrived.length(), big.lengthSync());
    // Spot-check rather than compare 37 MB twice in memory — the byte-for-byte
    // guarantee is covered by the multi-chunk case above.
    final tail = await arrived.openRead(size - 4).first;
    expect(tail, equals(block.sublist(block.length - 4)));
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('text copied during a long transfer does not wait for it', () async {
    // The reason transfers are cut into segments. Holding the socket for a
    // whole multi-gigabyte file would mean everything copied meanwhile arrives
    // only once it finishes, which for the user reads as sync being broken.
    final source = await Directory.systemTemp.createTemp('plokee-src');
    addTearDown(() => source.delete(recursive: true));
    final big = File('${source.path}${Platform.pathSeparator}huge.bin');
    final block = Uint8List.fromList(List.generate(1 << 20, (i) => i % 251));
    final sink = big.openWrite();
    for (var i = 0; i < 40; i++) {
      sink.add(block);
    }
    await sink.flush();
    await sink.close();

    final order = <ClipKind>[];
    final textArrived = Completer<void>();
    final fileArrived = Completer<void>();
    final (engineA, engineB, incoming) = await _pairedEngines(
      onClipAtB: (_, payload) {
        order.add(payload.kind);
        final done = payload.kind == ClipKind.text ? textArrived : fileArrived;
        if (!done.isCompleted) done.complete();
      },
    );
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
      await incoming.delete(recursive: true);
    });

    // Distinct timestamps: `origin:ts` is a clip's identity, and two clips
    // sharing one would make the second look like a replay of the first.
    final now = DateTime.now().millisecondsSinceEpoch;
    final transfer = engineA.broadcastClip(ClipPayload.files(
      [
        ClipFile.onDisk(
            name: 'huge.bin', path: big.path, size: big.lengthSync())
      ],
      ts: now,
      origin: 'aaaa',
    ));
    await engineA.broadcastClip(
        ClipPayload.text('срочный текст', ts: now + 1, origin: 'aaaa'));

    await textArrived.future.timeout(const Duration(seconds: 20));
    expect(order, [ClipKind.text],
        reason: 'the text must overtake the file, not queue behind it');
    await transfer;
    await fileArrived.future.timeout(const Duration(seconds: 20));
    expect(order, [ClipKind.text, ClipKind.files]);
  }, timeout: const Timeout(Duration(minutes: 2)));

  test('several files arrive in order, empty ones included', () async {
    final source = await Directory.systemTemp.createTemp('plokee-src');
    addTearDown(() => source.delete(recursive: true));
    final sep = Platform.pathSeparator;
    final one = File('${source.path}${sep}one.txt')
      ..writeAsBytesSync(utf8.encode('первый' * 100000));
    final empty = File('${source.path}${sep}empty.log')..writeAsBytesSync([]);
    final three = File('${source.path}${sep}three.bin')
      ..writeAsBytesSync(List.generate(700 * 1024, (i) => i % 97));

    final received = Completer<ClipPayload>();
    final (engineA, engineB, incoming) = await _pairedEngines(
      onClipAtB: (_, payload) {
        if (!received.isCompleted) received.complete(payload);
      },
    );
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
      await incoming.delete(recursive: true);
    });

    await engineA.broadcastClip(ClipPayload.files(
      [
        for (final f in [one, empty, three])
          ClipFile.onDisk(
              name: f.uri.pathSegments.last,
              path: f.path,
              size: f.lengthSync()),
      ],
      ts: DateTime.now().millisecondsSinceEpoch,
      origin: 'aaaa',
    ));

    final payload = await received.future.timeout(const Duration(seconds: 30));
    expect(payload.files.map((f) => f.name),
        ['one.txt', 'empty.log', 'three.bin']);
    for (var i = 0; i < 3; i++) {
      final sent = [one, empty, three][i];
      expect(await File(payload.files[i].path!).readAsBytes(),
          equals(sent.readAsBytesSync()),
          reason: '${payload.files[i].name} must match byte for byte');
    }
  });

  test('a large text clip streams and comes back identical', () async {
    // Text above the inline threshold takes the streamed path too, so the
    // whole thing has to survive a trip through disk and back to a String.
    final text = 'строка с юникодом 🌍\n' * 40000;
    final received = Completer<ClipPayload>();
    final (engineA, engineB, incoming) = await _pairedEngines(
      onClipAtB: (_, payload) {
        if (!received.isCompleted) received.complete(payload);
      },
    );
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
      await incoming.delete(recursive: true);
    });

    expect(utf8.encode(text).length, greaterThan(inlineClipBytes));
    await engineA.broadcastClip(ClipPayload.text(text,
        ts: DateTime.now().millisecondsSinceEpoch, origin: 'aaaa'));

    final payload = await received.future.timeout(const Duration(seconds: 30));
    expect(payload.kind, ClipKind.text);
    expect(payload.text, text);
  });

  test('a peer that refuses files never lets one touch its disk', () async {
    final source = await Directory.systemTemp.createTemp('plokee-src');
    addTearDown(() => source.delete(recursive: true));
    final big = File('${source.path}${Platform.pathSeparator}big.bin')
      ..writeAsBytesSync(List.generate(2 * 1024 * 1024, (i) => i % 256));

    final clips = <ClipPayload>[];
    final (engineA, engineB, incoming) = await _pairedEngines(
      onClipAtB: (_, payload) => clips.add(payload),
      rulesAtB: const SyncRules(kinds: {ClipKind.text, ClipKind.image}),
    );
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
      await incoming.delete(recursive: true);
    });

    await engineA.broadcastClip(ClipPayload.files(
      [
        ClipFile.onDisk(
            name: 'big.bin', path: big.path, size: big.lengthSync())
      ],
      ts: DateTime.now().millisecondsSinceEpoch,
      origin: 'aaaa',
    ));
    // Text from the same device is still welcome, and doubles as a marker that
    // the connection stayed usable after the refusal.
    await engineA.broadcastClip(ClipPayload.text('всё ещё синхронизируется',
        ts: DateTime.now().millisecondsSinceEpoch, origin: 'aaaa'));
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(clips.map((c) => c.kind), [ClipKind.text]);
    expect(incoming.existsSync() ? incoming.listSync() : const [], isEmpty,
        reason: 'a refused transfer must not write anything at all');
  });

  test('a replayed file clip is refused before it is written again', () async {
    // Reconnecting replays the sender's newest clip, which is what gets a clip
    // to a phone that was asleep. For files that replay must be recognised
    // before a byte is written: rejecting it after the fact would leave a
    // second copy of the file sitting in the download folder.
    final source = await Directory.systemTemp.createTemp('plokee-src');
    addTearDown(() => source.delete(recursive: true));
    final file = File('${source.path}${Platform.pathSeparator}report.pdf')
      ..writeAsBytesSync(List.generate(600 * 1024, (i) => i % 251));

    final clips = <ClipPayload>[];
    final (engineA, engineB, incoming) = await _pairedEngines(
      onClipAtB: (_, payload) => clips.add(payload),
    );
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
      await incoming.delete(recursive: true);
    });

    await engineA.broadcastClip(ClipPayload.files(
      [
        ClipFile.onDisk(
            name: 'report.pdf', path: file.path, size: file.lengthSync())
      ],
      ts: DateTime.now().millisecondsSinceEpoch,
      origin: 'aaaa',
    ));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(clips, hasLength(1));

    engineA.disconnectPeer('zzzz');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    await engineA.connectTo(
        engineA.settings.peerById('zzzz')!, ['127.0.0.1'], engineB.port);
    await Future<void>.delayed(const Duration(seconds: 1));

    expect(clips, hasLength(1), reason: 'the replay must not be applied twice');
    expect(
      incoming.listSync().whereType<File>().map((f) => f.uri.pathSegments.last),
      ['report.pdf'],
      reason: 'and must not leave a second copy on disk',
    );
  });

  test('rules the sender sets stop the clip before it leaves', () async {
    final clips = <ClipPayload>[];
    final (engineA, engineB, incoming) = await _pairedEngines(
      onClipAtB: (_, payload) => clips.add(payload),
    );
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
      await incoming.delete(recursive: true);
    });

    await engineA.settings
        .updatePeerRules('zzzz', const SyncRules(send: false));
    await engineA.broadcastClip(ClipPayload.text('не должно уйти',
        ts: DateTime.now().millisecondsSinceEpoch, origin: 'aaaa'));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(clips, isEmpty);

    await engineA.settings
        .updatePeerRules('zzzz', const SyncRules(send: true));
    await engineA.broadcastClip(ClipPayload.text('а это должно',
        ts: DateTime.now().millisecondsSinceEpoch, origin: 'aaaa'));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(clips.single.text, 'а это должно');
  });
}

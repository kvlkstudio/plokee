import 'dart:typed_data';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:plokee/src/crypto.dart';
import 'package:plokee/src/models.dart';
import 'package:plokee/src/settings_store.dart';
import 'package:plokee/src/sync_engine.dart';

/// Full protocol round-trip between two in-process engines over localhost:
/// pairing with user confirmation, authenticated WebSocket handshake and an
/// encrypted clipboard transfer.
void main() {
  test('pairing and clipboard sync between two engines', () async {
    final storeA =
        SettingsStore.inMemory(deviceId: 'aaaa', deviceName: 'Device A');
    final storeB =
        SettingsStore.inMemory(deviceId: 'zzzz', deviceName: 'Device B');
    final cryptoA = await CryptoService.fromSeed(storeA.keySeed);
    final cryptoB = await CryptoService.fromSeed(storeB.keySeed);

    final receivedOnB = Completer<ClipPayload>();
    final receivedImageOnB = Completer<ClipPayload>();
    String? codeSeenByA;

    late SyncEngine engineA;
    late SyncEngine engineB;

    DeviceInfo infoA() => DeviceInfo(
          id: storeA.deviceId,
          name: storeA.deviceName,
          platform: 'macos',
          publicKey: cryptoA.publicKeyBase64,
          port: engineA.port,
        );
    DeviceInfo infoB() => DeviceInfo(
          id: storeB.deviceId,
          name: storeB.deviceName,
          platform: 'linux',
          publicKey: cryptoB.publicKeyBase64,
          port: engineB.port,
        );

    engineA = SyncEngine(
      settings: storeA,
      crypto: cryptoA,
      localInfo: infoA,
      onPairRequest: (req) async {
        codeSeenByA = req.code;
        return true; // user taps "Pair"
      },
      onRemoteClip: (_, _) {},
      onConnectionsChanged: () {},
    );
    engineB = SyncEngine(
      settings: storeB,
      crypto: cryptoB,
      localInfo: infoB,
      onPairRequest: (_) async => false,
      onRemoteClip: (peer, payload) {
        if (payload.kind == ClipKind.text && !receivedOnB.isCompleted) {
          receivedOnB.complete(payload);
        }
        if (payload.kind == ClipKind.image &&
            !receivedImageOnB.isCompleted) {
          receivedImageOnB.complete(payload);
        }
      },
      onConnectionsChanged: () {},
    );

    await engineA.start();
    await engineB.start();
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
    });

    // B initiates pairing with A.
    final foundA = FoundDevice(info: infoA(), address: '127.0.0.1');
    final (codeShownOnB, result) = await engineB.requestPairing(foundA);
    expect(await result, isTrue, reason: 'pairing should be accepted');
    expect(codeSeenByA, equals(codeShownOnB),
        reason: 'both devices must display the same verification code');
    expect(storeA.peerById('zzzz'), isNotNull);
    expect(storeB.peerById('aaaa'), isNotNull);

    // Pairing itself records where each side can reach the other, so the
    // reconnect loop can dial straight away without waiting on discovery to
    // resolve the peer a second time (which on the Bonjour-only iOS↔Android
    // link may never happen). Requester B keeps A's discovered address and
    // advertised port; responder A keeps the socket B reached it on.
    expect(storeB.peerById('aaaa')!.lastAddress, '127.0.0.1');
    expect(storeB.peerById('aaaa')!.lastPort, engineA.port);
    expect(storeA.peerById('zzzz')!.lastAddress, '127.0.0.1');
    expect(storeA.peerById('zzzz')!.lastPort, engineB.port);

    // A (smaller id) dials B, handshake authenticates both sides. The first
    // candidate is a black hole — discovery hands over whatever the responder
    // answered, and only some of those addresses route — so the dialler has to
    // fall through to the one that works.
    await engineA.connectTo(
      storeA.peerById('zzzz')!,
      ['192.0.2.1', '127.0.0.1'], // TEST-NET-1, guaranteed unroutable
      engineB.port,
    );
    // Server side registers asynchronously after the ack; give it a beat.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(engineA.isConnected('zzzz'), isTrue);
    expect(engineB.isConnected('aaaa'), isTrue);

    // A copies text; B receives the decrypted clip.
    await engineA.broadcastClip(ClipPayload.text(
      'синхронизированный текст 📋',
      ts: DateTime.now().millisecondsSinceEpoch,
      origin: 'aaaa',
    ));
    final received =
        await receivedOnB.future.timeout(const Duration(seconds: 5));
    expect(received.text, 'синхронизированный текст 📋');

    // A copies an image; B receives identical bytes.
    final imageBytes =
        Uint8List.fromList(List.generate(100000, (i) => i % 251));
    await engineA.broadcastClip(ClipPayload.image(
      imageBytes,
      ts: DateTime.now().millisecondsSinceEpoch,
      origin: 'aaaa',
    ));
    final image =
        await receivedImageOnB.future.timeout(const Duration(seconds: 5));
    expect(image.imageBytes, equals(imageBytes));

  });

  test('a peer that connects late still receives the clip it missed',
      () async {
    // The phone-in-a-pocket case: A copies while B is unreachable, then B
    // comes back. Nothing rebroadcasts, so without catch-up on connect the
    // clip would be lost to B for good.
    final storeA =
        SettingsStore.inMemory(deviceId: 'aaaa', deviceName: 'Device A');
    final storeB =
        SettingsStore.inMemory(deviceId: 'zzzz', deviceName: 'Device B');
    final cryptoA = await CryptoService.fromSeed(storeA.keySeed);
    final cryptoB = await CryptoService.fromSeed(storeB.keySeed);

    final receivedOnB = <ClipPayload>[];
    final firstOnB = Completer<ClipPayload>();

    late SyncEngine engineA;
    late SyncEngine engineB;
    engineA = SyncEngine(
      settings: storeA,
      crypto: cryptoA,
      localInfo: () => DeviceInfo(
          id: 'aaaa',
          name: 'A',
          platform: 'macos',
          publicKey: cryptoA.publicKeyBase64,
          port: engineA.port),
      onPairRequest: (_) async => true,
      onRemoteClip: (_, _) {},
      onConnectionsChanged: () {},
    );
    engineB = SyncEngine(
      settings: storeB,
      crypto: cryptoB,
      localInfo: () => DeviceInfo(
          id: 'zzzz',
          name: 'B',
          platform: 'ios',
          publicKey: cryptoB.publicKeyBase64,
          port: engineB.port),
      onPairRequest: (_) async => false,
      onRemoteClip: (_, payload) {
        receivedOnB.add(payload);
        if (!firstOnB.isCompleted) firstOnB.complete(payload);
      },
      onConnectionsChanged: () {},
    );

    await engineA.start();
    await engineB.start();
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
    });

    // Pair them out of band, without ever connecting.
    const secret = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
    await storeA.addPeer(
        Peer(id: 'zzzz', name: 'B', platform: 'ios', secret: secret));
    await storeB.addPeer(
        Peer(id: 'aaaa', name: 'A', platform: 'macos', secret: secret));

    // A copies with nobody listening.
    await engineA.broadcastClip(ClipPayload.text(
      'скопировано пока телефон спал',
      ts: DateTime.now().millisecondsSinceEpoch,
      origin: 'aaaa',
    ));
    expect(engineA.connectedCount, 0, reason: 'nothing was connected yet');

    // B wakes up and dials (smaller id wins the deterministic-dialler rule
    // in the other direction, so A dials B here).
    await engineA.connectTo(
        storeA.peerById('zzzz')!, ['127.0.0.1'], engineB.port);
    final caughtUp = await firstOnB.future.timeout(const Duration(seconds: 5));
    expect(caughtUp.text, 'скопировано пока телефон спал');

    // A real drop and redial sends the same clip again — by design, since the
    // sender cannot know whether the peer kept it. The receiver recognises it
    // by its unchanged timestamp and drops it before applying it a second
    // time; for a file clip that check has to happen before the bytes are
    // written, which is why it lives in the engine.
    engineA.disconnectPeer('zzzz');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(engineA.isConnected('zzzz'), isFalse);
    await engineA.connectTo(
        storeA.peerById('zzzz')!, ['127.0.0.1'], engineB.port);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(receivedOnB, hasLength(1), reason: 'the replay must not reapply');
  });

  test('probeDevice finds a peer by address alone, skipping itself', () async {
    // The multicast-blocked-network path: no discovery, just an IP. probing
    // the port range over unicast HTTP must return the *other* engine, never
    // the prober's own /info (which answers on its port too).
    final storeA =
        SettingsStore.inMemory(deviceId: 'aaaa', deviceName: 'Device A');
    final storeB =
        SettingsStore.inMemory(deviceId: 'zzzz', deviceName: 'Device B');
    final cryptoA = await CryptoService.fromSeed(storeA.keySeed);
    final cryptoB = await CryptoService.fromSeed(storeB.keySeed);

    late SyncEngine engineA;
    late SyncEngine engineB;
    engineA = SyncEngine(
      settings: storeA,
      crypto: cryptoA,
      localInfo: () => DeviceInfo(
          id: 'aaaa',
          name: 'Device A',
          platform: 'android',
          publicKey: cryptoA.publicKeyBase64,
          port: engineA.port),
      onPairRequest: (_) async => false,
      onRemoteClip: (_, _) {},
      onConnectionsChanged: () {},
    );
    engineB = SyncEngine(
      settings: storeB,
      crypto: cryptoB,
      localInfo: () => DeviceInfo(
          id: 'zzzz',
          name: 'Device B',
          platform: 'ios',
          publicKey: cryptoB.publicKeyBase64,
          port: engineB.port),
      onPairRequest: (_) async => false,
      onRemoteClip: (_, _) {},
      onConnectionsChanged: () {},
    );
    await engineA.start();
    await engineB.start();
    addTearDown(() async {
      await engineA.stop();
      await engineB.stop();
    });

    final found = await engineA.probeDevice('127.0.0.1');
    expect(found, isNotNull);
    expect(found!.info.id, 'zzzz', reason: 'never the prober itself');
    expect(found.info.name, 'Device B');
    expect(found.info.port, engineB.port);
    expect(found.address, '127.0.0.1');
  });

  test('unpaired device cannot open an authenticated channel', () async {
    final storeA =
        SettingsStore.inMemory(deviceId: 'aaaa', deviceName: 'Device A');
    final storeC =
        SettingsStore.inMemory(deviceId: 'cccc', deviceName: 'Intruder');
    final cryptoA = await CryptoService.fromSeed(storeA.keySeed);
    final cryptoC = await CryptoService.fromSeed(storeC.keySeed);

    late SyncEngine engineA;
    late SyncEngine engineC;

    engineA = SyncEngine(
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
    engineC = SyncEngine(
      settings: storeC,
      crypto: cryptoC,
      localInfo: () => DeviceInfo(
          id: 'cccc',
          name: 'C',
          platform: 'linux',
          publicKey: cryptoC.publicKeyBase64,
          port: engineC.port),
      onPairRequest: (_) async => false,
      onRemoteClip: (_, _) {},
      onConnectionsChanged: () {},
    );

    await engineA.start();
    await engineC.start();
    addTearDown(() async {
      await engineA.stop();
      await engineC.stop();
    });

    // C forges a peer record with a made-up secret and tries to dial A.
    await storeC.addPeer(Peer(
      id: 'aaaa',
      name: 'A',
      platform: 'macos',
      secret: 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    ));
    await engineC.connectTo(
        storeC.peerById('aaaa')!, ['127.0.0.1'], engineA.port);
    await Future<void>.delayed(const Duration(milliseconds: 300));

    expect(engineA.isConnected('cccc'), isFalse);
    expect(engineC.isConnected('aaaa'), isFalse);
  });
}

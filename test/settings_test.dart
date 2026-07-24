import 'package:flutter_test/flutter_test.dart';

import 'package:plokee/src/models.dart';
import 'package:plokee/src/settings_store.dart';

void main() {
  Peer peer(String id, String name) =>
      Peer(id: id, name: name, platform: 'macos', secret: 'AA==');

  test('updatePeerName adopts a new advertised name', () async {
    final store =
        SettingsStore.inMemory(deviceId: 'me', deviceName: 'Me');
    await store.addPeer(peer('p1', 'Mac.fritz.box'));

    expect(await store.updatePeerName('p1', 'MacBook Pro — Данила'), isTrue);
    expect(store.peerById('p1')!.name, 'MacBook Pro — Данила');
  });

  test('updatePeerName ignores unchanged, empty, or unknown names', () async {
    final store =
        SettingsStore.inMemory(deviceId: 'me', deviceName: 'Me');
    await store.addPeer(peer('p1', 'iPhone 16 Pro'));

    expect(await store.updatePeerName('p1', 'iPhone 16 Pro'), isFalse);
    expect(await store.updatePeerName('p1', '   '), isFalse);
    expect(await store.updatePeerName('missing', 'Whatever'), isFalse);
    expect(store.peerById('p1')!.name, 'iPhone 16 Pro');
  });
}

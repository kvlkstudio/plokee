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

  test('a peer syncs everything until told otherwise', () {
    expect(peer('p1', 'Mac').rules.isDefault, isTrue);
    for (final kind in ClipKind.values) {
      expect(peer('p1', 'Mac').rules.allowsSend(kind), isTrue);
      expect(peer('p1', 'Mac').rules.allowsReceive(kind), isTrue);
    }
  });

  test('sync rules survive a round trip through storage', () {
    final original = peer('p1', 'Work laptop')
      ..rules = const SyncRules(
        send: false,
        kinds: {ClipKind.text, ClipKind.image},
      );
    final restored = Peer.fromJson(original.toJson());

    expect(restored.rules.send, isFalse);
    expect(restored.rules.receive, isTrue);
    expect(restored.rules.allowsReceive(ClipKind.text), isTrue);
    expect(restored.rules.allowsReceive(ClipKind.files), isFalse);
    expect(restored.rules.allowsSend(ClipKind.text), isFalse);
  });

  test('default rules are not written, so old records keep working', () {
    expect(peer('p1', 'Mac').toJson().containsKey('rules'), isFalse);
    // A record saved before rules existed reads back as "sync everything",
    // which is what those pairings did.
    final legacy = Peer.fromJson({
      'id': 'p1',
      'name': 'Mac',
      'platform': 'macos',
      'secret': 'AA==',
    });
    expect(legacy.rules.isDefault, isTrue);
  });

  test('a direction can be turned off without losing the kinds', () {
    var rules = const SyncRules();
    rules = rules.withKind(ClipKind.files, false);
    rules = rules.copyWith(receive: false);

    expect(rules.kinds, {ClipKind.text, ClipKind.image});
    expect(rules.allowsSend(ClipKind.image), isTrue);
    expect(rules.allowsReceive(ClipKind.image), isFalse);
    expect(rules.isDefault, isFalse);
  });

  test('updatePeerRules persists onto the stored peer', () async {
    final store = SettingsStore.inMemory(deviceId: 'me', deviceName: 'Me');
    await store.addPeer(peer('p1', 'Phone'));

    await store.updatePeerRules('p1', const SyncRules(send: false));
    expect(store.peerById('p1')!.rules.send, isFalse);

    // An unknown id is a no-op rather than a crash.
    await store.updatePeerRules('missing', const SyncRules(receive: false));
  });
}

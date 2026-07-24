import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:plokee/src/models.dart';

void main() {
  test('ClipItem preview collapses whitespace and truncates', () {
    final item = ClipItem(
      kind: ClipKind.text,
      text: 'hello\n  world ${'x' * 300}',
      time: DateTime.now(),
      sourceName: 'test',
      remote: false,
    );
    expect(item.preview.startsWith('hello world'), isTrue);
    expect(item.preview.length, lessThanOrEqualTo(201));
    expect(item.preview.endsWith('…'), isTrue);
  });

  group('ClipItem.linkUri', () {
    ClipItem text(String value) => ClipItem(
          kind: ClipKind.text,
          text: value,
          time: DateTime.now(),
          sourceName: 'test',
          remote: false,
        );

    test('recognises http(s) and bare www links', () {
      expect(text('https://example.com/a?b=1').linkUri.toString(),
          'https://example.com/a?b=1');
      expect(text('  http://example.com  ').linkUri.toString(),
          'http://example.com');
      expect(text('www.example.com').linkUri.toString(),
          'https://www.example.com');
    });

    test('recognises a bare email address as mailto', () {
      expect(text('someone@example.com').linkUri.toString(),
          'mailto:someone@example.com');
    });

    test('ignores prose, plain words and non-text clips', () {
      expect(text('see https://example.com for details').linkUri, isNull);
      expect(text('example').linkUri, isNull);
      expect(text('').linkUri, isNull);
      expect(
        ClipItem(
          kind: ClipKind.image,
          imageBytes: Uint8List.fromList([1, 2, 3]),
          time: DateTime.now(),
          sourceName: 'test',
          remote: false,
        ).linkUri,
        isNull,
      );
    });

    test('refuses schemes other than http, https and mailto', () {
      // A paired peer must not be able to make us launch these.
      expect(text('file:///etc/passwd').linkUri, isNull);
      expect(text('javascript:alert(1)').linkUri, isNull);
      expect(text('smb://server/share').linkUri, isNull);
      expect(text('ftp://example.com').linkUri, isNull);
    });
  });

  group('Peer last-known address', () {
    test('round-trips through JSON', () {
      final peer = Peer(
        id: 'abc',
        name: 'Mac',
        platform: 'macos',
        secret: 'c2VjcmV0',
        lastAddress: '192.168.1.5',
        lastPort: 45655,
      );
      final restored = Peer.fromJson(peer.toJson());
      expect(restored.lastAddress, '192.168.1.5');
      expect(restored.lastPort, 45655);
      expect(restored.secret, 'c2VjcmV0');
    });

    test('reads peers saved before the address was stored', () {
      // Entries persisted by older builds have no addr/port keys at all.
      final restored = Peer.fromJson({
        'id': 'abc',
        'name': 'Mac',
        'platform': 'macos',
        'secret': 'c2VjcmV0',
      });
      expect(restored.lastAddress, isNull);
      expect(restored.lastPort, isNull);
      expect(restored.name, 'Mac');
    });

    test('omits the address keys until the peer has been seen', () {
      final json = Peer(
        id: 'abc',
        name: 'Mac',
        platform: 'macos',
        secret: 'c2VjcmV0',
      ).toJson();
      expect(json.containsKey('addr'), isFalse);
      expect(json.containsKey('port'), isFalse);
    });
  });

  test('DeviceInfo round-trips through JSON', () {
    const info = DeviceInfo(
      id: 'abc',
      name: 'Test',
      platform: 'macos',
      publicKey: 'cGs=',
      port: 45655,
    );
    final parsed = DeviceInfo.tryParse(info.toJson());
    expect(parsed, isNotNull);
    expect(parsed!.id, 'abc');
    expect(parsed.port, 45655);
  });

  test('DeviceInfo rejects foreign packets', () {
    expect(DeviceInfo.tryParse({'app': 'other', 'v': 1}), isNull);
  });

  test('text payload round-trips through JSON', () {
    final payload = ClipPayload.text('привет', ts: 42, origin: 'dev1');
    final parsed = ClipPayload.tryParse(payload.toJson());
    expect(parsed, isNotNull);
    expect(parsed!.kind, ClipKind.text);
    expect(parsed.text, 'привет');
    expect(parsed.origin, 'dev1');
  });

  test('image payload round-trips through JSON', () {
    final bytes = Uint8List.fromList(List.generate(256, (i) => i % 256));
    final payload = ClipPayload.image(bytes, ts: 1, origin: 'dev1');
    final parsed = ClipPayload.tryParse(payload.toJson());
    expect(parsed, isNotNull);
    expect(parsed!.kind, ClipKind.image);
    expect(parsed.imageBytes, equals(bytes));
    expect(parsed.signature, payload.signature);
  });

  test('files payload round-trips through JSON', () {
    final payload = ClipPayload.files(
      [
        ClipFile(name: 'a.txt', bytes: Uint8List.fromList([1, 2, 3])),
        ClipFile(name: 'отчёт.pdf', bytes: Uint8List.fromList([4, 5])),
      ],
      ts: 1,
      origin: 'dev1',
    );
    final parsed = ClipPayload.tryParse(payload.toJson());
    expect(parsed, isNotNull);
    expect(parsed!.kind, ClipKind.files);
    expect(parsed.files.length, 2);
    expect(parsed.files[1].name, 'отчёт.pdf');
    expect(parsed.files[0].bytes, equals([1, 2, 3]));
  });

  test('malformed payload is rejected, not thrown', () {
    expect(ClipPayload.tryParse({'kind': 'nope'}), isNull);
    expect(ClipPayload.tryParse({'kind': 'image', 'image': '!!bad-b64'}),
        isNull);
  });
}

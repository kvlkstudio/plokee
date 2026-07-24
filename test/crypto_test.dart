import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:plokee/src/crypto.dart';

void main() {
  test('two devices derive the same secret and verification code', () async {
    final a = await CryptoService.fromSeed(CryptoService.randomSeed());
    final b = await CryptoService.fromSeed(CryptoService.randomSeed());

    final secretA = await a.deriveSharedSecret(
      remotePublicKeyBase64: b.publicKeyBase64,
      myId: 'device-a',
      remoteId: 'device-b',
    );
    final secretB = await b.deriveSharedSecret(
      remotePublicKeyBase64: a.publicKeyBase64,
      myId: 'device-b',
      remoteId: 'device-a',
    );

    expect(secretA, equals(secretB));
    expect(
      await CryptoService.verificationCode(secretA),
      equals(await CryptoService.verificationCode(secretB)),
    );
    expect((await CryptoService.verificationCode(secretA)).length, 6);
  });

  test('encrypt/decrypt round-trip', () async {
    final secret = Uint8List.fromList(List.generate(32, (i) => i));
    final box = await CryptoService.encrypt(secret, 'привет, clipboard! 📋');
    expect(await CryptoService.decrypt(secret, box), 'привет, clipboard! 📋');
  });

  test('decrypt fails with the wrong secret', () async {
    final secret = Uint8List.fromList(List.generate(32, (i) => i));
    final wrong = Uint8List.fromList(List.generate(32, (i) => i + 1));
    final box = await CryptoService.encrypt(secret, 'data');
    expect(() => CryptoService.decrypt(wrong, box), throwsA(anything));
  });

  test('handshake mac is deterministic per secret/nonce/id', () async {
    final secret = Uint8List.fromList(List.generate(32, (i) => i));
    final nonce = CryptoService.randomNonceBase64();
    final m1 = await CryptoService.handshakeMac(secret, nonce, 'id1');
    final m2 = await CryptoService.handshakeMac(secret, nonce, 'id1');
    final m3 = await CryptoService.handshakeMac(secret, nonce, 'id2');
    expect(m1, equals(m2));
    expect(m1, isNot(equals(m3)));
  });
}

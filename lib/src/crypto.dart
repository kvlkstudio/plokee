import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

/// All cryptography for Plokee.
///
/// Pairing: X25519 ECDH -> HKDF-SHA256 -> per-pair secret.
/// Verification: 6-digit code derived from the secret (numeric comparison,
/// both sides display the same code).
/// Transport: AES-256-GCM with a key derived from the pair secret;
/// WebSocket handshake authenticated with HMAC-SHA256.
class CryptoService {
  static final _x25519 = X25519();
  static final _aes = AesGcm.with256bits();
  static final _hmac = Hmac.sha256();

  final SimpleKeyPair _keyPair;
  final String publicKeyBase64;

  CryptoService._(this._keyPair, this.publicKeyBase64);

  static Uint8List randomSeed() {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(32, (_) => rng.nextInt(256)));
  }

  static Future<CryptoService> fromSeed(Uint8List seed) async {
    final keyPair = await _x25519.newKeyPairFromSeed(seed);
    final pub = await keyPair.extractPublicKey();
    return CryptoService._(keyPair, base64Encode(pub.bytes));
  }

  /// Derives the shared pairing secret with a remote device.
  ///
  /// Salt is built from both device ids in sorted order so both sides
  /// derive the same secret.
  Future<Uint8List> deriveSharedSecret({
    required String remotePublicKeyBase64,
    required String myId,
    required String remoteId,
  }) async {
    final remoteKey = SimplePublicKey(
      base64Decode(remotePublicKeyBase64),
      type: KeyPairType.x25519,
    );
    final shared = await _x25519.sharedSecretKey(
      keyPair: _keyPair,
      remotePublicKey: remoteKey,
    );
    final ids = [myId, remoteId]..sort();
    final hkdf = Hkdf(hmac: _hmac, outputLength: 32);
    final derived = await hkdf.deriveKey(
      secretKey: shared,
      nonce: utf8.encode(ids.join('|')),
      info: utf8.encode('plokee-pair-v1'),
    );
    return Uint8List.fromList(await derived.extractBytes());
  }

  /// 6-digit numeric-comparison code shown on both devices during pairing.
  static Future<String> verificationCode(Uint8List secret) async {
    final hash = await Sha256().hash([...utf8.encode('verify'), ...secret]);
    final n = ByteData.sublistView(
      Uint8List.fromList(hash.bytes),
    ).getUint32(0, Endian.big);
    return (n % 1000000).toString().padLeft(6, '0');
  }

  static Future<SecretKey> _messageKey(Uint8List secret) async {
    final hkdf = Hkdf(hmac: _hmac, outputLength: 32);
    return hkdf.deriveKey(
      secretKey: SecretKey(secret),
      info: utf8.encode('plokee-msg-v1'),
    );
  }

  /// Encrypts a payload for a paired device. Returns base64(nonce|ct|mac).
  static Future<String> encrypt(Uint8List secret, String plaintext) async {
    final key = await _messageKey(secret);
    final box = await _aes.encrypt(utf8.encode(plaintext), secretKey: key);
    return base64Encode(box.concatenation());
  }

  /// Decrypts base64(nonce|ct|mac); throws on tampering.
  static Future<String> decrypt(Uint8List secret, String data) async {
    final key = await _messageKey(secret);
    final box = SecretBox.fromConcatenation(
      base64Decode(data),
      nonceLength: 12,
      macLength: 16,
    );
    final clear = await _aes.decrypt(box, secretKey: key);
    return utf8.decode(clear);
  }

  /// HMAC proof for the WebSocket handshake: mac(secret, nonce|deviceId).
  static Future<String> handshakeMac(
    Uint8List secret,
    String nonceBase64,
    String deviceId,
  ) async {
    final mac = await _hmac.calculateMac([
      ...base64Decode(nonceBase64),
      ...utf8.encode(deviceId),
    ], secretKey: SecretKey(secret));
    return base64Encode(mac.bytes);
  }

  static String randomNonceBase64([int length = 16]) {
    final rng = Random.secure();
    return base64Encode(List.generate(length, (_) => rng.nextInt(256)));
  }
}

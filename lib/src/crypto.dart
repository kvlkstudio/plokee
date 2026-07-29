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

  /// Derived message keys, kept per pairing secret.
  ///
  /// A streamed file is encrypted one chunk at a time, so this runs thousands
  /// of times per transfer; re-deriving through HKDF each time is pure waste.
  /// The map is keyed by the secret itself and therefore bounded by the number
  /// of paired devices.
  static final Map<String, SecretKey> _messageKeys = {};

  static Future<SecretKey> _messageKey(Uint8List secret) async {
    final cacheKey = base64Encode(secret);
    final cached = _messageKeys[cacheKey];
    if (cached != null) return cached;
    final hkdf = Hkdf(hmac: _hmac, outputLength: 32);
    final key = await hkdf.deriveKey(
      secretKey: SecretKey(secret),
      info: utf8.encode('plokee-msg-v1'),
    );
    _messageKeys[cacheKey] = key;
    return key;
  }

  /// Encrypts bytes for a paired device. Returns nonce|ct|mac.
  static Future<Uint8List> encryptBytes(
      Uint8List secret, List<int> clear) async {
    final key = await _messageKey(secret);
    final box = await _aes.encrypt(clear, secretKey: key);
    return Uint8List.fromList(box.concatenation());
  }

  /// Decrypts nonce|ct|mac; throws on tampering.
  static Future<Uint8List> decryptBytes(Uint8List secret, Uint8List box) async {
    final key = await _messageKey(secret);
    final secretBox = SecretBox.fromConcatenation(
      box,
      nonceLength: 12,
      macLength: 16,
    );
    return Uint8List.fromList(await _aes.decrypt(secretBox, secretKey: key));
  }

  /// Encrypts a payload for a paired device. Returns base64(nonce|ct|mac).
  static Future<String> encrypt(Uint8List secret, String plaintext) async =>
      base64Encode(await encryptBytes(secret, utf8.encode(plaintext)));

  /// Decrypts base64(nonce|ct|mac); throws on tampering.
  static Future<String> decrypt(Uint8List secret, String data) async =>
      utf8.decode(await decryptBytes(secret, base64Decode(data)));

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

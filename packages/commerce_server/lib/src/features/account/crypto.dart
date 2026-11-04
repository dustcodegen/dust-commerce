import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:cryptography/helpers.dart';

/// Raised when the server is already doing its safe amount of password work.
final class PasswordCapacityException implements Exception {
  /// Creates the admission-control signal.
  const PasswordCapacityException();
}

/// Bounds memory-hard password work instead of building an unbounded queue.
final class PasswordWorkLimiter {
  /// Creates a limiter for at most [maxConcurrent] Argon2 operations.
  PasswordWorkLimiter({this.maxConcurrent = 2})
      : assert(maxConcurrent > 0, 'maxConcurrent must be positive');

  /// Maximum Argon2 operations held in memory at once per server isolate.
  final int maxConcurrent;

  int _active = 0;

  /// Whether no password operation currently owns capacity.
  bool get isIdle => _active == 0;

  /// Runs admitted work, or rejects immediately so callers can return 429.
  Future<T> run<T>(Future<T> Function() work) async {
    if (_active >= maxConcurrent) throw const PasswordCapacityException();
    _active++;
    try {
      return await work();
    } finally {
      _active--;
    }
  }
}

/// Argon2id password hashing with a self-describing PHC value.
abstract final class Passwords {
  /// OWASP's minimum Argon2id memory cost: 19 MiB.
  static const int memoryKiB = 19 * 1024;

  /// OWASP's minimum at the selected memory cost.
  static const int iterations = 2;

  /// A single lane keeps the cost predictable on small servers.
  static const int parallelism = 1;

  static const int _hashLength = 32;
  static const int _saltLength = 16;
  static const String _prefix = r'$argon2id$v=19$m=19456,t=2,p=1$';

  static final Argon2id _algorithm = Argon2id(
    memory: memoryKiB,
    iterations: iterations,
    parallelism: parallelism,
    hashLength: _hashLength,
  );
  static final PasswordWorkLimiter _work = PasswordWorkLimiter();

  /// Hashes [password] with a fresh cryptographic salt.
  static Future<String> hash(
    String password, {
    PasswordWorkLimiter? limiter,
  }) =>
      (limiter ?? _work).run(() => _hash(password));

  static Future<String> _hash(String password) async {
    final salt = SecretKeyData.random(length: _saltLength).bytes;
    final derived = await _derive(password, salt);
    return '$_prefix${_encode(salt)}\$${_encode(derived)}';
  }

  /// Verifies [password] without data-dependent comparison timing.
  static Future<bool> verify(
    String password,
    String encoded, {
    PasswordWorkLimiter? limiter,
  }) =>
      (limiter ?? _work).run(() => _verify(password, encoded));

  static Future<bool> _verify(String password, String encoded) async {
    if (!encoded.startsWith(_prefix)) return false;
    final parts = encoded.split(r'$');
    if (parts.length != 6) return false;

    try {
      final salt = _decode(parts[4]);
      final expected = _decode(parts[5]);
      if (salt.length != _saltLength || expected.length != _hashLength) {
        return false;
      }
      final actual = await _derive(password, salt);
      return constantTimeBytesEquality.equals(actual, expected);
    } on FormatException {
      return false;
    }
  }

  static Future<List<int>> _derive(String password, List<int> salt) async {
    final key = await _algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
    return key.extractBytes();
  }

  static String _encode(List<int> bytes) =>
      base64.encode(bytes).replaceAll('=', '');

  static Uint8List _decode(String value) {
    final padded = value.padRight((value.length + 3) ~/ 4 * 4, '=');
    return base64.decode(padded);
  }
}

/// Secure opaque bearer-token creation and fingerprinting.
abstract final class Tokens {
  /// 256 bits of entropy.
  static const int entropyBytes = 32;

  /// Issues a token suitable for an Authorization header.
  static String issue() => base64Url
      .encode(SecretKeyData.random(length: entropyBytes).bytes)
      .replaceAll('=', '');

  /// Returns the SHA-256 value stored by the server.
  static Future<String> fingerprint(String token) async {
    final digest = await Sha256().hash(utf8.encode(token));
    return digest.bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}

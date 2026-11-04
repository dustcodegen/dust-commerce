import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A persisted customer session used only at the authorization boundary.
///
/// The raw token deliberately stays out of application state and serializable
/// response models so UI diagnostics cannot expose it accidentally.
final class StoredAuthSession {
  /// Creates a stored session.
  const StoredAuthSession({required this.token, required this.expiresAt});

  /// Restores a session from one atomic secure-storage value.
  factory StoredAuthSession.fromJson(Map<String, Object?> json) {
    final token = json['token'];
    final expiresAt = json['expires_at'];
    if (token is! String || token.isEmpty || expiresAt is! String) {
      throw const FormatException('Invalid stored customer session');
    }
    return StoredAuthSession(
      token: token,
      expiresAt: DateTime.parse(expiresAt).toUtc(),
    );
  }

  /// Opaque bearer credential, never written to logs or view-model state.
  final String token;

  /// Server-issued UTC expiry instant.
  final DateTime expiresAt;

  /// Whether this session can no longer authorize a request at [now].
  bool isExpiredAt(DateTime now) => !expiresAt.isAfter(now);

  Map<String, Object?> _toJson() => {
        'token': token,
        'expires_at': expiresAt.toIso8601String(),
      };
}

/// Persists the single customer authorization session.
abstract interface class AuthSessionStore {
  /// Reads the current session, if a complete value exists.
  Future<StoredAuthSession?> read();

  /// Atomically replaces the current session with [token].
  Future<void> write(IssuedToken token);

  /// Removes the local bearer credential.
  Future<void> clear();
}

/// Platform-secure customer-session persistence used by the production app.
final class SecureAuthSessionStore implements AuthSessionStore {
  /// Creates the secure store.
  SecureAuthSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(migrateWithBackup: true),
            );

  final FlutterSecureStorage _storage;

  static const _key = 'morrow.auth.session.v1';

  @override
  Future<void> clear() => _storage.delete(key: _key);

  @override
  Future<StoredAuthSession?> read() async {
    final encoded = await _storage.read(key: _key);
    if (encoded == null) return null;
    try {
      final json = jsonDecode(encoded);
      if (json is! Map<String, Object?>) {
        await clear();
        return null;
      }
      return StoredAuthSession.fromJson(json);
    } on FormatException {
      await clear();
      return null;
    }
  }

  @override
  Future<void> write(IssuedToken token) {
    final session = StoredAuthSession(
      token: token.token,
      expiresAt: token.expiresAt,
    );
    return _storage.write(key: _key, value: jsonEncode(session._toJson()));
  }
}

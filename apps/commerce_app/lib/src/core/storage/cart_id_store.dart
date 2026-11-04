import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists opaque cart capabilities without exposing storage details.
abstract interface class CartIdStore {
  /// Reads the cart capability belonging to [scope].
  Future<String?> read(String scope);

  /// Replaces the cart capability belonging to [scope].
  Future<void> write(String scope, String cartId);

  /// Removes an invalid or completed cart capability.
  Future<void> clear(String scope);
}

/// Platform-secure cart capability storage used by the production app.
final class SecureCartIdStore implements CartIdStore {
  /// Creates the secure store.
  SecureCartIdStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(migrateWithBackup: true),
            );

  final FlutterSecureStorage _storage;

  static String _key(String scope) => 'morrow.cart.$scope.v1';

  @override
  Future<void> clear(String scope) => _storage.delete(key: _key(scope));

  @override
  Future<String?> read(String scope) => _storage.read(key: _key(scope));

  @override
  Future<void> write(String scope, String cartId) =>
      _storage.write(key: _key(scope), value: cartId);
}

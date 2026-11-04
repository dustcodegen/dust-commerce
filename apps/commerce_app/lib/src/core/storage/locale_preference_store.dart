import 'package:dust_dart/fp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the storefront language independently of the customer session.
abstract interface class LocalePreferenceStore {
  /// Removes an explicit choice so the storefront uses its default locale.
  Future<void> clear();

  /// Reads the normalized locale code, when one was selected before.
  Future<Option<String>> read();

  /// Replaces the selected locale code.
  Future<void> write(String localeCode);
}

/// Durable locale preference used by the production storefront.
final class SecureLocalePreferenceStore implements LocalePreferenceStore {
  /// Creates the secure preference store.
  SecureLocalePreferenceStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(migrateWithBackup: true),
            );

  final FlutterSecureStorage _storage;

  static const _key = 'morrow.locale.v1';

  @override
  Future<void> clear() => _storage.delete(key: _key);

  @override
  Future<Option<String>> read() async {
    final value = (await _storage.read(key: _key))?.trim().toLowerCase();
    return value == null || value.isEmpty ? const None() : Some(value);
  }

  @override
  Future<void> write(String localeCode) => _storage.write(
        key: _key,
        value: localeCode.trim().toLowerCase(),
      );
}

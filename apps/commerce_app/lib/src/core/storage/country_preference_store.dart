import 'package:dust_dart/fp.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the storefront country without exposing its storage mechanism.
abstract interface class CountryPreferenceStore {
  /// Reads the normalized ISO country code, when one was selected before.
  Future<Option<String>> read();

  /// Replaces the selected ISO country code.
  Future<void> write(String countryCode);
}

/// Platform-secure country preference used by the production storefront.
final class SecureCountryPreferenceStore implements CountryPreferenceStore {
  /// Creates the secure preference store.
  SecureCountryPreferenceStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(migrateWithBackup: true),
            );

  final FlutterSecureStorage _storage;

  static const _key = 'morrow.country.v1';

  @override
  Future<Option<String>> read() async {
    final value = (await _storage.read(key: _key))?.trim().toLowerCase();
    return value == null || value.isEmpty ? const None() : Some(value);
  }

  @override
  Future<void> write(String countryCode) => _storage.write(
        key: _key,
        value: countryCode.trim().toLowerCase(),
      );
}

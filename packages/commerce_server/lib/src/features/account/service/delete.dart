import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/account/repository/repository.dart';
import 'package:dust_dart/db.dart';

/// Revokes a raw bearer token by deleting only its fingerprint.
Future<Result<ExecResult, SqlxError>> signOut(
  AccountDeleteRepository deletes,
  String token,
) async {
  return deletes.revokeToken(await Tokens.fingerprint(token));
}

/// Soft-deletes one address only when the authenticated customer owns it.
Future<Result<bool, SqlxError>> deleteCustomerAddress(
  AccountDeleteRepository deletes,
  String id,
  String customerId,
) async {
  final result = await deletes.deleteAddress(id, customerId);
  return switch (result) {
    Ok(value: final deleted) => Ok(deleted.rowsAffected == 1),
    Err(:final error) => Err(error),
  };
}

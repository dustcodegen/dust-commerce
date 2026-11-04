import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_server/src/features/account/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Resolves a raw bearer token without ever sending it to the database.
Future<Result<Option<CustomerResponse>, SqlxError>> authenticateToken(
  AccountReadRepository reads,
  String token,
  DateTime now,
) async {
  final found = await reads.customerForToken(
    await Tokens.fingerprint(token),
    now.toUtc().toIso8601String(),
  );
  return switch (found) {
    Ok(:final value) => Ok(optionOf<CustomerResponse>(value)),
    Err(:final error) => Err(error),
  };
}

import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Resolves a raw bearer token without sending it to persistence.
Future<Result<Option<AdminUserResponse>, SqlxError>> authenticateAdminToken(
  AdminReadRepository reads,
  String token,
  DateTime now,
) async {
  final found = await reads.adminForToken(
    await Tokens.fingerprint(token),
    now.toUtc().toIso8601String(),
  );
  return switch (found) {
    Ok(:final value) => Ok(optionOf<AdminUserResponse>(value)),
    Err(:final error) => Err(error),
  };
}

/// Reads one complete active product or [None] when [id] is unknown.
Future<Result<Option<AdminProductDetailResponse>, SqlxError>> readAdminProduct(
    AdminProductReadRepository products, String id) async {
  final result = await products.findById(id);
  return switch (result) {
    Ok(:final value) => Ok(optionOf<AdminProductDetailResponse>(value)),
    Err(:final error) => Err(error),
  };
}

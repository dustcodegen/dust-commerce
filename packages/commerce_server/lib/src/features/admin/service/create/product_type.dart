import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a product type could not be created.
enum AdminCreateProductTypeFailure {
  /// The normalized label is empty or too long.
  invalid,

  /// Another active type already owns the normalized label.
  valueConflict,
}

/// Creates one product type and returns its direct SQLx response row.
Future<
    Result<Result<AdminProductTypeResponse, AdminCreateProductTypeFailure>,
        SqlxError>> createAdminProductType(
  CommerceDatabase database,
  AdminCreateProductType input, {
  required String Function() nextId,
}) async {
  final value = input.value.trim();
  if (value.isEmpty || value.length > 255) {
    return const Ok(Err(AdminCreateProductTypeFailure.invalid));
  }
  final inserted = await AdminProductTypeCreateRepository(
    database.executor,
  ).insertProductType(nextId(), value);
  if (inserted case Err(:final error)) return Err(error);
  return switch (optionOf(
    (inserted as Ok<AdminProductTypeResponse?, SqlxError>).value,
  )) {
    Some(:final value) => Ok(Ok(value)),
    None() => const Ok(Err(AdminCreateProductTypeFailure.valueConflict)),
  };
}

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a product type could not be renamed.
enum AdminUpdateProductTypeFailure {
  /// The normalized replacement is empty or too long.
  invalid,

  /// No active product type owns the identifier.
  notFound,

  /// Another active type already owns the normalized label.
  valueConflict,
}

/// Replaces one product-type label atomically.
Future<
    Result<Result<AdminProductTypeResponse, AdminUpdateProductTypeFailure>,
        SqlxError>> updateAdminProductType(
  CommerceDatabase database,
  String id,
  AdminUpdateProductType input,
) async {
  final value = input.value.trim();
  if (value.isEmpty || value.length > 255) {
    return const Ok(Err(AdminUpdateProductTypeFailure.invalid));
  }
  return database.transaction((tx) async {
    final updated = await AdminProductTypeUpdateRepository(
      tx,
    ).updateProductType(id, value);
    if (updated case Err(:final error)) return Err(error);
    final changed = (updated as Ok<ExecResult, SqlxError>).value.rowsAffected;

    final current =
        await AdminProductTypeReadRepository(tx).findProductType(id);
    if (current case Err(:final error)) return Err(error);
    final row = optionOf(
      (current as Ok<AdminProductTypeResponse?, SqlxError>).value,
    );
    return switch (row) {
      Some(:final value) when changed == 1 => Ok(Ok(value)),
      Some() => const Ok(Err(AdminUpdateProductTypeFailure.valueConflict)),
      None() => const Ok(Err(AdminUpdateProductTypeFailure.notFound)),
    };
  });
}

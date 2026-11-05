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

/// Error crossing the Admin product-type update boundary.
sealed class AdminUpdateProductTypeError {
  /// Creates one product-type error.
  const AdminUpdateProductTypeError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminUpdateProductTypeRejected extends AdminUpdateProductTypeError {
  /// Creates one business rejection.
  const AdminUpdateProductTypeRejected(this.failure);

  /// The stable business reason.
  final AdminUpdateProductTypeFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminUpdateProductTypeStorage extends AdminUpdateProductTypeError {
  /// Creates one storage failure.
  const AdminUpdateProductTypeStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Replaces one product-type label atomically.
Future<Result<AdminProductTypeResponse, AdminUpdateProductTypeError>>
    updateAdminProductType(
  CommerceDatabase database,
  String id,
  AdminUpdateProductType input,
) async {
  final value = input.value.trim();
  if (value.isEmpty || value.length > 255) {
    return const Err(
      AdminUpdateProductTypeRejected(AdminUpdateProductTypeFailure.invalid),
    );
  }
  return transactionResult<AdminProductTypeResponse,
      AdminUpdateProductTypeError>(
    database,
    (tx) async {
      final updated = await AdminProductTypeUpdateRepository(
        tx,
      ).updateProductType(id, value);
      if (updated case Err(:final error)) {
        return Err(AdminUpdateProductTypeStorage(error));
      }
      final changed = (updated as Ok<ExecResult, SqlxError>).value.rowsAffected;

      final current =
          await AdminProductTypeReadRepository(tx).findProductType(id);
      if (current case Err(:final error)) {
        return Err(AdminUpdateProductTypeStorage(error));
      }
      final row = optionOf(
        (current as Ok<AdminProductTypeResponse?, SqlxError>).value,
      );
      return switch (row) {
        Some(:final value) when changed == 1 => Ok(value),
        Some() => const Err(
            AdminUpdateProductTypeRejected(
              AdminUpdateProductTypeFailure.valueConflict,
            ),
          ),
        None() => const Err(
            AdminUpdateProductTypeRejected(
              AdminUpdateProductTypeFailure.notFound,
            ),
          ),
      };
    },
    storageError: AdminUpdateProductTypeStorage.new,
  );
}

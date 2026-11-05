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

/// Error crossing the Admin product-type creation boundary.
sealed class AdminCreateProductTypeError {
  /// Creates one product-type error.
  const AdminCreateProductTypeError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminCreateProductTypeRejected extends AdminCreateProductTypeError {
  /// Creates one business rejection.
  const AdminCreateProductTypeRejected(this.failure);

  /// The stable business reason.
  final AdminCreateProductTypeFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminCreateProductTypeStorage extends AdminCreateProductTypeError {
  /// Creates one storage failure.
  const AdminCreateProductTypeStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Creates one product type and returns its direct SQLx response row.
Future<Result<AdminProductTypeResponse, AdminCreateProductTypeError>>
    createAdminProductType(
  CommerceDatabase database,
  AdminCreateProductType input, {
  required String Function() nextId,
}) async {
  final value = input.value.trim();
  if (value.isEmpty || value.length > 255) {
    return const Err(
      AdminCreateProductTypeRejected(AdminCreateProductTypeFailure.invalid),
    );
  }
  final inserted = await AdminProductTypeCreateRepository(
    database.executor,
  ).insertProductType(nextId(), value);
  if (inserted case Err(:final error)) {
    return Err(AdminCreateProductTypeStorage(error));
  }
  return switch (optionOf(
    (inserted as Ok<AdminProductTypeResponse?, SqlxError>).value,
  )) {
    Some(:final value) => Ok(value),
    None() => const Err(
        AdminCreateProductTypeRejected(
          AdminCreateProductTypeFailure.valueConflict,
        ),
      ),
  };
}

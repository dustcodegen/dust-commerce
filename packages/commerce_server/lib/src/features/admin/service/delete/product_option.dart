import 'package:commerce_server/src/features/admin/product_option_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a product option could not be retired.
enum AdminDeleteProductOptionFailure {
  /// No active option owns the identifier.
  notFound,

  /// One or more active products still expose the option.
  inUse,
}

/// Error crossing the Admin product-option deletion boundary.
sealed class AdminDeleteProductOptionError {
  /// Creates one product-option error.
  const AdminDeleteProductOptionError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminDeleteProductOptionRejected
    extends AdminDeleteProductOptionError {
  /// Creates one business rejection.
  const AdminDeleteProductOptionRejected(this.failure);

  /// The stable business reason.
  final AdminDeleteProductOptionFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminDeleteProductOptionStorage
    extends AdminDeleteProductOptionError {
  /// Creates one storage failure.
  const AdminDeleteProductOptionStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Atomically retires one option and its values when no product uses it.
Future<Result<void, AdminDeleteProductOptionError>> deleteAdminProductOption(
  CommerceDatabase database,
  String optionId,
) async {
  return transactionResult<void, AdminDeleteProductOptionError>(
    database,
    (tx) async {
      final reads = AdminProductOptionRepository(tx);
      final found = await reads.findById(optionId);
      if (found case Err(:final error)) {
        return Err(AdminDeleteProductOptionStorage(error));
      }
      final option = optionOf(
        (found as Ok<AdminProductOptionDetailResponse?, SqlxError>).value,
      );
      if (option case None()) {
        return const Err(
          AdminDeleteProductOptionRejected(
            AdminDeleteProductOptionFailure.notFound,
          ),
        );
      }

      final deletes = AdminProductOptionDeleteRepository(tx);
      final links = await deletes.linkedProductCount(optionId);
      if (links case Err(:final error)) {
        return Err(AdminDeleteProductOptionStorage(error));
      }
      if ((links as Ok<int, SqlxError>).value > 0) {
        return const Err(
          AdminDeleteProductOptionRejected(
            AdminDeleteProductOptionFailure.inUse,
          ),
        );
      }

      final values = await deletes.retireValues(optionId);
      if (values case Err(:final error)) {
        return Err(AdminDeleteProductOptionStorage(error));
      }
      final retired = await deletes.retireOption(optionId);
      if (retired case Err(:final error)) {
        return Err(AdminDeleteProductOptionStorage(error));
      }
      return (retired as Ok<ExecResult, SqlxError>).value.rowsAffected == 1
          ? const Ok(null)
          : const Err(
              AdminDeleteProductOptionRejected(
                AdminDeleteProductOptionFailure.notFound,
              ),
            );
    },
    storageError: AdminDeleteProductOptionStorage.new,
  );
}

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/product_option_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a global product option could not be created.
enum AdminCreateProductOptionFailure {
  /// The title or values are empty, too long, or duplicated.
  invalid,

  /// Another active global option already uses the requested title.
  titleConflict,

  /// The committed option could not be read back.
  unavailable,
}

/// Error crossing the Admin product-option creation boundary.
sealed class AdminCreateProductOptionError {
  /// Creates one product-option error.
  const AdminCreateProductOptionError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminCreateProductOptionRejected
    extends AdminCreateProductOptionError {
  /// Creates one business rejection.
  const AdminCreateProductOptionRejected(this.failure);

  /// The stable business reason.
  final AdminCreateProductOptionFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminCreateProductOptionStorage
    extends AdminCreateProductOptionError {
  /// Creates one storage failure.
  const AdminCreateProductOptionStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Creates one global product option and its values atomically.
Future<Result<AdminProductOptionDetailResponse, AdminCreateProductOptionError>>
    createAdminProductOption(
  CommerceDatabase database,
  AdminCreateProductOption input, {
  required String Function() nextId,
}) async {
  final title = input.title.trim();
  final values = input.values.map((value) => value.trim()).toList();
  if (!_validCreatedOption(title, values)) {
    return const Err(
      AdminCreateProductOptionRejected(AdminCreateProductOptionFailure.invalid),
    );
  }
  return transactionResult<AdminProductOptionDetailResponse,
      AdminCreateProductOptionError>(
    database,
    (tx) async {
      final options = AdminProductOptionRepository(tx);
      final writes = AdminProductOptionUpdateRepository(tx);
      final optionId = nextId();
      final inserted = await options.insert(optionId, title);
      if (inserted case Err(:final error)) {
        return Err(AdminCreateProductOptionStorage(error));
      }
      if ((inserted as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        return const Err(
          AdminCreateProductOptionRejected(
            AdminCreateProductOptionFailure.titleConflict,
          ),
        );
      }
      for (var rank = 0; rank < values.length; rank++) {
        final write = await writes.insertValue(
          nextId(),
          optionId,
          values[rank],
          rank,
        );
        if (write case Err(:final error)) {
          return Err(AdminCreateProductOptionStorage(error));
        }
      }
      final refreshed = await options.findById(optionId);
      if (refreshed case Err(:final error)) {
        return Err(AdminCreateProductOptionStorage(error));
      }
      return switch (optionOf(
        (refreshed as Ok<AdminProductOptionDetailResponse?, SqlxError>).value,
      )) {
        Some(:final value) => Ok(value),
        None() => const Err(AdminCreateProductOptionRejected(
            AdminCreateProductOptionFailure.unavailable,
          )),
      };
    },
    storageError: AdminCreateProductOptionStorage.new,
  );
}

bool _validCreatedOption(String title, List<String> values) =>
    title.isNotEmpty &&
    title.length <= 255 &&
    values.isNotEmpty &&
    values.every((value) => value.isNotEmpty && value.length <= 255) &&
    values.toSet().length == values.length;

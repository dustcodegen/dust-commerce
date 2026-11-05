import 'package:commerce_server/src/features/admin/product_import_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/service/create/import_document.dart';
import 'package:commerce_server/src/features/admin/service/create/import_preflight.dart';
import 'package:commerce_server/src/features/admin/service/create/import_prepared.dart';
import 'package:commerce_server/src/features/admin/service/create/import_relations.dart';
import 'package:commerce_server/src/features/admin/service/create/import_write.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Error crossing the Admin product-import confirmation boundary.
sealed class AdminProductImportConfirmError {
  /// Creates one product-import confirmation error.
  const AdminProductImportConfirmError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminProductImportConfirmRejected
    extends AdminProductImportConfirmError {
  /// Creates one business rejection.
  const AdminProductImportConfirmRejected(this.failure);

  /// The stable business reason.
  final AdminProductImportConfirmFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminProductImportConfirmStorage
    extends AdminProductImportConfirmError {
  /// Creates one storage failure.
  const AdminProductImportConfirmStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Atomically consumes one staged product import owned by an administrator.
Future<Result<void, AdminProductImportConfirmError>> confirmAdminProductImport(
  CommerceDatabase database, {
  required String transactionId,
  required String adminUserId,
  required DateTime now,
  required String Function() nextId,
}) =>
    transactionResult<void, AdminProductImportConfirmError>(
      database,
      (tx) async {
        final imports = AdminProductImportConfirmRepository(tx);
        final found = await imports.findImport(transactionId, adminUserId);
        if (found case Err(:final error)) {
          return Err(AdminProductImportConfirmStorage(error));
        }
        final staged = optionOf(
          (found as Ok<AdminProductImportRow?, SqlxError>).value,
        );
        if (staged case None()) {
          return const Err(AdminProductImportConfirmRejected(
            AdminProductImportConfirmFailure.notFound,
          ));
        }
        final import = (staged as Some<AdminProductImportRow>).value;
        if (import.status != 'pending') {
          return const Err(AdminProductImportConfirmRejected(
            AdminProductImportConfirmFailure.unavailable,
          ));
        }
        if (!now.toUtc().isBefore(import.expiresAt)) {
          final expired = await imports.expire(transactionId, adminUserId);
          if (expired case Err(:final error)) {
            return Err(AdminProductImportConfirmStorage(error));
          }
          return const Err(AdminProductImportConfirmRejected(
            AdminProductImportConfirmFailure.unavailable,
          ));
        }
        final decoded = decodeAdminProductImport(import.payloadJson);
        if (decoded case Err()) {
          return const Err(AdminProductImportConfirmRejected(
            AdminProductImportConfirmFailure.invalid,
          ));
        }
        final prepared = await preflightAdminProductImport(
          imports,
          (decoded as Ok<List<AdminImportedProduct>, String>).value,
          nextId: nextId,
        );
        if (prepared case Err(:final error)) {
          return Err(AdminProductImportConfirmStorage(error));
        }
        final outcome = (prepared as Ok<
                Result<List<PreparedImportedProduct>,
                    AdminProductImportConfirmFailure>,
                SqlxError>)
            .value;
        if (outcome case Err(:final error)) {
          return Err(AdminProductImportConfirmRejected(error));
        }
        final products = (outcome as Ok<List<PreparedImportedProduct>,
                AdminProductImportConfirmFailure>)
            .value;
        final productWrites = AdminProductImportProductRepository(tx);
        final variantWrites = AdminProductImportVariantRepository(tx);
        final relationWrites = AdminProductImportRelationRepository(tx);
        for (final product in products) {
          final core = await writeAdminImportedProduct(
            productWrites,
            variantWrites,
            product,
          );
          if (core case Err(:final error)) {
            return Err(AdminProductImportConfirmStorage(error));
          }
          final relations = await writeAdminImportedRelations(
            relationWrites,
            product,
            nextId: nextId,
          );
          if (relations case Err(:final error)) {
            return Err(AdminProductImportConfirmStorage(error));
          }
        }
        final completed = await imports.complete(transactionId, adminUserId);
        if (completed case Err(:final error)) {
          return Err(AdminProductImportConfirmStorage(error));
        }
        if ((completed as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
          return Err(AdminProductImportConfirmStorage(
            SqlxError.query('Product import was consumed concurrently'),
          ));
        }
        return const Ok(null);
      },
      storageError: AdminProductImportConfirmStorage.new,
    );

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

/// Atomically consumes one staged product import owned by an administrator.
Future<Result<Result<void, AdminProductImportConfirmFailure>, SqlxError>>
    confirmAdminProductImport(
  CommerceDatabase database, {
  required String transactionId,
  required String adminUserId,
  required DateTime now,
  required String Function() nextId,
}) =>
        database.transaction((tx) async {
          final imports = AdminProductImportConfirmRepository(tx);
          final found = await imports.findImport(transactionId, adminUserId);
          if (found case Err(:final error)) return Err(error);
          final staged = optionOf(
            (found as Ok<AdminProductImportRow?, SqlxError>).value,
          );
          if (staged case None()) {
            return const Ok(Err(AdminProductImportConfirmFailure.notFound));
          }
          final import = (staged as Some<AdminProductImportRow>).value;
          if (import.status != 'pending') {
            return const Ok(Err(AdminProductImportConfirmFailure.unavailable));
          }
          if (!now.toUtc().isBefore(import.expiresAt)) {
            final expired = await imports.expire(transactionId, adminUserId);
            if (expired case Err(:final error)) return Err(error);
            return const Ok(Err(AdminProductImportConfirmFailure.unavailable));
          }
          final decoded = decodeAdminProductImport(import.payloadJson);
          if (decoded case Err()) {
            return const Ok(Err(AdminProductImportConfirmFailure.invalid));
          }
          final prepared = await preflightAdminProductImport(
            imports,
            (decoded as Ok<List<AdminImportedProduct>, String>).value,
            nextId: nextId,
          );
          if (prepared case Err(:final error)) return Err(error);
          final outcome = (prepared as Ok<
                  Result<List<PreparedImportedProduct>,
                      AdminProductImportConfirmFailure>,
                  SqlxError>)
              .value;
          if (outcome case Err(:final error)) return Ok(Err(error));
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
            if (core case Err(:final error)) return Err(error);
            final relations = await writeAdminImportedRelations(
              relationWrites,
              product,
              nextId: nextId,
            );
            if (relations case Err(:final error)) return Err(error);
          }
          final completed = await imports.complete(transactionId, adminUserId);
          if (completed case Err(:final error)) return Err(error);
          if ((completed as Ok<ExecResult, SqlxError>).value.rowsAffected !=
              1) {
            return Err(
              SqlxError.query('Product import was consumed concurrently'),
            );
          }
          return const Ok(Ok(null));
        });

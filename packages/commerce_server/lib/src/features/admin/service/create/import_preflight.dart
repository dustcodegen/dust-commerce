import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/product_import_model.dart';
import 'package:commerce_server/src/features/admin/service/create/import_document.dart';
import 'package:commerce_server/src/features/admin/service/create/import_prepared.dart';
import 'package:commerce_server/src/features/admin/service/create/import_variant_preflight.dart';
import 'package:dust_dart/db.dart';

/// Error crossing the Admin product-import preflight boundary.
sealed class AdminProductImportPreflightError {
  /// Creates one product-import preflight error.
  const AdminProductImportPreflightError();
}

/// A business rejection that is safe to expose to confirmation.
final class AdminProductImportPreflightRejected
    extends AdminProductImportPreflightError {
  /// Creates one business rejection.
  const AdminProductImportPreflightRejected(this.failure);

  /// The stable business reason.
  final AdminProductImportConfirmFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminProductImportPreflightStorage
    extends AdminProductImportPreflightError {
  /// Creates one storage failure.
  const AdminProductImportPreflightStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Re-checks every identity and reference before the first catalogue write.
Future<Result<List<PreparedImportedProduct>, AdminProductImportPreflightError>>
    preflightAdminProductImport(
  AdminProductImportConfirmRepository reads,
  List<AdminImportedProduct> products, {
  required String Function() nextId,
}) async {
  final currenciesResult = await reads.activeCurrencies();
  if (currenciesResult case Err(:final error)) {
    return Err(AdminProductImportPreflightStorage(error));
  }
  final currencies =
      (currenciesResult as Ok<List<AdminProductImportCurrencyRow>, SqlxError>)
          .value
          .map((row) => row.currencyCode)
          .toSet();
  final productIds = <String>{};
  final variantIds = <String>{};
  final skus = <String>{};
  final prepared = <PreparedImportedProduct>[];
  for (final product in products) {
    final row = product.row;
    final incomingId = row['Product Id']!;
    final matchesResult =
        await reads.findProducts(incomingId, row['Product Handle']!);
    if (matchesResult case Err(:final error)) {
      return Err(AdminProductImportPreflightStorage(error));
    }
    final matches =
        (matchesResult as Ok<List<AdminProductImportIdentityRow>, SqlxError>)
            .value;
    if (matches.length > 1 ||
        (incomingId.isEmpty && matches.isNotEmpty) ||
        (incomingId.isNotEmpty &&
            (matches.length != 1 ||
                matches.single.id != incomingId ||
                matches.single.handle != row['Product Handle']))) {
      return const Err(AdminProductImportPreflightRejected(
        AdminProductImportConfirmFailure.conflict,
      ));
    }
    final productId = incomingId.isEmpty ? nextId() : incomingId;
    if (!productIds.add(productId)) {
      return const Err(AdminProductImportPreflightRejected(
        AdminProductImportConfirmFailure.invalid,
      ));
    }
    final references = await _validReferences(reads, row);
    if (references case Err(:final error)) {
      return Err(AdminProductImportPreflightStorage(error));
    }
    if (!(references as Ok<bool, SqlxError>).value) {
      return const Err(AdminProductImportPreflightRejected(
        AdminProductImportConfirmFailure.invalid,
      ));
    }
    final variants = <PreparedImportedVariant>[];
    for (final variantRow in product.variantRows) {
      final resolved = await prepareImportedVariant(
        reads,
        variantRow,
        productId,
        currencies,
        nextId,
      );
      if (resolved case Err(:final error)) {
        return switch (error) {
          AdminProductImportVariantPreflightStorage(:final cause) =>
            Err(AdminProductImportPreflightStorage(cause)),
          AdminProductImportVariantPreflightRejected(:final failure) =>
            Err(AdminProductImportPreflightRejected(failure)),
        };
      }
      final variant = (resolved as Ok<PreparedImportedVariant,
              AdminProductImportVariantPreflightError>)
          .value;
      final sku = variant.row.optional('Variant SKU');
      if (!variantIds.add(variant.id) || (sku != null && !skus.add(sku))) {
        return const Err(AdminProductImportPreflightRejected(
          AdminProductImportConfirmFailure.invalid,
        ));
      }
      variants.add(variant);
    }
    if (variants.isEmpty ||
        (matches.isEmpty &&
            variants.any(
                (variant) => !currencies.every(variant.prices.containsKey)))) {
      return const Err(AdminProductImportPreflightRejected(
        AdminProductImportConfirmFailure.invalid,
      ));
    }
    prepared.add(PreparedImportedProduct(
      id: productId,
      exists: matches.isNotEmpty,
      row: row,
      variants: variants,
    ));
  }
  return Ok(prepared);
}

Future<Result<bool, SqlxError>> _validReferences(
  AdminProductImportConfirmRepository reads,
  Map<String, String> row,
) async {
  final typeId = row.optional('Product Type Id');
  if (typeId != null) {
    final count = await reads.activeTypeCount(typeId);
    if (count case Err(:final error)) return Err(error);
    if ((count as Ok<int, SqlxError>).value != 1) return const Ok(false);
  }
  final collectionId = row.optional('Product Collection Id');
  if (collectionId != null) {
    final count = await reads.activeCollectionCount(collectionId);
    if (count case Err(:final error)) return Err(error);
    if ((count as Ok<int, SqlxError>).value != 1) return const Ok(false);
  }
  return const Ok(true);
}

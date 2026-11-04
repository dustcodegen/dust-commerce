import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/product_import_model.dart';
import 'package:commerce_server/src/features/admin/service/create/import_document.dart';
import 'package:commerce_server/src/features/admin/service/create/import_prepared.dart';
import 'package:commerce_server/src/features/admin/service/create/import_variant_preflight.dart';
import 'package:dust_dart/db.dart';

/// Re-checks every identity and reference before the first catalogue write.
Future<
    Result<
        Result<List<PreparedImportedProduct>, AdminProductImportConfirmFailure>,
        SqlxError>> preflightAdminProductImport(
  AdminProductImportConfirmRepository reads,
  List<AdminImportedProduct> products, {
  required String Function() nextId,
}) async {
  final currenciesResult = await reads.activeCurrencies();
  if (currenciesResult case Err(:final error)) return Err(error);
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
    if (matchesResult case Err(:final error)) return Err(error);
    final matches =
        (matchesResult as Ok<List<AdminProductImportIdentityRow>, SqlxError>)
            .value;
    if (matches.length > 1 ||
        (incomingId.isEmpty && matches.isNotEmpty) ||
        (incomingId.isNotEmpty &&
            (matches.length != 1 ||
                matches.single.id != incomingId ||
                matches.single.handle != row['Product Handle']))) {
      return const Ok(Err(AdminProductImportConfirmFailure.conflict));
    }
    final productId = incomingId.isEmpty ? nextId() : incomingId;
    if (!productIds.add(productId)) {
      return const Ok(Err(AdminProductImportConfirmFailure.invalid));
    }
    final references = await _validReferences(reads, row);
    if (references case Err(:final error)) return Err(error);
    if (!(references as Ok<bool, SqlxError>).value) {
      return const Ok(Err(AdminProductImportConfirmFailure.invalid));
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
      if (resolved case Err(:final error)) return Err(error);
      final outcome = (resolved as Ok<
              Result<PreparedImportedVariant, AdminProductImportConfirmFailure>,
              SqlxError>)
          .value;
      if (outcome case Err(:final error)) return Ok(Err(error));
      final variant = (outcome
              as Ok<PreparedImportedVariant, AdminProductImportConfirmFailure>)
          .value;
      final sku = variant.row.optional('Variant SKU');
      if (!variantIds.add(variant.id) || (sku != null && !skus.add(sku))) {
        return const Ok(Err(AdminProductImportConfirmFailure.invalid));
      }
      variants.add(variant);
    }
    if (variants.isEmpty ||
        (matches.isEmpty &&
            variants.any(
                (variant) => !currencies.every(variant.prices.containsKey)))) {
      return const Ok(Err(AdminProductImportConfirmFailure.invalid));
    }
    prepared.add(PreparedImportedProduct(
      id: productId,
      exists: matches.isNotEmpty,
      row: row,
      variants: variants,
    ));
  }
  return Ok(Ok(prepared));
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

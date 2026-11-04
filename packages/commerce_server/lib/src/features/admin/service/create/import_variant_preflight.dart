import 'package:commerce_server/src/features/admin/product_import_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/service/create/import_document.dart';
import 'package:commerce_server/src/features/admin/service/create/import_money.dart';
import 'package:commerce_server/src/features/admin/service/create/import_prepared.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Resolves and validates one imported variant before catalogue writes begin.
Future<
    Result<Result<PreparedImportedVariant, AdminProductImportConfirmFailure>,
        SqlxError>> prepareImportedVariant(
  AdminProductImportConfirmRepository reads,
  Map<String, String> row,
  String productId,
  Set<String> activeCurrencies,
  String Function() nextId,
) async {
  final incomingId = row.optional('Variant Id');
  Option<AdminProductImportVariantRow> existing = const None();
  if (incomingId != null) {
    final found = await reads.findVariant(incomingId);
    if (found case Err(:final error)) return Err(error);
    existing = optionOf(
      (found as Ok<AdminProductImportVariantRow?, SqlxError>).value,
    );
    if (existing case None()) {
      return const Ok(Err(AdminProductImportConfirmFailure.conflict));
    }
    if ((existing as Some<AdminProductImportVariantRow>).value.productId !=
        productId) {
      return const Ok(Err(AdminProductImportConfirmFailure.conflict));
    }
  }
  final sku = row.optional('Variant SKU');
  if (sku != null) {
    final owner = await reads.findSkuOwner(sku, incomingId ?? '');
    if (owner case Err(:final error)) return Err(error);
    if (optionOf(
      (owner as Ok<AdminProductImportVariantRow?, SqlxError>).value,
    )
        case Some()) {
      return const Ok(Err(AdminProductImportConfirmFailure.conflict));
    }
  }
  final prices = <String, int>{};
  for (final entry in row.entries) {
    if (!entry.key.startsWith('Variant Price ') || entry.value.isEmpty) {
      continue;
    }
    final currency = entry.key.substring('Variant Price '.length).toLowerCase();
    final amount = adminImportMinorUnits(entry.value, currency);
    if (!activeCurrencies.contains(currency) || amount == null) {
      return const Ok(Err(AdminProductImportConfirmFailure.invalid));
    }
    prices[currency] = amount;
  }
  return Ok(Ok(PreparedImportedVariant(
    id: incomingId ?? nextId(),
    exists: existing is Some<AdminProductImportVariantRow>,
    row: row,
    prices: prices,
  )));
}

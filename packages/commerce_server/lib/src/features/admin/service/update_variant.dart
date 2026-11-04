import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a valid variant update could not be applied.
enum AdminUpdateVariantFailure {
  /// The product or variant is not active under the requested identifiers.
  notFound,

  /// A selection is missing, unknown, or duplicates another variant.
  invalidOptions,

  /// Another active variant already owns the requested SKU.
  skuConflict,

  /// The committed product could not be read back.
  unavailable,
}

/// Atomically replaces Medusa's variant-detail fields and returns fresh detail.
Future<
    Result<Result<AdminProductDetailResponse, AdminUpdateVariantFailure>,
        SqlxError>> updateAdminProductVariant(
  CommerceDatabase database,
  String productId,
  String variantId,
  AdminUpdateProductVariant input,
) =>
    database.transaction((tx) async {
      final reads = AdminProductReadRepository(tx);
      final found = await reads.findById(productId);
      if (found case Err(:final error)) return Err(error);
      final product = optionOf(
        (found as Ok<AdminProductDetailResponse?, SqlxError>).value,
      );
      if (product case None()) {
        return const Ok(Err(AdminUpdateVariantFailure.notFound));
      }
      final detail = (product as Some<AdminProductDetailResponse>).value;
      final variant = _variant(detail.variants, variantId);
      if (variant case None()) {
        return const Ok(Err(AdminUpdateVariantFailure.notFound));
      }
      final selections = _prepareSelections(detail, variantId, input);
      if (selections case None()) {
        return const Ok(Err(AdminUpdateVariantFailure.invalidOptions));
      }

      final writes = AdminVariantUpdateRepository(tx);
      final valueIds = <String, String>{};
      for (final selection
          in (selections as Some<Map<String, String>>).value.entries) {
        final result = await writes.optionValueId(
          productId,
          selection.key,
          selection.value,
        );
        if (result case Err(:final error)) return Err(error);
        final id = optionOf((result as Ok<String?, SqlxError>).value);
        if (id case None()) {
          return const Ok(Err(AdminUpdateVariantFailure.invalidOptions));
        }
        valueIds[selection.key] = (id as Some<String>).value;
      }

      final updated = await writes.updateVariant(
        variantId,
        productId,
        input.title,
        input.sku,
        input.material,
        input.ean,
        input.upc,
        input.barcode,
        input.weight,
        input.width,
        input.length,
        input.height,
        input.midCode,
        input.hsCode,
        input.originCountry,
        input.manageInventory ? 1 : 0,
        input.allowBackorder ? 1 : 0,
      );
      if (updated case Err(:final error)) return Err(error);
      if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
        return const Ok(Err(AdminUpdateVariantFailure.skuConflict));
      }
      for (final selection in valueIds.entries) {
        final linked = await writes.upsertOptionValue(
          variantId,
          selection.key,
          selection.value,
        );
        if (linked case Err(:final error)) return Err(error);
      }

      final refreshed = await reads.findById(productId);
      if (refreshed case Err(:final error)) return Err(error);
      return switch (optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      )) {
        Some(:final value) => Ok(Ok(value)),
        None() => const Ok(Err(AdminUpdateVariantFailure.unavailable)),
      };
    });

Option<AdminProductVariant> _variant(
  List<AdminProductVariant> variants,
  String id,
) {
  for (final variant in variants) {
    if (variant.id == id) return Some(variant);
  }
  return const None();
}

Option<Map<String, String>> _prepareSelections(
  AdminProductDetailResponse product,
  String variantId,
  AdminUpdateProductVariant input,
) {
  final selections = {
    for (final entry in input.optionValues.entries)
      entry.key.trim(): entry.value.trim(),
  };
  if (selections.length != product.options.length) return const None();
  for (final option in product.options) {
    final value = selections[option.id];
    if (value == null || !option.values.contains(value)) return const None();
  }
  for (final variant in product.variants) {
    if (variant.id != variantId &&
        _sameSelections(variant.optionValues, selections)) {
      return const None();
    }
  }
  return Some(selections);
}

bool _sameSelections(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length) return false;
  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) return false;
  }
  return true;
}

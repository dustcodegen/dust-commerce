import 'package:commerce_server/src/features/admin/product_import_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/service/create/import_document.dart';
import 'package:commerce_server/src/features/admin/service/create/import_prepared.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Replaces imported product relations and upserts variant selections/prices.
Future<Result<void, SqlxError>> writeAdminImportedRelations(
  AdminProductImportRelationRepository writes,
  PreparedImportedProduct product, {
  required String Function() nextId,
}) async {
  final row = product.row;
  if (row.keys.any((key) => key.startsWith('Product Image '))) {
    final retired = await writes.retireImages(product.id);
    if (retired case Err(:final error)) return Err(error);
    final images = row.numbered('Product Image ', ' Url');
    for (var rank = 0; rank < images.length; rank++) {
      final image = await writes.insertImage(
        nextId(),
        product.id,
        images[rank],
        rank,
      );
      if (image case Err(:final error)) return Err(error);
    }
  }
  if (row.keys.any((key) => key.startsWith('Product Tag '))) {
    final cleared = await writes.clearTags(product.id);
    if (cleared case Err(:final error)) return Err(error);
    for (final value in row.numbered('Product Tag ', '')) {
      final tagId = await _tag(writes, value, nextId);
      if (tagId case Err(:final error)) return Err(error);
      final link = await writes.linkTag(
        product.id,
        (tagId as Ok<String, SqlxError>).value,
      );
      if (link case Err(:final error)) return Err(error);
    }
  }
  for (final variant in product.variants) {
    for (var index = 1; index <= 100; index++) {
      final title = variant.row['Variant Option $index Name'] ?? '';
      final value = variant.row['Variant Option $index Value'] ?? '';
      if (title.isEmpty) continue;
      final selection = await _upsertSelection(
        writes,
        product.id,
        variant.id,
        title,
        value,
        nextId,
      );
      if (selection case Err(:final error)) return Err(error);
    }
    for (final price in variant.prices.entries) {
      final stored = await writes.upsertPrice(
        variant.id,
        price.key,
        price.value,
      );
      if (stored case Err(:final error)) return Err(error);
    }
  }
  return const Ok(null);
}

Future<Result<String, SqlxError>> _tag(
  AdminProductImportRelationRepository writes,
  String value,
  String Function() nextId,
) async {
  final found = await writes.findTag(value);
  if (found case Err(:final error)) return Err(error);
  final existing = optionOf(
    (found as Ok<AdminProductImportIdRow?, SqlxError>).value,
  );
  if (existing case Some(value: final row)) return Ok(row.id);
  final id = nextId();
  final inserted = await writes.insertTag(id, value);
  if (inserted case Err(:final error)) return Err(error);
  return Ok(id);
}

Future<Result<void, SqlxError>> _upsertSelection(
  AdminProductImportRelationRepository writes,
  String productId,
  String variantId,
  String title,
  String value,
  String Function() nextId,
) async {
  final optionId = await _option(writes, productId, title, nextId);
  if (optionId case Err(:final error)) return Err(error);
  final option = (optionId as Ok<String, SqlxError>).value;
  final linkResult = await writes.findProductOption(productId, option);
  if (linkResult case Err(:final error)) return Err(error);
  final link = optionOf(
    (linkResult as Ok<AdminProductImportIdRow?, SqlxError>).value,
  );
  if (link is! Some<AdminProductImportIdRow>) {
    return Err(
      SqlxError.query('Imported product option link is missing'),
    );
  }
  final valueId = await _optionValue(writes, option, value, nextId);
  if (valueId case Err(:final error)) return Err(error);
  final selected = (valueId as Ok<String, SqlxError>).value;
  final available = await writes.linkProductOptionValue(
    nextId(),
    link.value.id,
    selected,
  );
  if (available case Err(:final error)) return Err(error);
  final selection =
      await writes.upsertVariantOptionValue(variantId, option, selected);
  if (selection case Err(:final error)) return Err(error);
  return const Ok(null);
}

Future<Result<String, SqlxError>> _option(
  AdminProductImportRelationRepository writes,
  String productId,
  String title,
  String Function() nextId,
) async {
  final found = await writes.findOption(productId, title);
  if (found case Err(:final error)) return Err(error);
  final existing = optionOf(
    (found as Ok<AdminProductImportIdRow?, SqlxError>).value,
  );
  if (existing case Some(value: final row)) return Ok(row.id);
  final optionId = nextId();
  final linkId = nextId();
  final inserted = await writes.insertOption(optionId, title);
  if (inserted case Err(:final error)) return Err(error);
  final linked = await writes.insertProductOption(linkId, productId, optionId);
  if (linked case Err(:final error)) return Err(error);
  return Ok(optionId);
}

Future<Result<String, SqlxError>> _optionValue(
  AdminProductImportRelationRepository writes,
  String optionId,
  String value,
  String Function() nextId,
) async {
  final found = await writes.findOptionValue(optionId, value);
  if (found case Err(:final error)) return Err(error);
  final existing = optionOf(
    (found as Ok<AdminProductImportIdRow?, SqlxError>).value,
  );
  if (existing case Some(value: final row)) return Ok(row.id);
  final rank = await writes.nextOptionValueRank(optionId);
  if (rank case Err(:final error)) return Err(error);
  final id = nextId();
  final inserted = await writes.insertOptionValue(
    id,
    optionId,
    value,
    (rank as Ok<int, SqlxError>).value,
  );
  if (inserted case Err(:final error)) return Err(error);
  return Ok(id);
}

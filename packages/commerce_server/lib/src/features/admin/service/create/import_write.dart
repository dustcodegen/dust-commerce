import 'dart:convert';

import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/service/create/import_document.dart';
import 'package:commerce_server/src/features/admin/service/create/import_prepared.dart';
import 'package:dust_dart/db.dart';

/// Writes imported product and variant core records after complete preflight.
Future<Result<void, SqlxError>> writeAdminImportedProduct(
  AdminProductImportProductRepository products,
  AdminProductImportVariantRepository variants,
  PreparedImportedProduct product,
) async {
  final row = product.row;
  final productWrite = product.exists
      ? products.updateProduct(
          product.id,
          jsonEncode(_productFields(row)),
        )
      : products.insertProduct(
          product.id,
          row.optional('Product Collection Id'),
          row['Product Title']!,
          row.optional('Product Subtitle'),
          row['Product Handle']!,
          row.optional('Product Description'),
          row.boolean('Product Discountable', defaultValue: true) ? 1 : 0,
          row.optional('Product Thumbnail'),
          row.optional('Product Material'),
          row.optional('Product Origin Country'),
          row.optional('Product Type Id'),
          row.integer('Product Weight'),
          row.integer('Product Length'),
          row.integer('Product Width'),
          row.integer('Product Height'),
          row.optional('Product Status') ?? 'draft',
        );
  final shell = await productWrite;
  if (shell case Err(:final error)) return Err(error);
  if ((shell as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
    return Err(
      SqlxError.query('Imported product write did not affect one row'),
    );
  }
  for (final variant in product.variants) {
    final variantRow = variant.row;
    final write = variant.exists
        ? variants.updateVariant(
            variant.id,
            product.id,
            jsonEncode(_variantFields(variantRow)),
          )
        : variants.insertVariant(
            variant.id,
            product.id,
            variantRow['Variant Title']!,
            variantRow.optional('Variant Material'),
            variantRow.optional('Variant SKU'),
            variantRow.optional('Variant Barcode'),
            variantRow.boolean('Variant Manage Inventory', defaultValue: true)
                ? 1
                : 0,
            variantRow.boolean('Variant Allow Backorder', defaultValue: false)
                ? 1
                : 0,
            variantRow.integer('Variant Weight'),
            variantRow.integer('Variant Width'),
            variantRow.integer('Variant Length'),
            variantRow.integer('Variant Height'),
            variantRow.optional('Variant MID Code'),
            variantRow.optional('Variant HS Code'),
            variantRow.optional('Variant Origin Country'),
          );
    final outcome = await write;
    if (outcome case Err(:final error)) return Err(error);
    if ((outcome as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return Err(
        SqlxError.query('Imported variant write did not affect one row'),
      );
    }
  }
  return const Ok(null);
}

Map<String, Object?> _productFields(Map<String, String> row) => {
      'title': row['Product Title']!,
      'handle': row['Product Handle']!,
      if (row.containsKey('Product Collection Id'))
        'collection_id': row.optional('Product Collection Id'),
      if (row.containsKey('Product Subtitle'))
        'subtitle': row.optional('Product Subtitle'),
      if (row.containsKey('Product Description'))
        'description': row.optional('Product Description'),
      if (row.containsKey('Product Discountable'))
        'discountable':
            row.boolean('Product Discountable', defaultValue: true) ? 1 : 0,
      if (row.containsKey('Product Thumbnail'))
        'thumbnail': row.optional('Product Thumbnail'),
      if (row.containsKey('Product Material'))
        'material': row.optional('Product Material'),
      if (row.containsKey('Product Origin Country'))
        'origin_country': row.optional('Product Origin Country'),
      if (row.containsKey('Product Type Id'))
        'type_id': row.optional('Product Type Id'),
      if (row.containsKey('Product Weight'))
        'weight': row.integer('Product Weight'),
      if (row.containsKey('Product Length'))
        'length': row.integer('Product Length'),
      if (row.containsKey('Product Width'))
        'width': row.integer('Product Width'),
      if (row.containsKey('Product Height'))
        'height': row.integer('Product Height'),
      if (row.containsKey('Product Status'))
        'status': row.optional('Product Status') ?? 'draft',
    };

Map<String, Object?> _variantFields(Map<String, String> row) => {
      'title': row['Variant Title']!,
      if (row.containsKey('Variant Material'))
        'material': row.optional('Variant Material'),
      if (row.containsKey('Variant SKU')) 'sku': row.optional('Variant SKU'),
      if (row.containsKey('Variant Barcode'))
        'barcode': row.optional('Variant Barcode'),
      if (row.containsKey('Variant Manage Inventory'))
        'manage_inventory':
            row.boolean('Variant Manage Inventory', defaultValue: true) ? 1 : 0,
      if (row.containsKey('Variant Allow Backorder'))
        'allow_backorder':
            row.boolean('Variant Allow Backorder', defaultValue: false) ? 1 : 0,
      if (row.containsKey('Variant Weight'))
        'weight': row.integer('Variant Weight'),
      if (row.containsKey('Variant Width'))
        'width': row.integer('Variant Width'),
      if (row.containsKey('Variant Length'))
        'length': row.integer('Variant Length'),
      if (row.containsKey('Variant Height'))
        'height': row.integer('Variant Height'),
      if (row.containsKey('Variant MID Code'))
        'mid_code': row.optional('Variant MID Code'),
      if (row.containsKey('Variant HS Code'))
        'hs_code': row.optional('Variant HS Code'),
      if (row.containsKey('Variant Origin Country'))
        'origin_country': row.optional('Variant Origin Country'),
    };

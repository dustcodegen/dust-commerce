import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

/// Writes the Medusa-compatible product import template to a chosen location.
Future<bool> saveAdminProductImportTemplate() async {
  const name = 'product-import-template.csv';
  final location = await getSaveLocation(
    suggestedName: name,
    acceptedTypeGroups: const [
      XTypeGroup(label: 'CSV', extensions: ['csv'], mimeTypes: ['text/csv']),
    ],
  );
  if (location == null) return false;
  final file = XFile.fromData(
    Uint8List.fromList(utf8.encode(adminProductImportTemplate)),
    mimeType: 'text/csv',
    name: name,
  );
  await file.saveTo(location.path);
  return true;
}

/// Header-only template matching Medusa's product import contract.
const adminProductImportTemplate =
    'Product Id,Product Handle,Product Title,Product Subtitle,'
    'Product Description,Product Status,Product Thumbnail,Product Weight,'
    'Product Length,Product Width,Product Height,Product HS Code,'
    'Product Origin Country,Product MID Code,Product Material,'
    'Shipping Profile Id,Product Sales Channel 1,Product Collection Id,'
    'Product Type Id,Product Tag 1,Product Discountable,Product External Id,'
    'Variant Id,Variant Title,Variant SKU,Variant Barcode,'
    'Variant Allow Backorder,Variant Manage Inventory,Variant Weight,'
    'Variant Length,Variant Width,Variant Height,Variant HS Code,'
    'Variant Origin Country,Variant MID Code,Variant Material,'
    'Variant Price EUR,Variant Price USD,Variant Option 1 Name,'
    'Variant Option 1 Value,Product Image 1 Url,Product Image 2 Url\r\n';

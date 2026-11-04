import 'dart:convert';

import 'support.dart';

/// Previews [csv] and returns its staged transaction id.
Future<String> previewProductImport(
  AdminHarness harness,
  String token,
  String csv,
) async {
  final request = harness.client.post('/admin/products/import')
    ..bearer(token)
    ..bytes(
      utf8.encode(
        '--import\r\n'
        'Content-Disposition: form-data; name="file"; '
        'filename="products.csv"\r\n'
        'Content-Type: text/csv\r\n\r\n'
        '$csv\r\n--import--\r\n',
      ),
      contentType: 'multipart/form-data; boundary=import',
    );
  final response = await request.send();
  response.assertOk();
  return (response.json! as Map<String, Object?>)['transaction_id']! as String;
}

/// Complete create-and-update fixture.
final String completeProductImportCsv = _csv([
  _tee,
  _cap('Small', 'CAP-S', '18.00', '16.00'),
  _cap('Large', 'CAP-L', '20.00', '18.00'),
]);

/// One valid new product fixture.
final String newOnlyProductImportCsv =
    _csv([_cap('One size', 'NEW-CAP', '18.00', '16.00')]);

/// One new product that conflicts with an active SKU.
final String conflictingSkuProductImportCsv = _csv([
  _cap('One size', 'TSHIRT-S-BLACK', '18.00', '16.00', handle: 'bad-sku'),
]);

/// External storefront fixture images.
const importedCapFront = 'https://example.test/imported-cap-front.png';
const importedCapBack = 'https://example.test/imported-cap-back.png';

String _csv(List<Map<String, String>> rows) => '${[
      _headers,
      for (final row in rows)
        [for (final header in _headers) row[header] ?? ''],
    ].map((row) => row.join(',')).join('\r\n')}\r\n';

const _headers = [
  'Product Id',
  'Product Handle',
  'Product Title',
  'Product Subtitle',
  'Product Description',
  'Product Status',
  'Product Thumbnail',
  'Product Weight',
  'Product Length',
  'Product Width',
  'Product Height',
  'Product Origin Country',
  'Product Material',
  'Product Collection Id',
  'Product Type Id',
  'Product Tag 1',
  'Product Discountable',
  'Variant Id',
  'Variant Title',
  'Variant SKU',
  'Variant Barcode',
  'Variant Allow Backorder',
  'Variant Manage Inventory',
  'Variant Weight',
  'Variant Length',
  'Variant Width',
  'Variant Height',
  'Variant HS Code',
  'Variant Origin Country',
  'Variant MID Code',
  'Variant Material',
  'Variant Price EUR',
  'Variant Price USD',
  'Variant Option 1 Name',
  'Variant Option 1 Value',
  'Variant Option 2 Name',
  'Variant Option 2 Value',
  'Product Image 1 Url',
  'Product Image 2 Url',
];

const _tee = {
  'Product Id': 'prod_tshirt',
  'Product Handle': 't-shirt',
  'Product Title': 'Imported Essential Tee',
  'Product Subtitle': 'Updated by CSV',
  'Product Description': 'Fresh copy',
  'Product Status': 'published',
  'Product Weight': '250',
  'Product Origin Country': 'mm',
  'Product Material': 'Organic cotton',
  'Product Type Id': 'ptyp_shirt',
  'Product Tag 1': 'Imported',
  'Product Discountable': 'true',
  'Variant Id': 'var_tshirt_s_black',
  'Variant Title': 'S / Black',
  'Variant SKU': 'TSHIRT-S-BLACK',
  'Variant Barcode': 'TEE-S-BLACK',
  'Variant Allow Backorder': 'false',
  'Variant Manage Inventory': 'true',
  'Variant Material': 'Jersey',
  'Variant Price EUR': '12.00',
  'Variant Price USD': '16.00',
  'Variant Option 1 Name': 'Size',
  'Variant Option 1 Value': 'S',
  'Variant Option 2 Name': 'Color',
  'Variant Option 2 Value': 'Black',
};

Map<String, String> _cap(
  String size,
  String sku,
  String usd,
  String eur, {
  String handle = 'imported-cap',
}) =>
    {
      'Product Handle': handle,
      'Product Title': 'Imported Cap',
      'Product Subtitle': 'CSV collection',
      'Product Description': 'Daily cap',
      'Product Status': 'published',
      'Product Thumbnail': importedCapFront,
      'Product Weight': '180',
      'Product Origin Country': 'mm',
      'Product Material': 'Canvas',
      'Product Type Id': 'ptyp_shirt',
      'Product Tag 1': 'Imported',
      'Product Discountable': 'true',
      'Variant Title': size,
      'Variant SKU': sku,
      'Variant Allow Backorder': 'false',
      'Variant Manage Inventory': 'false',
      'Variant Material': 'Canvas',
      'Variant Price EUR': eur,
      'Variant Price USD': usd,
      'Variant Option 1 Name': 'Size',
      'Variant Option 1 Value': size,
      'Product Image 1 Url': importedCapFront,
      'Product Image 2 Url': importedCapBack,
    };

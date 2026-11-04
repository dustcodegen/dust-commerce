import 'dart:convert';

import 'package:commerce_server/src/features/admin/product_export_model.dart';
import 'package:commerce_server/src/features/admin/service/export_headers.dart';
import 'package:intl/intl.dart';

/// Expands direct database projections into a Medusa-compatible CSV document.
String adminProductCsv(List<AdminProductExportRow> rows) {
  final products = rows.map(_ProductData.new).toList(growable: false);
  final currencies = <String>{
    for (final product in products)
      for (final variant in product.variants)
        for (final price in _objects(variant['prices']))
          _text(price['currency_code']),
  }..remove('');
  final orderedCurrencies = currencies.toList()..sort();
  final headers = adminProductExportHeaders(
    currencies: orderedCurrencies,
    tagCount: _maximum(products.map((value) => value.tags.length)),
    optionCount: _maximum(products.map((value) => value.options.length)),
    imageCount: _maximum(products.map((value) => value.images.length)),
  );
  final csvRows = <List<String>>[headers];
  for (final product in products) {
    final variants = product.variants.isEmpty
        ? const <Map<String, Object?>>[{}]
        : product.variants;
    for (final variant in variants) {
      final values = _values(product, variant, orderedCurrencies);
      csvRows.add([for (final header in headers) values[header] ?? '']);
    }
  }
  return '${csvRows.map(_csvRow).join('\r\n')}\r\n';
}

Map<String, String> _values(
  _ProductData product,
  Map<String, Object?> variant,
  List<String> currencies,
) {
  final row = product.row;
  final values = <String, String>{
    'Product Id': row.productId,
    'Product Handle': row.handle,
    'Product Title': row.title,
    'Product Subtitle': _text(row.subtitle),
    'Product Description': _text(row.description),
    'Product Status': row.status,
    'Product Thumbnail': _text(row.thumbnail),
    'Product Weight': _text(row.weight),
    'Product Length': _text(row.length),
    'Product Width': _text(row.width),
    'Product Height': _text(row.height),
    'Product Origin Country': _text(row.originCountry),
    'Product Material': _text(row.material),
    'Product Collection Id': _text(row.collectionId),
    'Product Type Id': _text(row.typeId),
    'Product Discountable': '${row.discountable != 0}',
    'Variant Id': _text(variant['id']),
    'Variant Title': _text(variant['title']),
    'Variant SKU': _text(variant['sku']),
    'Variant Barcode': _text(variant['barcode']),
    'Variant Allow Backorder': _text(variant['allow_backorder']),
    'Variant Manage Inventory': _text(variant['manage_inventory']),
    'Variant Weight': _text(variant['weight']),
    'Variant Length': _text(variant['length']),
    'Variant Width': _text(variant['width']),
    'Variant Height': _text(variant['height']),
    'Variant HS Code': _text(variant['hs_code']),
    'Variant Origin Country': _text(variant['origin_country']),
    'Variant MID Code': _text(variant['mid_code']),
    'Variant Material': _text(variant['material']),
  };
  for (var index = 0; index < product.tags.length; index++) {
    values['Product Tag ${index + 1}'] = product.tags[index];
  }
  final prices = {
    for (final price in _objects(variant['prices']))
      _text(price['currency_code']): price['amount'],
  };
  for (final currency in currencies) {
    final amount = prices[currency];
    if (amount is int) {
      values['Variant Price ${currency.toUpperCase()}'] =
          _money(amount, currency);
    }
  }
  final selected = _object(variant['option_values']);
  for (var index = 0; index < product.options.length; index++) {
    final option = product.options[index];
    values['Variant Option ${index + 1} Name'] = _text(option['title']);
    values['Variant Option ${index + 1} Value'] =
        _text(selected[_text(option['id'])]);
  }
  for (var index = 0; index < product.images.length; index++) {
    values['Product Image ${index + 1} Url'] = product.images[index];
  }
  return values;
}

String _money(int amount, String currency) {
  final digits = NumberFormat.simpleCurrency(
        name: currency.toUpperCase(),
      ).decimalDigits ??
      2;
  var divisor = 1;
  for (var index = 0; index < digits; index++) {
    divisor *= 10;
  }
  if (digits == 0) return '$amount';
  final whole = amount ~/ divisor;
  final remainder = (amount % divisor).toString().padLeft(digits, '0');
  return '$whole.$remainder';
}

String _csvRow(List<String> values) => values.map(_escape).join(',');

String _escape(String value) => value.contains(RegExp('[,"\r\n]'))
    ? '"${value.replaceAll('"', '""')}"'
    : value;

int _maximum(Iterable<int> values) =>
    values.fold(0, (maximum, value) => value > maximum ? value : maximum);

String _text(Object? value) => value?.toString() ?? '';

Map<String, Object?> _object(Object? value) => switch (value) {
      final Map<String, Object?> object => object,
      _ => const {},
    };

List<Map<String, Object?>> _objects(Object? value) {
  final decoded = value is String ? jsonDecode(value) : value;
  if (decoded is! List<Object?>) return const [];
  return [
    for (final item in decoded)
      if (item is Map<String, Object?>) item
  ];
}

List<String> _strings(String value) {
  final decoded = jsonDecode(value);
  if (decoded is! List<Object?>) return const [];
  return [
    for (final item in decoded)
      if (item is String) item
  ];
}

final class _ProductData {
  _ProductData(this.row)
      : images = _strings(row.imagesJson),
        options = _objects(row.optionsJson),
        tags = _strings(row.tagsJson),
        variants = _objects(row.variantsJson);

  final List<String> images;
  final List<Map<String, Object?>> options;
  final AdminProductExportRow row;
  final List<String> tags;
  final List<Map<String, Object?>> variants;
}

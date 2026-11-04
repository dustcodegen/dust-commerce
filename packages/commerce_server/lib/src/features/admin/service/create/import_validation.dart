/// Validates typed values supported by product-import confirmation.
String? validateAdminProductImportCells(Map<String, String> row) {
  const unsupported = {
    'Product HS Code',
    'Product MID Code',
    'Shipping Profile Id',
    'Product Sales Channel 1',
    'Product External Id',
  };
  for (final column in unsupported) {
    if ((row[column] ?? '').isNotEmpty) {
      return '$column is not supported by this store';
    }
  }
  final status = row['Product Status'];
  if (status != null &&
      status.isNotEmpty &&
      !const {'draft', 'published', 'rejected', 'proposed'}.contains(status)) {
    return 'Product Status is invalid';
  }
  for (final entry in row.entries) {
    final value = entry.value;
    if (value.isEmpty) continue;
    if (entry.key.endsWith('Weight') ||
        entry.key.endsWith('Length') ||
        entry.key.endsWith('Width') ||
        entry.key.endsWith('Height')) {
      final number = int.tryParse(value);
      if (number == null || number < 0) {
        return '${entry.key} must be a non-negative integer';
      }
    }
    if ((entry.key == 'Product Discountable' ||
            entry.key == 'Variant Allow Backorder' ||
            entry.key == 'Variant Manage Inventory') &&
        value != 'true' &&
        value != 'false') {
      return '${entry.key} must be true or false';
    }
    if (entry.key.startsWith('Variant Price ') &&
        !RegExp(r'^\d+(?:\.\d+)?$').hasMatch(value)) {
      return '${entry.key} must be a non-negative decimal';
    }
  }
  for (var index = 1; index <= 100; index++) {
    final name = row['Variant Option $index Name'] ?? '';
    final value = row['Variant Option $index Value'] ?? '';
    if ((name.isEmpty) != (value.isEmpty)) {
      return 'Variant option names and values must be paired';
    }
  }
  final optionNames = <String>{};
  for (var index = 1; index <= 100; index++) {
    final name = row['Variant Option $index Name'] ?? '';
    if (name.isNotEmpty && !optionNames.add(name)) {
      return 'Variant option names must be unique within one row';
    }
  }
  if ((row['Variant Title'] ?? '').trim().isEmpty) {
    return 'Every product row needs a variant title';
  }
  for (final key in [
    'Variant Title',
    'Variant SKU',
    'Variant Barcode',
    'Variant HS Code',
    'Variant MID Code',
    'Variant Material',
  ]) {
    if ((row[key] ?? '').length > 255) return '$key is too long';
  }
  final variantId = row['Variant Id'] ?? '';
  if (variantId.isNotEmpty &&
      !RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(variantId)) {
    return 'Variant ids contain unsupported characters';
  }
  final tags = <String>{};
  final images = <String>{};
  for (final entry in row.entries) {
    if (entry.value.isEmpty) continue;
    if (entry.key.startsWith('Product Tag ') &&
        !tags.add(entry.value.toLowerCase())) {
      return 'Product tags must be unique';
    }
    if (entry.key.startsWith('Product Image ') && !images.add(entry.value)) {
      return 'Product images must be unique';
    }
  }
  for (final key in ['Product Origin Country', 'Variant Origin Country']) {
    final value = row[key] ?? '';
    if (value.isNotEmpty && !RegExp(r'^[a-z]{2}$').hasMatch(value)) {
      return '$key must be a lowercase ISO country code';
    }
  }
  return null;
}

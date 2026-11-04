import 'dart:convert';

import 'package:commerce_server/src/features/admin/service/export_headers.dart';
import 'package:commerce_server/src/features/admin/service/create/import_validation.dart';
import 'package:csv/csv.dart';
import 'package:dust_dart/fp.dart';

/// A normalized, bounded Medusa product CSV ready to stage.
final class AdminProductImportDocument {
  /// Creates a validated document.
  const AdminProductImportDocument({
    required this.headers,
    required this.rows,
    required this.identities,
  });

  /// Original unique columns in source order.
  final List<String> headers;

  /// One identity per unique product handle.
  final List<Map<String, String>> identities;

  /// Normalized string cells retained for later confirmation.
  final List<Map<String, String>> rows;

  /// Number of unique products represented by the file.
  int get productCount => identities.length;

  /// Stable payload written only after every row validates.
  String get payloadJson => jsonEncode({'headers': headers, 'rows': rows});
}

/// Parses one RFC 4180 document or returns a merchant-safe reason.
Result<AdminProductImportDocument, String> parseAdminProductImport(
  String source,
) {
  if (source.trim().isEmpty) return const Err('CSV is empty');
  try {
    final eol = source.contains('\r\n') ? '\r\n' : '\n';
    final parsed = CsvToListConverter(
      eol: eol,
      shouldParseNumbers: false,
      allowInvalid: false,
      convertEmptyTo: '',
    ).convert<String>(source);
    if (parsed.length < 2) {
      return const Err('CSV must include at least one product');
    }
    final headers = parsed.first
        .map((value) => value.replaceFirst('\ufeff', '').trim())
        .toList(growable: false);
    final headerError = _validateHeaders(headers);
    if (headerError != null) return Err(headerError);

    final rows = <Map<String, String>>[];
    final products = <String, ({String id, String title, String signature})>{};
    for (final cells in parsed.skip(1)) {
      if (cells.every((cell) => cell.trim().isEmpty)) continue;
      if (cells.length != headers.length) {
        return const Err('Every row must match the header');
      }
      if (rows.length == 10000) {
        return const Err('CSV exceeds 10000 data rows');
      }
      final row = {
        for (var index = 0; index < headers.length; index++)
          headers[index]: cells[index].trim(),
      };
      final rowError = _validateRow(row, products);
      if (rowError != null) return Err(rowError);
      rows.add(row);
    }
    if (rows.isEmpty) {
      return const Err('CSV must include at least one product');
    }
    final identities = [
      for (final entry in products.entries)
        {'id': entry.value.id, 'handle': entry.key},
    ];
    return Ok(AdminProductImportDocument(
      headers: headers,
      rows: rows,
      identities: identities,
    ));
  } on FormatException {
    return const Err('CSV is malformed');
  }
}

String? _validateHeaders(List<String> headers) {
  if (headers.toSet().length != headers.length ||
      headers.any((header) => header.isEmpty)) {
    return 'CSV headers must be unique and non-empty';
  }
  for (final required in ['Product Id', 'Product Handle', 'Product Title']) {
    if (!headers.contains(required)) return 'CSV is missing $required';
  }
  if (headers.any((header) => !isAdminProductCsvHeader(header))) {
    return 'CSV contains an unsupported header';
  }
  return null;
}

String? _validateRow(
  Map<String, String> row,
  Map<String, ({String id, String title, String signature})> products,
) {
  if (row.values.any((value) => value.length > 10000)) {
    return 'CSV contains a cell longer than 10000 characters';
  }
  final id = row['Product Id']!;
  final handle = row['Product Handle']!;
  final title = row['Product Title']!;
  if (handle.isEmpty ||
      title.isEmpty ||
      handle.length > 255 ||
      title.length > 255) {
    return 'Every product row needs a valid handle and title';
  }
  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(handle)) {
    return 'Product handles must use lowercase letters, numbers, and hyphens';
  }
  if (id.isNotEmpty && !RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(id)) {
    return 'Product ids contain unsupported characters';
  }
  final signature = jsonEncode({
    for (final entry in row.entries)
      if (entry.key.startsWith('Product ') &&
          !entry.key.startsWith('Product Image '))
        entry.key: entry.value,
    for (final entry in row.entries)
      if (entry.key.startsWith('Product Image ') ||
          entry.key.startsWith('Product Tag '))
        entry.key: entry.value,
  });
  final previous = products[handle];
  if (previous != null && previous.signature != signature) {
    return 'Rows for one product must use the same product values';
  }
  products[handle] = (id: id, title: title, signature: signature);
  return validateAdminProductImportCells(row);
}

import 'dart:convert';

import 'package:commerce_server/src/features/admin/service/create/import_parser.dart';
import 'package:csv/csv.dart';
import 'package:dust_dart/fp.dart';

/// One product and all variant rows from a revalidated staged payload.
final class AdminImportedProduct {
  /// Creates a product group with one consistent product shell.
  const AdminImportedProduct({required this.row, required this.variantRows});

  /// Product fields shared by every CSV row in this group.
  final Map<String, String> row;

  /// Rows that describe variants belonging to this product.
  final List<Map<String, String>> variantRows;
}

/// Decodes and revalidates the normalized payload before any write.
Result<List<AdminImportedProduct>, String> decodeAdminProductImport(
  String payload,
) {
  try {
    final decoded = jsonDecode(payload);
    if (decoded is! Map<String, Object?> ||
        decoded['headers'] is! List<Object?> ||
        decoded['rows'] is! List<Object?>) {
      return const Err('Staged import payload is invalid');
    }
    final headers = (decoded['headers']! as List<Object?>).cast<String>();
    final maps = (decoded['rows']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .map((row) => row.cast<String, String>())
        .toList(growable: false);
    final csv = const ListToCsvConverter().convert([
      headers,
      for (final row in maps) [for (final header in headers) row[header] ?? ''],
    ]);
    final parsed = parseAdminProductImport(csv);
    if (parsed case Err()) return const Err('Staged import payload is invalid');
    final document = (parsed as Ok<AdminProductImportDocument, String>).value;
    final grouped = <String, List<Map<String, String>>>{};
    for (final row in document.rows) {
      grouped.putIfAbsent(row['Product Handle']!, () => []).add(row);
    }
    return Ok([
      for (final rows in grouped.values)
        AdminImportedProduct(row: rows.first, variantRows: rows),
    ]);
  } on Object {
    return const Err('Staged import payload is invalid');
  }
}

/// Typed accessors for normalized imported CSV cells.
extension AdminImportedRow on Map<String, String> {
  /// Returns a trimmed optional cell.
  String? optional(String key) => switch (this[key] ?? '') {
        '' => null,
        final value => value,
      };

  /// Returns a validated optional integer cell.
  int? integer(String key) => switch (optional(key)) {
        null => null,
        final value => int.parse(value),
      };

  /// Returns a validated boolean cell or its Medusa-compatible default.
  bool boolean(String key, {required bool defaultValue}) => switch (this[key]) {
        'true' => true,
        'false' => false,
        _ => defaultValue,
      };

  /// Returns numbered non-empty values in their CSV column order.
  List<String> numbered(String prefix, String suffix) {
    final values = <(int, String)>[];
    for (final entry in entries) {
      final match = RegExp('^${RegExp.escape(prefix)}(\\d+)'
              '${RegExp.escape(suffix)}\$')
          .firstMatch(entry.key);
      if (match != null && entry.value.isNotEmpty) {
        values.add((int.parse(match.group(1)!), entry.value));
      }
    }
    values.sort((left, right) => left.$1.compareTo(right.$1));
    return [for (final value in values) value.$2];
  }
}

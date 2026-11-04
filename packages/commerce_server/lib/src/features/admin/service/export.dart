import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/service/export_csv.dart';
import 'package:dust_dart/db.dart';

/// Exports every product matching the same filters and order as the Admin table.
Future<Result<String, SqlxError>> exportAdminProducts(
  AdminProductExportRepository products, {
  required String query,
  required List<AdminProductLifecycle> statuses,
  required List<String> tagIds,
  required List<String> typeIds,
  required AdminDateFilter createdAt,
  required AdminDateFilter updatedAt,
  required AdminProductOrder order,
}) async {
  final rows = await products.list(
    query.trim(),
    statuses.map((status) => status.name).join(','),
    tagIds.join(','),
    typeIds.join(','),
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
    order.parameter,
  );
  return switch (rows) {
    Ok(:final value) => Ok(adminProductCsv(value)),
    Err(:final error) => Err(error),
  };
}

String _value(Option<DateTime> value) => switch (value) {
      Some(value: final instant) => instant.toIso8601String(),
      None() => '',
    };

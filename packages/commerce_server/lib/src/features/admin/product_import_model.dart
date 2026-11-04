import 'package:dust_dart/db.dart';

part 'product_import_model.g.dart';

/// Private staged-import projection read directly by SQLx.
@Derive([FromRow()])
@Sqlx(renameAll: SqlxRename.snakeCase)
final class AdminProductImportRow {
  /// Creates the exact fields needed to confirm one staged import.
  const AdminProductImportRow({
    required this.id,
    required this.payloadJson,
    required this.status,
    required this.expiresAt,
  });

  /// Opaque staging transaction identifier.
  final String id;

  /// Validated normalized CSV retained at preview time.
  final String payloadJson;

  /// Pending, completed, or expired lifecycle.
  final String status;

  /// UTC deadline after which confirmation is refused.
  @Sqlx(tryFrom: _AdminImportUtcDateTime())
  final DateTime expiresAt;
}

/// Private active product identity read directly by SQLx.
@Derive([FromRow()])
@Sqlx(renameAll: SqlxRename.snakeCase)
final class AdminProductImportIdentityRow {
  /// Creates an identity without an intermediate ORM model.
  const AdminProductImportIdentityRow({required this.id, required this.handle});

  /// Stable product identifier.
  final String id;

  /// Active storefront handle.
  final String handle;
}

/// Private active variant identity used to reject cross-product writes.
@Derive([FromRow()])
@Sqlx(renameAll: SqlxRename.snakeCase)
final class AdminProductImportVariantRow {
  /// Creates the database identity selected during confirmation preflight.
  const AdminProductImportVariantRow({
    required this.id,
    required this.productId,
    this.sku,
  });

  /// Stable variant identifier.
  final String id;

  /// Product that currently owns the variant.
  final String productId;

  /// Optional active merchant SKU.
  final String? sku;
}

/// Private identifier projection shared by import relation lookups.
@Derive([FromRow()])
final class AdminProductImportIdRow {
  /// Creates an id selected directly from a relation table.
  const AdminProductImportIdRow({required this.id});

  /// Stable relation or entity identifier.
  final String id;
}

/// Private currency projection used during import confirmation.
@Derive([FromRow()])
@Sqlx(renameAll: SqlxRename.snakeCase)
final class AdminProductImportCurrencyRow {
  /// Creates an active storefront currency selected directly by SQLx.
  const AdminProductImportCurrencyRow({required this.currencyCode});

  /// Lowercase ISO-4217 code stored by selling regions.
  final String currencyCode;
}

final class _AdminImportUtcDateTime implements SqlxTryFrom<DateTime, DateTime> {
  const _AdminImportUtcDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}

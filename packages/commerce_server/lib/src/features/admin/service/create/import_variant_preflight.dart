import 'package:commerce_server/src/features/admin/product_import_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/service/create/import_document.dart';
import 'package:commerce_server/src/features/admin/service/create/import_money.dart';
import 'package:commerce_server/src/features/admin/service/create/import_prepared.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Error crossing the imported-variant preflight boundary.
sealed class AdminProductImportVariantPreflightError {
  /// Creates one imported-variant preflight error.
  const AdminProductImportVariantPreflightError();
}

/// A business rejection that is safe to expose to product preflight.
final class AdminProductImportVariantPreflightRejected
    extends AdminProductImportVariantPreflightError {
  /// Creates one business rejection.
  const AdminProductImportVariantPreflightRejected(this.failure);

  /// The stable business reason.
  final AdminProductImportConfirmFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminProductImportVariantPreflightStorage
    extends AdminProductImportVariantPreflightError {
  /// Creates one storage failure.
  const AdminProductImportVariantPreflightStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Resolves and validates one imported variant before catalogue writes begin.
Future<Result<PreparedImportedVariant, AdminProductImportVariantPreflightError>>
    prepareImportedVariant(
  AdminProductImportConfirmRepository reads,
  Map<String, String> row,
  String productId,
  Set<String> activeCurrencies,
  String Function() nextId,
) async {
  final incomingId = row.optional('Variant Id');
  Option<AdminProductImportVariantRow> existing = const None();
  if (incomingId != null) {
    final found = await reads.findVariant(incomingId);
    if (found case Err(:final error)) {
      return Err(AdminProductImportVariantPreflightStorage(error));
    }
    existing = optionOf(
      (found as Ok<AdminProductImportVariantRow?, SqlxError>).value,
    );
    if (existing case None()) {
      return const Err(AdminProductImportVariantPreflightRejected(
        AdminProductImportConfirmFailure.conflict,
      ));
    }
    if ((existing as Some<AdminProductImportVariantRow>).value.productId !=
        productId) {
      return const Err(AdminProductImportVariantPreflightRejected(
        AdminProductImportConfirmFailure.conflict,
      ));
    }
  }
  final sku = row.optional('Variant SKU');
  if (sku != null) {
    final owner = await reads.findSkuOwner(sku, incomingId ?? '');
    if (owner case Err(:final error)) {
      return Err(AdminProductImportVariantPreflightStorage(error));
    }
    if (optionOf(
      (owner as Ok<AdminProductImportVariantRow?, SqlxError>).value,
    )
        case Some()) {
      return const Err(AdminProductImportVariantPreflightRejected(
        AdminProductImportConfirmFailure.conflict,
      ));
    }
  }
  final prices = <String, int>{};
  for (final entry in row.entries) {
    if (!entry.key.startsWith('Variant Price ') || entry.value.isEmpty) {
      continue;
    }
    final currency = entry.key.substring('Variant Price '.length).toLowerCase();
    final amount = adminImportMinorUnits(entry.value, currency);
    if (!activeCurrencies.contains(currency) || amount == null) {
      return const Err(AdminProductImportVariantPreflightRejected(
        AdminProductImportConfirmFailure.invalid,
      ));
    }
    prices[currency] = amount;
  }
  return Ok(PreparedImportedVariant(
    id: incomingId ?? nextId(),
    exists: existing is Some<AdminProductImportVariantRow>,
    row: row,
    prices: prices,
  ));
}

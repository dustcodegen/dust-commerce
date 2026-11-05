import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/repository/read/product.dart';
import 'package:commerce_server/src/features/admin/repository/update/price.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason a complete price replacement could not be applied.
enum AdminUpdateVariantPricesFailure {
  /// No active variant belongs to the requested product.
  notFound,

  /// Prices do not cover every active currency exactly once.
  invalidPrices,

  /// The committed product could not be read back.
  unavailable,
}

/// Error crossing the Admin variant-pricing boundary.
sealed class AdminUpdateVariantPricesError {
  /// Creates one variant-pricing error.
  const AdminUpdateVariantPricesError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminUpdateVariantPricesRejected
    extends AdminUpdateVariantPricesError {
  /// Creates one business rejection.
  const AdminUpdateVariantPricesRejected(this.failure);

  /// The stable business reason.
  final AdminUpdateVariantPricesFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminUpdateVariantPricesStorage
    extends AdminUpdateVariantPricesError {
  /// Creates one storage failure.
  const AdminUpdateVariantPricesStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Atomically replaces every active-currency amount for one variant.
Future<Result<AdminProductDetailResponse, AdminUpdateVariantPricesError>>
    updateAdminVariantPrices(
  CommerceDatabase database,
  String productId,
  String variantId,
  AdminUpdateVariantPrices input,
) async {
  return transactionResult<AdminProductDetailResponse,
      AdminUpdateVariantPricesError>(
    database,
    (tx) async {
      final prices = AdminVariantPriceRepository(tx);
      final found = await prices.variantCount(variantId, productId);
      if (found case Err(:final error)) {
        return Err(AdminUpdateVariantPricesStorage(error));
      }
      if ((found as Ok<int, SqlxError>).value != 1) {
        return const Err(
          AdminUpdateVariantPricesRejected(
            AdminUpdateVariantPricesFailure.notFound,
          ),
        );
      }

      final currencies = await prices.activeCurrencies();
      if (currencies case Err(:final error)) {
        return Err(AdminUpdateVariantPricesStorage(error));
      }
      final required = {
        for (final item
            in (currencies as Ok<List<AdminProductCurrencyResponse>, SqlxError>)
                .value)
          item.currencyCode,
      };
      final supplied = {for (final item in input.prices) item.currencyCode};
      if (supplied.length != input.prices.length ||
          supplied.length != required.length ||
          !supplied.containsAll(required)) {
        return const Err(
          AdminUpdateVariantPricesRejected(
            AdminUpdateVariantPricesFailure.invalidPrices,
          ),
        );
      }

      final deleted = await prices.deleteAll(variantId);
      if (deleted case Err(:final error)) {
        return Err(AdminUpdateVariantPricesStorage(error));
      }
      for (final price in input.prices) {
        if (price.amount < 0) {
          return const Err(
            AdminUpdateVariantPricesRejected(
              AdminUpdateVariantPricesFailure.invalidPrices,
            ),
          );
        }
        final written = await prices.insert(
          variantId,
          price.currencyCode,
          price.amount,
        );
        if (written case Err(:final error)) {
          return Err(AdminUpdateVariantPricesStorage(error));
        }
      }

      final refreshed =
          await AdminProductReadRepository(tx).findById(productId);
      if (refreshed case Err(:final error)) {
        return Err(AdminUpdateVariantPricesStorage(error));
      }
      return switch (optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      )) {
        Some(:final value) => Ok(value),
        None() => const Err(AdminUpdateVariantPricesRejected(
            AdminUpdateVariantPricesFailure.unavailable,
          )),
      };
    },
    storageError: AdminUpdateVariantPricesStorage.new,
  );
}

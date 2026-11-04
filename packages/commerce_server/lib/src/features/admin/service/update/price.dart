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

/// Atomically replaces every active-currency amount for one variant.
Future<
    Result<Result<AdminProductDetailResponse, AdminUpdateVariantPricesFailure>,
        SqlxError>> updateAdminVariantPrices(
  CommerceDatabase database,
  String productId,
  String variantId,
  AdminUpdateVariantPrices input,
) =>
    database.transaction((tx) async {
      final prices = AdminVariantPriceRepository(tx);
      final found = await prices.variantCount(variantId, productId);
      if (found case Err(:final error)) return Err(error);
      if ((found as Ok<int, SqlxError>).value != 1) {
        return const Ok(Err(AdminUpdateVariantPricesFailure.notFound));
      }

      final currencies = await prices.activeCurrencies();
      if (currencies case Err(:final error)) return Err(error);
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
        return const Ok(Err(AdminUpdateVariantPricesFailure.invalidPrices));
      }

      final deleted = await prices.deleteAll(variantId);
      if (deleted case Err(:final error)) return Err(error);
      for (final price in input.prices) {
        if (price.amount < 0) {
          return const Ok(Err(AdminUpdateVariantPricesFailure.invalidPrices));
        }
        final written = await prices.insert(
          variantId,
          price.currencyCode,
          price.amount,
        );
        if (written case Err(:final error)) return Err(error);
      }

      final refreshed =
          await AdminProductReadRepository(tx).findById(productId);
      if (refreshed case Err(:final error)) return Err(error);
      return switch (optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      )) {
        Some(:final value) => Ok(Ok(value)),
        None() => const Ok(Err(AdminUpdateVariantPricesFailure.unavailable)),
      };
    });

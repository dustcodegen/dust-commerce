import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/service/update/price.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateVariantPrices> _pricesBody =
    ValidatedExtractable(
  JsonExtractable<AdminUpdateVariantPrices>(AdminUpdateVariantPrices.fromJson),
);

/// `PUT /admin/products/{id}/variants/{variant_id}/prices` — replace prices.
Future<Result<AdminProductDetailResponse, Rejection>>
    updateAdminVariantPricesHandler(Request request) async {
  final parameters = pathParametersOf(request);
  final productId = parameters['id'];
  final variantId = parameters['variant_id'];
  if (productId == null ||
      productId.isEmpty ||
      variantId == null ||
      variantId.isEmpty) {
    return const Err(
      Rejection.badRequest('Product and variant ids are required'),
    );
  }
  final decoded = await _pricesBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await updateAdminVariantPrices(
    deps.database,
    productId,
    variantId,
    (decoded as Ok<AdminUpdateVariantPrices, Rejection>).value,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminUpdateVariantPricesRejected(
        failure: AdminUpdateVariantPricesFailure.notFound,
      )
    ) =>
      Err(Rejection.notFound('Product variant "$variantId"')),
    Err(
      error: AdminUpdateVariantPricesRejected(
        failure: AdminUpdateVariantPricesFailure.invalidPrices,
      )
    ) =>
      const Err(Rejection.status(
        422,
        'Set one non-negative price for every active currency',
      )),
    Err(
      error: AdminUpdateVariantPricesRejected(
        failure: AdminUpdateVariantPricesFailure.unavailable,
      )
    ) =>
      const Err(Rejection.internal()),
    Err(error: AdminUpdateVariantPricesStorage()) =>
      const Err(Rejection.internal()),
  };
}

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateProductVariant> _updateVariantBody =
    ValidatedExtractable(
  JsonExtractable<AdminUpdateProductVariant>(
      AdminUpdateProductVariant.fromJson),
);

/// `PATCH /admin/products/{id}/variants/{variant_id}` — edit one variant.
Future<Result<AdminProductDetailResponse, Rejection>>
    updateAdminProductVariantHandler(Request request) async {
  final parameters = pathParametersOf(request);
  final productId = parameters['id'];
  final variantId = parameters['variant_id'];
  if (productId == null ||
      productId.isEmpty ||
      variantId == null ||
      variantId.isEmpty) {
    return const Err(
        Rejection.badRequest('Product and variant ids are required'));
  }
  final decoded = await _updateVariantBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await updateAdminProductVariant(
    deps.database,
    productId,
    variantId,
    (decoded as Ok<AdminUpdateProductVariant, Rejection>).value,
  );
  return switch (result) {
    Ok(value: Ok(value: final product)) => Ok(product),
    Ok(value: Err(error: AdminUpdateVariantFailure.notFound)) =>
      Err(Rejection.notFound('Product variant "$variantId"')),
    Ok(value: Err(error: AdminUpdateVariantFailure.invalidOptions)) =>
      const Err(Rejection.status(
        422,
        'Select one unique value for every active product option',
      )),
    Ok(value: Err(error: AdminUpdateVariantFailure.skuConflict)) =>
      const Err(Rejection.conflict('Another variant already uses this SKU')),
    Ok(value: Err(error: AdminUpdateVariantFailure.unavailable)) =>
      const Err(Rejection.internal()),
    Err() => const Err(Rejection.internal()),
  };
}

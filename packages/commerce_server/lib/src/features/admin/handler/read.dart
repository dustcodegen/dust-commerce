import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/users/me` — returns the proven admin profile.
Future<Result<AdminUserResponse, Rejection>> readCurrentAdminHandler(
  Request request,
) async {
  final actor = await request.extract(const Extension<AuthenticatedAdmin>());
  return Ok(actor.user);
}

/// `GET /admin/products/{id}` — complete allowlisted merchant detail.
Future<Result<AdminProductDetailResponse, Rejection>> readAdminProductHandler(
    Request request) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await readAdminProduct(deps.productReads, id);
  return switch (result) {
    Ok(value: Some(value: final product)) => Ok(product),
    Ok(value: None()) => Err(Rejection.notFound('Product "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /admin/product-types/{id}` — reads one active classification.
Future<Result<AdminProductTypeResponse, Rejection>> readAdminProductTypeHandler(
    Request request) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product type id is required'));
  }
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await readAdminProductType(deps.productTypeReads, id);
  return switch (result) {
    Ok(value: Some(value: final productType)) => Ok(productType),
    Ok(value: None()) => Err(Rejection.notFound('Product type "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}

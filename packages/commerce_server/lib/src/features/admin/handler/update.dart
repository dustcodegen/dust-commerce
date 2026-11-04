import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateProduct> _updateProductBody =
    ValidatedExtractable(
  JsonExtractable<AdminUpdateProduct>(AdminUpdateProduct.fromJson),
);
const ValidatedExtractable<AdminUpdateProductType> _updateProductTypeBody =
    ValidatedExtractable(
  JsonExtractable<AdminUpdateProductType>(AdminUpdateProductType.fromJson),
);
const ValidatedExtractable<AdminUpdateProductOrganization>
    _updateProductOrganizationBody = ValidatedExtractable(
  JsonExtractable<AdminUpdateProductOrganization>(
    AdminUpdateProductOrganization.fromJson,
  ),
);

/// `PATCH /admin/products/{id}` — replace supported merchant product fields.
Future<Result<AdminProductDetailResponse, Rejection>> updateAdminProductHandler(
  Request request,
) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final decoded = await _updateProductBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await updateAdminProduct(
    deps.database,
    id,
    (decoded as Ok<AdminUpdateProduct, Rejection>).value,
  );
  return switch (result) {
    Ok(value: Ok(value: final product)) => Ok(product),
    Ok(value: Err(error: AdminUpdateProductFailure.notFound)) =>
      Err(Rejection.notFound('Product "$id"')),
    Ok(value: Err(error: AdminUpdateProductFailure.handleConflict)) =>
      const Err(Rejection.conflict('Another product already uses this handle')),
    Err() => const Err(Rejection.internal()),
  };
}

/// `PATCH /admin/product-types/{id}` — renames one classification.
Future<Result<AdminProductTypeResponse, Rejection>>
    updateAdminProductTypeHandler(Request request) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product type id is required'));
  }
  final decoded = await _updateProductTypeBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await updateAdminProductType(
    deps.database,
    id,
    (decoded as Ok<AdminUpdateProductType, Rejection>).value,
  );
  return switch (result) {
    Ok(value: Ok(value: final productType)) => Ok(productType),
    Ok(value: Err(error: AdminUpdateProductTypeFailure.invalid)) =>
      const Err(Rejection.status(422, 'Enter a product type')),
    Ok(value: Err(error: AdminUpdateProductTypeFailure.notFound)) =>
      Err(Rejection.notFound('Product type "$id"')),
    Ok(value: Err(error: AdminUpdateProductTypeFailure.valueConflict)) =>
      const Err(Rejection.conflict('Another product type uses this value')),
    Err() => const Err(Rejection.internal()),
  };
}

/// `PATCH /admin/products/{id}/organization` — replaces its classification.
Future<Result<AdminProductDetailResponse, Rejection>>
    updateAdminProductOrganizationHandler(Request request) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final decoded = await _updateProductOrganizationBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await updateAdminProductOrganization(
    deps.database,
    id,
    (decoded as Ok<AdminUpdateProductOrganization, Rejection>).value,
  );
  return switch (result) {
    Ok(value: Ok(value: final product)) => Ok(product),
    Ok(value: Err(error: AdminUpdateProductOrganizationFailure.notFound)) =>
      Err(Rejection.notFound('Product "$id"')),
    Ok(
      value: Err(
        error: AdminUpdateProductOrganizationFailure.invalidProductType
      )
    ) =>
      const Err(Rejection.status(422, 'Choose an active product type')),
    Err() => const Err(Rejection.internal()),
  };
}

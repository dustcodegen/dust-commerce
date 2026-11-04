import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminCredentials> _credentialsBody =
    ValidatedExtractable(
  JsonExtractable<AdminCredentials>(AdminCredentials.fromJson),
);

const ValidatedExtractable<AdminCreateProduct> _createProductBody =
    ValidatedExtractable(
  JsonExtractable<AdminCreateProduct>(AdminCreateProduct.fromJson),
);
const ValidatedExtractable<AdminCreateProductType> _createProductTypeBody =
    ValidatedExtractable(
  JsonExtractable<AdminCreateProductType>(AdminCreateProductType.fromJson),
);

/// `POST /auth/admin/emailpass` — exchange admin credentials for a token.
Future<Result<AdminIssuedToken, Rejection>> adminSignInHandler(
  Request request,
) async {
  final decoded = await _credentialsBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final depsResult = await adminDeps(request);
  if (depsResult case Err(:final error)) return Err(error);
  final deps = (depsResult as Ok<AdminDeps, Rejection>).value;

  late final Result<Option<AdminIssuedToken>, SqlxError> result;
  try {
    result = await adminSignIn(
      deps.reads,
      deps.writes,
      (decoded as Ok<AdminCredentials, Rejection>).value,
      now: deps.clock.now(),
      dummyPasswordHash: deps.dummyPasswordHash,
      passwordWork: deps.passwordWork,
    );
  } on PasswordCapacityException {
    return const Err(
      Rejection.status(429, 'Authentication is busy; retry shortly'),
    );
  }
  return switch (result) {
    Ok(value: Some(value: final token)) => Ok(token),
    Ok(value: None()) =>
      const Err(Rejection.unauthorized('Invalid email or password')),
    Err() => const Err(Rejection.internal()),
  };
}

/// `POST /admin/products` — creates one complete merchant product graph.
Future<Result<AdminProductDetailResponse, Rejection>> createAdminProductHandler(
  Request request,
) async {
  final decoded = await _createProductBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await createAdminProduct(
    deps.database,
    (decoded as Ok<AdminCreateProduct, Rejection>).value,
    nextId: deps.clock.nextId,
    mediaStorage: deps.mediaStorage,
  );
  return switch (result) {
    Ok(value: Ok(value: final product)) => Ok(product),
    Ok(value: Err(error: AdminCreateProductFailure.handleConflict)) =>
      const Err(Rejection.conflict('Another product already uses this handle')),
    Ok(value: Err(error: AdminCreateProductFailure.skuConflict)) =>
      const Err(Rejection.conflict('Another variant already uses this SKU')),
    Ok(value: Err(error: AdminCreateProductFailure.invalidCurrency)) =>
      const Err(Rejection.status(
        422,
        'Add one price for every active storefront currency',
      )),
    Ok(value: Err(error: AdminCreateProductFailure.invalidMedia)) =>
      const Err(Rejection.status(
        422,
        'Use unique product images returned by the upload endpoint',
      )),
    Ok(value: Err(error: AdminCreateProductFailure.invalidProductType)) =>
      const Err(Rejection.status(422, 'Choose an active product type')),
    Ok(value: Err(error: AdminCreateProductFailure.invalidHandle)) =>
      const Err(Rejection.status(
        422,
        'Use a non-empty lowercase product handle',
      )),
    Ok(value: Err(error: AdminCreateProductFailure.invalidOptions)) =>
      const Err(Rejection.status(
        422,
        'Every variant must select one valid value for every option',
      )),
    Ok(value: Err(error: AdminCreateProductFailure.invalidVariants)) =>
      const Err(Rejection.status(
        422,
        'Add at least one unique, valid product variant',
      )),
    Ok(value: Err(error: AdminCreateProductFailure.unavailable)) =>
      const Err(Rejection.internal()),
    Err() => const Err(Rejection.internal()),
  };
}

/// `POST /admin/product-types` — creates one reusable classification.
Future<Result<AdminProductTypeResponse, Rejection>>
    createAdminProductTypeHandler(Request request) async {
  final decoded = await _createProductTypeBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await createAdminProductType(
    deps.database,
    (decoded as Ok<AdminCreateProductType, Rejection>).value,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(value: Ok(value: final productType)) => Ok(productType),
    Ok(value: Err(error: AdminCreateProductTypeFailure.invalid)) =>
      const Err(Rejection.status(422, 'Enter a product type')),
    Ok(value: Err(error: AdminCreateProductTypeFailure.valueConflict)) =>
      const Err(Rejection.conflict('Another product type uses this value')),
    Err() => const Err(Rejection.internal()),
  };
}

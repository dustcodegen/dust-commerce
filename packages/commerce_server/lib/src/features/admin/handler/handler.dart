/// Admin HTTP handlers.
library;

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/product_option_model.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

export 'create.dart';
export 'delete.dart';
export 'delete/product.dart';
export 'export.dart';
export 'image_variants.dart';
export 'create/import.dart';
export 'create/import_confirm.dart';
export 'list.dart';
export 'media.dart';
export 'read.dart';
export 'update.dart';
export 'update/price.dart';
export 'update/stock.dart';
export 'update_media.dart';
export 'update_variant.dart';

const ValidatedExtractable<AdminCreateProductOption> _createOptionBody =
    ValidatedExtractable(
  JsonExtractable<AdminCreateProductOption>(AdminCreateProductOption.fromJson),
);
const ValidatedExtractable<AdminUpdateProductOption> _updateOptionBody =
    ValidatedExtractable(
  JsonExtractable<AdminUpdateProductOption>(AdminUpdateProductOption.fromJson),
);

/// `POST /admin/product-options` — creates one global product option.
Future<Result<AdminProductOptionDetailResponse, Rejection>>
    createAdminProductOptionHandler(Request request) async {
  final decoded = await _createOptionBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await createAdminProductOption(
    deps.database,
    (decoded as Ok<AdminCreateProductOption, Rejection>).value,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(value: Ok(value: final option)) => Ok(option),
    Ok(value: Err(error: AdminCreateProductOptionFailure.invalid)) =>
      const Err(Rejection.status(422, 'Add at least one unique option value')),
    Ok(value: Err(error: AdminCreateProductOptionFailure.titleConflict)) =>
      const Err(Rejection.conflict('Another option already uses this title')),
    Ok(value: Err(error: AdminCreateProductOptionFailure.unavailable)) =>
      const Err(Rejection.internal()),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /admin/product-options` — lists global options for a proven merchant.
Future<Result<AdminProductOptionListResponse, Rejection>>
    listAdminProductOptionsHandler(Request request) async {
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final paging = pagingOf(request);
  final query = request.requestedUri.queryParameters['q'] ?? '';
  final result = await listAdminProductOptions(
    deps.productOptions,
    query: query,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /admin/product-options/{id}` — reads one product option.
Future<Result<AdminProductOptionDetailResponse, Rejection>>
    readAdminProductOptionHandler(Request request) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product option id is required'));
  }
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await readAdminProductOption(deps.productOptions, id);
  return switch (result) {
    Ok(value: Some(value: final option)) => Ok(option),
    Ok(value: None()) => Err(Rejection.notFound('Product option "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}

/// `PATCH /admin/product-options/{id}` — edits one product option.
Future<Result<AdminProductOptionDetailResponse, Rejection>>
    updateAdminProductOptionDetailHandler(Request request) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product option id is required'));
  }
  final decoded = await _updateOptionBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await updateAdminProductOptionDetail(
    deps.database,
    id,
    (decoded as Ok<AdminUpdateProductOption, Rejection>).value,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(value: Ok(value: final option)) => Ok(option),
    Ok(value: Err(error: AdminUpdateProductOptionDetailFailure.notFound)) =>
      Err(Rejection.notFound('Product option "$id"')),
    Ok(value: Err(error: AdminUpdateProductOptionDetailFailure.invalid)) =>
      const Err(Rejection.status(422, 'Add at least one unique option value')),
    Ok(
      value: Err(error: AdminUpdateProductOptionDetailFailure.titleConflict)
    ) =>
      const Err(Rejection.conflict('Another option already uses this title')),
    Ok(value: Err(error: AdminUpdateProductOptionDetailFailure.valueInUse)) =>
      const Err(Rejection.conflict(
        'A product variant still uses one of the removed values',
      )),
    Err() => const Err(Rejection.internal()),
  };
}

/// `DELETE /admin/product-options/{id}` — retires one unused product option.
Future<Result<Response, Rejection>> deleteAdminProductOptionHandler(
  Request request,
) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product option id is required'));
  }
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await deleteAdminProductOption(deps.database, id);
  return switch (result) {
    Ok(value: Ok()) => Ok(noContent()),
    Ok(value: Err(error: AdminDeleteProductOptionFailure.notFound)) =>
      Err(Rejection.notFound('Product option "$id"')),
    Ok(value: Err(error: AdminDeleteProductOptionFailure.inUse)) =>
      const Err(Rejection.conflict(
        'Remove this option from every product before deleting it',
      )),
    Err() => const Err(Rejection.internal()),
  };
}

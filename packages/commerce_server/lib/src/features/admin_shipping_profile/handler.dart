import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/deps.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/model.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/management_service.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/query.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateProductShippingProfile>
    _updateProductShippingProfileBody = ValidatedExtractable(
  JsonExtractable<AdminUpdateProductShippingProfile>(
    AdminUpdateProductShippingProfile.fromJson,
  ),
);

const ValidatedExtractable<AdminCreateShippingProfile>
    _createShippingProfileBody = ValidatedExtractable(
  JsonExtractable<AdminCreateShippingProfile>(
    AdminCreateShippingProfile.fromJson,
  ),
);

/// `POST /admin/shipping-profiles` — creates one fulfillment group.
Future<Result<AdminShippingProfileResponse, Rejection>>
    createAdminShippingProfileHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final decoded = await _createShippingProfileBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminShippingProfileDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminShippingProfileDeps, Rejection>).value;
  final result = await createAdminShippingProfile(
    deps.management,
    (decoded as Ok<AdminCreateShippingProfile, Rejection>).value,
    nextId: deps.clock.nextId,
  );
  return _profileResult(result, 'Shipping profile');
}

/// `GET /admin/shipping-profiles/{id}` — reads one fulfillment group.
Future<Result<AdminShippingProfileResponse, Rejection>>
    readAdminShippingProfileHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A shipping profile id is required'));
  }
  final state = await adminShippingProfileDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminShippingProfileDeps, Rejection>).value;
  return _profileResult(
    await readAdminShippingProfile(deps.management, id),
    'Shipping profile "$id"',
  );
}

/// `DELETE /admin/shipping-profiles/{id}` — retires one fulfillment group.
Future<Result<Response, Rejection>> deleteAdminShippingProfileHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A shipping profile id is required'));
  }
  final state = await adminShippingProfileDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminShippingProfileDeps, Rejection>).value;
  return switch (await deleteAdminShippingProfile(deps.database, id)) {
    Ok() => Ok(noContent()),
    Err(error: AdminShippingProfileManagementFailure.notFound) =>
      Err(Rejection.notFound('Shipping profile "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}

Result<AdminShippingProfileResponse, Rejection> _profileResult(
  Result<AdminShippingProfileResponse, AdminShippingProfileManagementFailure>
      result,
  String resource,
) =>
    switch (result) {
      Ok(:final value) => Ok(value),
      Err(error: AdminShippingProfileManagementFailure.invalid) =>
        const Err(Rejection.status(422, 'Enter a name and type')),
      Err(error: AdminShippingProfileManagementFailure.nameConflict) =>
        const Err(Rejection.conflict('Another profile uses this name')),
      Err(error: AdminShippingProfileManagementFailure.notFound) =>
        Err(Rejection.notFound(resource)),
      Err(error: AdminShippingProfileManagementFailure.internal) =>
        const Err(Rejection.internal()),
    };

/// `GET /admin/shipping-profiles` — lists choices for a proven merchant.
Future<Result<AdminShippingProfileListResponse, Rejection>>
    listAdminShippingProfilesHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminShippingProfileDeps(request);
  if (state case Err(:final error)) return Err(error);
  final filters = adminShippingProfileQueryOf(request);
  if (filters case Err(:final error)) return Err(error);
  final query = request.requestedUri.queryParameters;
  final limit = int.tryParse(query['limit'] ?? '') ?? defaultLimit;
  final offset = int.tryParse(query['offset'] ?? '') ?? 0;
  final deps = (state as Ok<AdminShippingProfileDeps, Rejection>).value;
  final parsed = (filters as Ok<AdminShippingProfileQuery, Rejection>).value;
  final result = await listAdminShippingProfiles(
    deps.profiles,
    query: parsed.query,
    name: parsed.name,
    type: parsed.type,
    createdAt: parsed.createdAt,
    updatedAt: parsed.updatedAt,
    order: parsed.order,
    limit: limit.clamp(1, 1000),
    offset: offset < 0 ? 0 : offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `PATCH /admin/products/{id}/shipping-profile` — replaces fulfillment.
Future<Result<AdminProductShippingProfileResponse, Rejection>>
    updateAdminProductShippingProfileHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final productId = pathParametersOf(request)['id'];
  if (productId == null || productId.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final decoded = await _updateProductShippingProfileBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminShippingProfileDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminShippingProfileDeps, Rejection>).value;
  final result = await replaceAdminProductShippingProfile(
    deps.database,
    productId,
    (decoded as Ok<AdminUpdateProductShippingProfile, Rejection>).value,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminProductShippingProfileUpdateFailure.notFound) =>
      Err(Rejection.notFound('Product "$productId"')),
    Err(error: AdminProductShippingProfileUpdateFailure.invalid) =>
      const Err(Rejection.status(422, 'Choose an active shipping profile')),
    Err(error: AdminProductShippingProfileUpdateFailure.internal) =>
      const Err(Rejection.internal()),
  };
}

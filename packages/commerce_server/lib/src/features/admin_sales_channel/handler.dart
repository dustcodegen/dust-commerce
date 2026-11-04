import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_sales_channel/deps.dart';
import 'package:commerce_server/src/features/admin_sales_channel/model.dart';
import 'package:commerce_server/src/features/admin_sales_channel/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateProductSalesChannels>
    _updateProductChannelsBody = ValidatedExtractable(
  JsonExtractable<AdminUpdateProductSalesChannels>(
    AdminUpdateProductSalesChannels.fromJson,
  ),
);

/// `GET /admin/sales-channels` — lists choices for a proven merchant.
Future<Result<AdminSalesChannelDetailListResponse, Rejection>>
    listAdminSalesChannelsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminSalesChannelDeps(request);
  if (state case Err(:final error)) return Err(error);
  final query = request.requestedUri.queryParameters;
  final limit = int.tryParse(query['limit'] ?? '') ?? defaultLimit;
  final offset = int.tryParse(query['offset'] ?? '') ?? 0;
  final deps = (state as Ok<AdminSalesChannelDeps, Rejection>).value;
  final result = await listAdminSalesChannels(
    deps.salesChannels,
    query: query['q'] ?? '',
    limit: limit.clamp(1, 1000),
    offset: offset < 0 ? 0 : offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `PUT /admin/products/{id}/sales-channels` — replaces product availability.
Future<Result<AdminSalesChannelListResponse, Rejection>>
    updateAdminProductSalesChannelsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final productId = pathParametersOf(request)['id'];
  if (productId == null || productId.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final decoded = await _updateProductChannelsBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminSalesChannelDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminSalesChannelDeps, Rejection>).value;
  final result = await replaceAdminProductSalesChannels(
    deps.database,
    productId,
    (decoded as Ok<AdminUpdateProductSalesChannels, Rejection>).value,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminProductSalesChannelUpdateFailure.notFound) =>
      Err(Rejection.notFound('Product "$productId"')),
    Err(error: AdminProductSalesChannelUpdateFailure.invalid) => const Err(
        Rejection.status(422, 'Choose unique available sales channels')),
    Err(error: AdminProductSalesChannelUpdateFailure.internal) =>
      const Err(Rejection.internal()),
  };
}

/// `GET /admin/products/{id}/sales-channels` — reads product availability.
Future<Result<AdminSalesChannelListResponse, Rejection>>
    readAdminProductSalesChannelsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final state = await adminSalesChannelDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminSalesChannelDeps, Rejection>).value;
  final result = await readAdminProductSalesChannels(deps.salesChannels, id);
  return switch (result) {
    Ok(value: Some(value: final channels)) => Ok(channels),
    Ok(value: None()) => Err(Rejection.notFound('Product "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_promotion/deps.dart';
import 'package:commerce_server/src/features/admin_promotion/model.dart';
import 'package:commerce_server/src/features/admin_promotion/query.dart';
import 'package:commerce_server/src/features/admin_promotion/service.dart';
import 'package:commerce_server/src/features/admin_promotion/update_failure.dart';
import 'package:commerce_server/src/features/admin_promotion/update_service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

export 'handler/create.dart';
export 'delete_handler.dart';

const ValidatedExtractable<AdminUpdatePromotion> _updateBody =
    ValidatedExtractable(
  StrictJsonExtractable<AdminUpdatePromotion>(
    AdminUpdatePromotion.fromJson,
    fields: {
      'code',
      'type',
      'value',
      'currency_code',
      'starts_at',
      'ends_at',
      'usage_limit',
    },
  ),
);

/// `PATCH /admin/promotions/{id}` — replaces one active promotion.
Future<Result<AdminPromotionDetailResponse, Rejection>>
    updateAdminPromotionHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A promotion id is required'));
  }
  final decoded = await _updateBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminPromotionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminPromotionDeps, Rejection>).value;
  final input = (decoded as Ok<AdminUpdatePromotion, Rejection>).value;
  return switch (await updateAdminPromotion(
    deps.promotions,
    deps.updates,
    id,
    input,
  )) {
    Ok(:final value) => Ok(AdminPromotionDetailResponse(promotion: value)),
    Err(error: AdminPromotionUpdateRejected(:final failure)) => switch (
          failure) {
        AdminPromotionUpdateFailure.notFound =>
          Err(Rejection.notFound('Promotion "$id"')),
        AdminPromotionUpdateFailure.codeConflict =>
          const Err(Rejection.conflict('Another promotion uses this code')),
        AdminPromotionUpdateFailure.invalidDefinition => const Err(
            Rejection.unprocessable({
              'promotion': ['The promotion definition is invalid'],
            }),
          ),
      },
    Err(error: AdminPromotionUpdateStorage()) =>
      const Err(Rejection.internal()),
  };
}

/// `GET /admin/promotions` — lists discount policies for a proven merchant.
Future<Result<AdminPromotionListResponse, Rejection>>
    listAdminPromotionsHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final state = await adminPromotionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final filters = adminPromotionQueryOf(request);
  if (filters case Err(:final error)) return Err(error);
  final paging = pagingOf(request);
  final deps = (state as Ok<AdminPromotionDeps, Rejection>).value;
  final query = (filters as Ok<AdminPromotionQuery, Rejection>).value;
  final result = await listAdminPromotions(
    deps.promotions,
    query: query.query,
    createdAt: query.createdAt,
    updatedAt: query.updatedAt,
    order: query.order,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

/// `GET /admin/promotions/{id}` — reads one active promotion.
Future<Result<AdminPromotionDetailResponse, Rejection>>
    readAdminPromotionHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A promotion id is required'));
  }
  final state = await adminPromotionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminPromotionDeps, Rejection>).value;
  final result = await readAdminPromotion(deps.promotions, id);
  return switch (result) {
    Ok(value: Some(:final value)) => Ok(value),
    Ok(value: None()) => Err(Rejection.notFound('Promotion "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}

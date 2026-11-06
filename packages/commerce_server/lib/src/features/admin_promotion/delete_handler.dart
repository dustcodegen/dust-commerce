import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_promotion/delete_service.dart';
import 'package:commerce_server/src/features/admin_promotion/deps.dart';
import 'package:dust_server/server.dart';

/// `DELETE /admin/promotions/{id}` — retires one active promotion.
Future<Result<AdminPromotionDeleted, Rejection>> deleteAdminPromotionHandler(
    Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A promotion id is required'));
  }
  final state = await adminPromotionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminPromotionDeps, Rejection>).value;
  final result = await deleteAdminPromotion(deps.deletes, id);
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminPromotionDeleteRejected(:final failure)) => switch (
          failure) {
        AdminPromotionDeleteFailure.notFound =>
          Err(Rejection.notFound('Promotion "$id"')),
      },
    Err(error: AdminPromotionDeleteStorage()) =>
      const Err(Rejection.internal()),
  };
}

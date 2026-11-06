import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin_promotion/create_failure.dart';
import 'package:commerce_server/src/features/admin_promotion/create_response.dart';
import 'package:commerce_server/src/features/admin_promotion/deps.dart';
import 'package:commerce_server/src/features/admin_promotion/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminCreatePromotion> _promotionBody =
    ValidatedExtractable(
  StrictJsonExtractable<AdminCreatePromotion>(
    AdminCreatePromotion.fromJson,
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

/// `POST /admin/promotions` — creates one merchant promotion.
Future<Result<AdminPromotionCreateResponse, Rejection>>
    createAdminPromotionHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final decoded = await _promotionBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminPromotionDeps(request);
  if (state case Err(:final error)) return Err(error);
  final input = (decoded as Ok<AdminCreatePromotion, Rejection>).value;
  final deps = (state as Ok<AdminPromotionDeps, Rejection>).value;
  final result = await createAdminPromotion(
    deps.creates,
    input,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(error: AdminPromotionCreateRejected(:final failure)) => switch (
          failure) {
        AdminPromotionCreateFailure.codeConflict =>
          const Err(Rejection.conflict('A promotion already uses this code')),
        AdminPromotionCreateFailure.invalidDefinition =>
          const Err(Rejection.unprocessable({
            'promotion': ['The promotion definition is invalid'],
          })),
      },
    Err(error: AdminPromotionCreateStorage()) =>
      const Err(Rejection.internal()),
  };
}

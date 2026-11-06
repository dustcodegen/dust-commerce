import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_promotion/model.dart';
import 'package:commerce_server/src/features/admin_promotion/repository.dart';
import 'package:commerce_server/src/features/admin_promotion/repository/update.dart';
import 'package:commerce_server/src/features/admin_promotion/update_failure.dart';
import 'package:dust_dart/db.dart';

/// Replaces one active promotion without changing redemption history.
Future<Result<AdminPromotionResponse, AdminPromotionUpdateError>>
    updateAdminPromotion(
  AdminPromotionRepository reads,
  AdminPromotionUpdateRepository updates,
  String id,
  AdminUpdatePromotion input,
) async {
  if (id.isEmpty || id.trim() != id) {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.notFound,
    ));
  }
  final current = await reads.find(id);
  if (current case Err(:final error)) {
    return Err(AdminPromotionUpdateStorage(error));
  }
  final promotion = (current as Ok<AdminPromotionResponse?, SqlxError>).value;
  if (promotion == null) {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.notFound,
    ));
  }

  final type = input.type;
  final currency = input.currencyCodeValue;
  if (type != 'percentage' && type != 'fixed') {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.invalidDefinition,
    ));
  }
  if (type == 'percentage' && input.value > 10000) {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.invalidDefinition,
    ));
  }
  if (type == 'percentage' && currency != null) {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.invalidDefinition,
    ));
  }
  if (type == 'fixed' && (currency == null || currency.length != 3)) {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.invalidDefinition,
    ));
  }
  final startsAt = input.startsAtValue?.toUtc();
  final endsAt = input.endsAtValue?.toUtc();
  if (startsAt != null && endsAt != null && !endsAt.isAfter(startsAt)) {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.invalidDefinition,
    ));
  }
  final limit = input.usageLimitValue;
  if (limit != null && limit < promotion.usageCount) {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.invalidDefinition,
    ));
  }
  final conflict = await reads.codeExists(input.code, id);
  if (conflict case Err(:final error)) {
    return Err(AdminPromotionUpdateStorage(error));
  }
  if ((conflict as Ok<bool, SqlxError>).value) {
    return const Err(AdminPromotionUpdateRejected(
      AdminPromotionUpdateFailure.codeConflict,
    ));
  }

  final result = await updates.update(
    id,
    input.code,
    type,
    input.value,
    currency,
    startsAt?.toIso8601String() ?? '',
    endsAt?.toIso8601String() ?? '',
    limit,
  );
  if (result case Err(:final error)) {
    return Err(AdminPromotionUpdateStorage(error));
  }
  final updated = (result as Ok<AdminPromotionResponse?, SqlxError>).value;
  return updated == null
      ? const Err(AdminPromotionUpdateRejected(
          AdminPromotionUpdateFailure.notFound,
        ))
      : Ok(updated);
}

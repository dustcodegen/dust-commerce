import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_promotion/create_failure.dart';
import 'package:commerce_server/src/features/admin_promotion/create_response.dart';
import 'package:commerce_server/src/features/admin_promotion/model.dart';
import 'package:commerce_server/src/features/admin_promotion/repository/create.dart';
import 'package:commerce_server/src/features/admin_promotion/repository.dart';
import 'package:dust_dart/db.dart';

/// Creates one validated code-based promotion.
Future<Result<AdminPromotionCreateResponse, AdminPromotionCreateError>>
    createAdminPromotion(
  AdminPromotionCreateRepository promotions,
  AdminCreatePromotion input, {
  required String Function() nextId,
}) async {
  final type = input.type;
  final currency = input.currencyCodeValue;
  if (type != 'percentage' && type != 'fixed') {
    return const Err(AdminPromotionCreateRejected(
      AdminPromotionCreateFailure.invalidDefinition,
    ));
  }
  if (type == 'percentage' && input.value > 10000) {
    return const Err(AdminPromotionCreateRejected(
      AdminPromotionCreateFailure.invalidDefinition,
    ));
  }
  if (type == 'percentage' && currency != null) {
    return const Err(AdminPromotionCreateRejected(
      AdminPromotionCreateFailure.invalidDefinition,
    ));
  }
  if (type == 'fixed' && (currency == null || currency.length != 3)) {
    return const Err(AdminPromotionCreateRejected(
      AdminPromotionCreateFailure.invalidDefinition,
    ));
  }
  final startsAt = input.startsAtValue?.toUtc();
  final endsAt = input.endsAtValue?.toUtc();
  if (startsAt != null && endsAt != null && !endsAt.isAfter(startsAt)) {
    return const Err(AdminPromotionCreateRejected(
      AdminPromotionCreateFailure.invalidDefinition,
    ));
  }
  final inserted = await promotions.insert(
    nextId(),
    input.code,
    type,
    input.value,
    currency,
    startsAt?.toIso8601String() ?? '',
    endsAt?.toIso8601String() ?? '',
    input.usageLimitValue,
  );
  return switch (inserted) {
    Ok(value: final promotion?) => Ok(
        AdminPromotionCreateResponse(promotion: promotion),
      ),
    Ok(value: null) => const Err(AdminPromotionCreateRejected(
        AdminPromotionCreateFailure.codeConflict,
      )),
    Err(:final error) => Err(AdminPromotionCreateStorage(error)),
  };
}

/// Lists one bounded page of merchant-visible promotion rows.
Future<Result<AdminPromotionListResponse, SqlxError>> listAdminPromotions(
  AdminPromotionRepository promotions, {
  required String query,
  required AdminDateFilter createdAt,
  required AdminDateFilter updatedAt,
  required AdminPromotionOrder order,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final rows = await promotions.list(
    normalized,
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
    order.parameter,
    limit,
    offset,
  );
  if (rows case Err(:final error)) return Err(error);
  final total = await promotions.count(
    normalized,
    _value(createdAt.greaterThan),
    _value(createdAt.greaterThanOrEqual),
    _value(createdAt.lessThan),
    _value(createdAt.lessThanOrEqual),
    _value(updatedAt.greaterThan),
    _value(updatedAt.greaterThanOrEqual),
    _value(updatedAt.lessThan),
    _value(updatedAt.lessThanOrEqual),
  );
  if (total case Err(:final error)) return Err(error);
  return Ok(AdminPromotionListResponse(
    promotions: (rows as Ok<List<AdminPromotionResponse>, SqlxError>).value,
    count: (total as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

/// Reads one active merchant-visible promotion, or none when hidden.
Future<Result<Option<AdminPromotionDetailResponse>, SqlxError>>
    readAdminPromotion(AdminPromotionRepository promotions, String id) async {
  final result = await promotions.find(id);
  return switch (result) {
    Ok(value: final promotion?) =>
      Ok(Some(AdminPromotionDetailResponse(promotion: promotion))),
    Ok(value: null) => const Ok(None()),
    Err(:final error) => Err(error),
  };
}

String _value(Option<DateTime> value) => switch (value) {
      Some(value: final instant) => instant.toIso8601String(),
      None() => '',
    };

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_promotion/model.dart';
import 'package:commerce_server/src/features/admin_promotion/repository.dart';
import 'package:dust_dart/db.dart';

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

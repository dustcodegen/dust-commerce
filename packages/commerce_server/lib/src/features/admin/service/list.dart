import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/product_tag_model.dart';
import 'package:commerce_server/src/features/admin/product_type_model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of merchant-visible catalogue rows.
Future<Result<AdminProductListResponse, SqlxError>> listAdminProducts(
  AdminProductRepository products, {
  required String query,
  required List<AdminProductLifecycle> statuses,
  required List<String> tagIds,
  required List<String> typeIds,
  required AdminDateFilter createdAt,
  required AdminDateFilter updatedAt,
  required AdminProductOrder order,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final statusList = statuses.map((status) => status.name).join(',');
  final page = await products.list(
    normalized,
    statusList,
    tagIds.join(','),
    typeIds.join(','),
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
  if (page case Err(:final error)) return Err(error);

  final total = await products.count(
    normalized,
    statusList,
    tagIds.join(','),
    typeIds.join(','),
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

  return Ok(AdminProductListResponse(
    products: (page as Ok<List<AdminProductResponse>, SqlxError>).value,
    count: (total as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

/// Lists one bounded page of reusable product types.
Future<Result<AdminProductTypeListResponse, SqlxError>> listAdminProductTypes(
  AdminProductTypeRepository productTypes, {
  required String query,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final rows = await productTypes.list(normalized, limit, offset);
  if (rows case Err(:final error)) return Err(error);
  final count = await productTypes.count(normalized);
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminProductTypeListResponse(
    productTypes: (rows as Ok<List<AdminProductTypeResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

/// Lists one bounded page of reusable product tags.
Future<Result<AdminProductTagListResponse, SqlxError>> listAdminProductTags(
  AdminProductTagRepository productTags, {
  required String query,
  required int limit,
  required int offset,
}) async {
  final normalized = query.trim();
  final rows = await productTags.list(normalized, limit, offset);
  if (rows case Err(:final error)) return Err(error);
  final count = await productTags.count(normalized);
  if (count case Err(:final error)) return Err(error);
  return Ok(AdminProductTagListResponse(
    productTags: (rows as Ok<List<AdminProductTagResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

String _value(Option<DateTime> value) => switch (value) {
      Some(value: final instant) => instant.toIso8601String(),
      None() => '',
    };

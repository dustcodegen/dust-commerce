import 'dart:convert';

import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/handler/product_query.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

/// `GET /admin/products/export` — downloads the current filtered product table.
Future<Result<Response, Rejection>> exportAdminProductsHandler(
  Request request,
) async {
  final query = adminProductQueryOf(request);
  if (query case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final value = (query as Ok<AdminProductQuery, Rejection>).value;
  final result = await exportAdminProducts(
    deps.productExports,
    query: value.query,
    statuses: value.statuses,
    tagIds: value.tagIds,
    typeIds: value.typeIds,
    createdAt: value.createdAt,
    updatedAt: value.updatedAt,
    order: value.order,
  );
  return switch (result) {
    Ok(:final value) => Ok(streamed(
        Stream.value(utf8.encode(value)),
        contentType: 'text/csv; charset=utf-8',
        headers: const {
          'content-disposition': 'attachment; filename="product-export.csv"',
        },
      )),
    Err() => const Err(Rejection.internal()),
  };
}

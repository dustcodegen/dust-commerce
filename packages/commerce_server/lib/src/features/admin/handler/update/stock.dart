import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/service/update/stock.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateProductStock> _stockBody =
    ValidatedExtractable(
  JsonExtractable<AdminUpdateProductStock>(AdminUpdateProductStock.fromJson),
);

/// `PUT /admin/products/{id}/stock` — replaces selected aggregate stock rows.
Future<Result<AdminProductDetailResponse, Rejection>>
    updateAdminProductStockHandler(Request request) async {
  final productId = pathParametersOf(request)['id'];
  if (productId == null || productId.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final decoded = await _stockBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await updateAdminProductStock(
    deps.database,
    productId,
    (decoded as Ok<AdminUpdateProductStock, Rejection>).value,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminUpdateProductStockRejected(
        failure: AdminUpdateProductStockFailure.notFound,
      )
    ) =>
      Err(Rejection.notFound('A selected product variant')),
    Err(
      error: AdminUpdateProductStockRejected(
        failure: AdminUpdateProductStockFailure.invalid,
      )
    ) =>
      const Err(
          Rejection.status(422, 'Choose unique variants and valid stock')),
    Err(
      error: AdminUpdateProductStockRejected(
        failure: AdminUpdateProductStockFailure.unavailable,
      )
    ) =>
      const Err(Rejection.internal()),
    Err(error: AdminUpdateProductStockStorage()) =>
      const Err(Rejection.internal()),
  };
}

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/service/delete/product.dart';
import 'package:dust_server/server.dart';

/// `DELETE /admin/products/{id}` — retires one active merchant product.
Future<Result<AdminProductDeleted, Rejection>> deleteAdminProductHandler(
  Request request,
) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await deleteAdminProduct(deps.database, id);
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err(
      error: AdminDeleteProductRejected(
        failure: AdminDeleteProductFailure.notFound,
      )
    ) =>
      Err(Rejection.notFound('Product "$id"')),
    Err(error: AdminDeleteProductStorage()) => const Err(Rejection.internal()),
  };
}

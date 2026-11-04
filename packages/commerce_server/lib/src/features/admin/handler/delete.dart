import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

/// `DELETE /auth/admin/session` — revokes the current admin bearer.
Future<Result<AdminSessionDeleted, Rejection>> adminSignOutHandler(
  Request request,
) async {
  final deps = await request.state<AdminDeps>();
  final actor = await request.extract(const Extension<AuthenticatedAdmin>());
  final revoked = await adminSignOut(deps.deletes, actor.token);
  if (revoked case Err()) return const Err(Rejection.internal());
  return const Ok(AdminSessionDeleted(success: true));
}

/// `DELETE /admin/product-types/{id}` — soft-deletes one classification.
Future<Result<Response, Rejection>> deleteAdminProductTypeHandler(
  Request request,
) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product type id is required'));
  }
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await deleteAdminProductType(deps.database, id);
  return switch (result) {
    Ok(value: Ok()) => Ok(noContent()),
    Ok(value: Err(error: AdminDeleteProductTypeFailure.notFound)) =>
      Err(Rejection.notFound('Product type "$id"')),
    Err() => const Err(Rejection.internal()),
  };
}

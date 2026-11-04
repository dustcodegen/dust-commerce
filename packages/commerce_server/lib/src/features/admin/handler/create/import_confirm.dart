import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

/// `POST /admin/products/import/{transaction_id}/confirm` consumes one preview.
Future<Result<Response, Rejection>> confirmAdminProductImportHandler(
  Request request,
) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final transactionId = pathParametersOf(request)['transaction_id'];
  if (transactionId == null || transactionId.isEmpty) {
    return const Err(Rejection.badRequest('An import transaction is required'));
  }
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await confirmAdminProductImport(
    deps.database,
    transactionId: transactionId,
    adminUserId: admin.user.id,
    now: deps.clock.now(),
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(value: Ok()) => Ok(Response(202)),
    Ok(value: Err(error: AdminProductImportConfirmFailure.notFound)) =>
      Err(Rejection.notFound('Product import "$transactionId"')),
    Ok(value: Err(error: AdminProductImportConfirmFailure.unavailable)) =>
      const Err(Rejection.conflict('Product import is no longer available')),
    Ok(value: Err(error: AdminProductImportConfirmFailure.invalid)) =>
      const Err(Rejection.status(422, 'Product import is invalid')),
    Ok(value: Err(error: AdminProductImportConfirmFailure.conflict)) =>
      const Err(Rejection.conflict('Product catalogue changed after preview')),
    Err() => const Err(Rejection.internal()),
  };
}

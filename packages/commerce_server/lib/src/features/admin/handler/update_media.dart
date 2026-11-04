import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminUpdateProductMedia> _updateMediaBody =
    ValidatedExtractable(
  JsonExtractable<AdminUpdateProductMedia>(AdminUpdateProductMedia.fromJson),
);

/// `PUT /admin/products/{id}/media` — replace the complete ordered gallery.
Future<Result<AdminProductDetailResponse, Rejection>>
    updateAdminProductMediaHandler(Request request) async {
  final id = pathParametersOf(request)['id'];
  if (id == null || id.isEmpty) {
    return const Err(Rejection.badRequest('A product id is required'));
  }
  final decoded = await _updateMediaBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await updateAdminProductMedia(
    deps.database,
    id,
    (decoded as Ok<AdminUpdateProductMedia, Rejection>).value,
    nextId: deps.clock.nextId,
    mediaStorage: deps.mediaStorage,
  );
  return switch (result) {
    Ok(value: Ok(value: final product)) => Ok(product),
    Ok(value: Err(error: AdminUpdateProductMediaFailure.notFound)) =>
      Err(Rejection.notFound('Product "$id"')),
    Ok(value: Err(error: AdminUpdateProductMediaFailure.invalidMedia)) =>
      const Err(Rejection.status(
        422,
        'Use unique existing images or files returned by the upload endpoint',
      )),
    Err() => const Err(Rejection.internal()),
  };
}

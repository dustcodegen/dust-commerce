import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<AdminBatchImageVariants> _batchBody =
    ValidatedExtractable(
  JsonExtractable<AdminBatchImageVariants>(AdminBatchImageVariants.fromJson),
);

/// `POST /admin/products/{id}/images/{image_id}/variants/batch`.
Future<Result<AdminBatchImageVariantsResult, Rejection>>
    batchAdminImageVariantsHandler(Request request) async {
  final paths = pathParametersOf(request);
  final productId = paths['id'];
  final imageId = paths['image_id'];
  if (productId == null ||
      productId.isEmpty ||
      imageId == null ||
      imageId.isEmpty) {
    return const Err(
        Rejection.badRequest('Product and image ids are required'));
  }
  final decoded = await _batchBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await batchAdminImageVariants(
    deps.database,
    productId,
    imageId,
    (decoded as Ok<AdminBatchImageVariants, Rejection>).value,
  );
  return switch (result) {
    Ok(value: Ok(value: final changed)) => Ok(changed),
    Ok(value: Err(error: AdminBatchImageVariantsFailure.notFound)) =>
      Err(Rejection.notFound('Product image "$imageId"')),
    Ok(value: Err(error: AdminBatchImageVariantsFailure.invalidVariants)) =>
      const Err(Rejection.status(
        422,
        'Use unique active variants owned by this product',
      )),
    Err() => const Err(Rejection.internal()),
  };
}

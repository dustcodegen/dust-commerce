import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin/service/service.dart';
import 'package:dust_server/server.dart';

/// `POST /admin/products/import` — validates and stages one bounded CSV file.
Future<Result<AdminProductImportPreview, Rejection>>
    previewAdminProductImportHandler(Request request) async {
  final actor = await const Extension<AuthenticatedAdmin>().extract(request);
  if (actor case Err(:final error)) return Err(error);
  final body =
      await const MultipartExtractable(limit: 5 * 1024 * 1024).extract(request);
  if (body case Err(:final error)) return Err(error);
  final upload = (body as Ok<MultipartForm, Rejection>).value.file('file');
  if (upload case Err(:final error)) return Err(error);
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);

  final file = (upload as Ok<UploadedFile, Rejection>).value;
  final admin = (actor as Ok<AuthenticatedAdmin, Rejection>).value;
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final result = await previewAdminProductImport(
    deps.productImports,
    bytes: file.bytes,
    filename: file.filename ?? '',
    contentType: file.contentType ?? '',
    adminUserId: admin.user.id,
    nextId: deps.clock.nextId,
    now: deps.clock.now(),
  );
  return switch (result) {
    Ok(value: Ok(:final value)) => Ok(value),
    Ok(value: Err(error: AdminProductImportPreviewFailure.invalidFile)) =>
      const Err(Rejection.status(422, 'Upload one CSV file')),
    Ok(value: Err(error: AdminProductImportPreviewFailure.invalidCsv)) =>
      const Err(Rejection.status(422, 'Product CSV is invalid')),
    Err() => const Err(Rejection.internal()),
  };
}

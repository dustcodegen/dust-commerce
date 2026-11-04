import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/deps.dart';
import 'package:commerce_server/src/features/admin/media_storage.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_server/server.dart';

/// `POST /admin/uploads` — streams image parts into configured storage.
Future<Result<AdminUploadedFileList, Rejection>> uploadAdminMediaHandler(
  Request request,
) async {
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final body = await const StreamedMultipartExtractable(
    limit: adminMediaFileCountLimit * adminMediaFileLimit + 64 * 1024,
  ).extract(request);
  if (body case Err(:final error)) return Err(error);

  final files = <AdminUploadedFile>[];
  try {
    await (body as Ok<StreamedMultipart, Rejection>).value.forEachPart(
      (part) async {
        if (!part.isFile || part.name != 'files') return;
        if (files.length == adminMediaFileCountLimit) {
          throw const AdminMediaException(AdminMediaFailure.invalidCount);
        }
        files.add(await deps.mediaStorage.store(part));
      },
    );
  } on AdminMediaException catch (error) {
    await _discardStored(deps.mediaStorage, files);
    return switch (error.failure) {
      AdminMediaFailure.unavailable => const Err(
          Rejection.status(503, 'Product media storage is unavailable')),
      AdminMediaFailure.invalidImage => const Err(Rejection.status(
          422,
          'Upload JPEG, PNG, GIF, or WebP image files',
        )),
      AdminMediaFailure.invalidCount => const Err(Rejection.status(
          422,
          'Upload between 1 and 10 image files',
        )),
    };
  } on Rejection catch (error) {
    await _discardStored(deps.mediaStorage, files);
    return Err(error);
  } on Object {
    await _discardStored(deps.mediaStorage, files);
    return const Err(Rejection.internal());
  }

  if (files.isEmpty) {
    return const Err(Rejection.status(
      422,
      'Upload between 1 and 10 image files',
    ));
  }
  return Ok(AdminUploadedFileList(files: files));
}

/// `DELETE /admin/uploads/{key}` — discards only an unattached staged file.
Future<Result<Response, Rejection>> deleteAdminMediaHandler(
  Request request,
) async {
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final key = pathParametersOf(request)['key'];
  if (key == null) return const Err(Rejection.notFound('Media not found'));
  final url = deps.mediaStorage.urlFor(key);
  final references = await deps.media.countReferences(url);
  if (references case Err()) return const Err(Rejection.internal());
  if ((references as Ok<int, SqlxError>).value > 0) {
    return const Err(
      Rejection.conflict('Attached product media cannot be deleted'),
    );
  }
  try {
    await deps.mediaStorage.delete(key);
    return Ok(noContent());
  } on Object {
    return const Err(Rejection.internal());
  }
}

/// `GET /uploads/{key}` — publicly streams one immutable product image.
Future<Result<Response, Rejection>> readPublicMediaHandler(
  Request request,
) async {
  final state = await adminDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<AdminDeps, Rejection>).value;
  final key = pathParametersOf(request)['key'];
  if (key == null) return const Err(Rejection.notFound('Media not found'));
  final found = await deps.mediaStorage.find(key);
  return switch (found) {
    Some(:final value) => Ok(streamed(
        value.file.openRead(),
        contentType: value.mimeType,
        headers: {
          'content-length': '${value.size}',
          'cache-control': 'public, max-age=31536000, immutable',
        },
      )),
    None() => const Err(Rejection.notFound('Media not found')),
  };
}

Future<void> _discardStored(
  AdminMediaStorage storage,
  List<AdminUploadedFile> files,
) async {
  for (final file in files) {
    try {
      await storage.delete(file.id);
    } on Object {
      // Best effort after a failed multipart request; the primary error wins.
    }
  }
}

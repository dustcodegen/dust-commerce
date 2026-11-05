import 'dart:convert';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/features/admin/service/create/import_parser.dart';
import 'package:dust_dart/db.dart';

/// Business reasons a product-import preview can be rejected.
enum AdminProductImportPreviewFailure {
  /// File name or declared media type is not a supported CSV upload.
  invalidFile,

  /// CSV structure or one of its bounded product rows is invalid.
  invalidCsv,
}

/// Error crossing the Admin product-import preview boundary.
sealed class AdminProductImportPreviewError {
  /// Creates one product-import preview error.
  const AdminProductImportPreviewError();
}

/// A business rejection that is safe to expose to the handler.
final class AdminProductImportPreviewRejected
    extends AdminProductImportPreviewError {
  /// Creates one business rejection.
  const AdminProductImportPreviewRejected(this.failure);

  /// The stable business reason.
  final AdminProductImportPreviewFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class AdminProductImportPreviewStorage
    extends AdminProductImportPreviewError {
  /// Creates one storage failure.
  const AdminProductImportPreviewStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Validates and stages a CSV without mutating any catalogue table.
Future<Result<AdminProductImportPreview, AdminProductImportPreviewError>>
    previewAdminProductImport(
  AdminProductImportRepository imports, {
  required List<int> bytes,
  required String filename,
  required String contentType,
  required String adminUserId,
  required String Function() nextId,
  required DateTime now,
}) async {
  final mime = contentType.split(';').first.trim().toLowerCase();
  final safeFilename = _safeFilename(filename);
  if (safeFilename == null ||
      !safeFilename.toLowerCase().endsWith('.csv') ||
      !const {'text/csv', 'application/vnd.ms-excel'}.contains(mime)) {
    return const Err(AdminProductImportPreviewRejected(
      AdminProductImportPreviewFailure.invalidFile,
    ));
  }
  String source;
  try {
    source = utf8.decode(bytes);
  } on FormatException {
    return const Err(AdminProductImportPreviewRejected(
      AdminProductImportPreviewFailure.invalidCsv,
    ));
  }
  final parsed = parseAdminProductImport(source);
  if (parsed case Err()) {
    return const Err(AdminProductImportPreviewRejected(
      AdminProductImportPreviewFailure.invalidCsv,
    ));
  }
  final document = (parsed as Ok<AdminProductImportDocument, String>).value;
  final encodedIdentities = jsonEncode(document.identities);
  final ambiguous = await imports.countAmbiguous(encodedIdentities);
  if (ambiguous case Err(:final error)) {
    return Err(AdminProductImportPreviewStorage(error));
  }
  if ((ambiguous as Ok<int, SqlxError>).value > 0) {
    return const Err(AdminProductImportPreviewRejected(
      AdminProductImportPreviewFailure.invalidCsv,
    ));
  }
  final identities = await imports.countExisting(encodedIdentities);
  if (identities case Err(:final error)) {
    return Err(AdminProductImportPreviewStorage(error));
  }
  final toUpdate = (identities as Ok<int, SqlxError>).value;
  final toCreate = document.productCount - toUpdate;
  final transactionId = nextId();
  final inserted = await imports.insert(
    transactionId,
    adminUserId,
    safeFilename,
    document.payloadJson,
    toCreate,
    toUpdate,
    now.toUtc().add(const Duration(hours: 24)).toIso8601String(),
  );
  if (inserted case Err(:final error)) {
    return Err(AdminProductImportPreviewStorage(error));
  }
  return Ok(AdminProductImportPreview(
    transactionId: transactionId,
    summary: AdminProductImportSummary(
      toCreate: toCreate,
      toUpdate: toUpdate,
    ),
  ));
}

String? _safeFilename(String value) {
  final filename = value.split(RegExp(r'[/\\]')).last.trim();
  if (filename.isEmpty ||
      filename.length > 255 ||
      filename.contains(RegExp(r'[\x00-\x1f\x7f]'))) {
    return null;
  }
  return filename;
}

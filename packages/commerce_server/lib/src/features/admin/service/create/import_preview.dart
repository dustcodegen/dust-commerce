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

/// Validates and stages a CSV without mutating any catalogue table.
Future<
    Result<Result<AdminProductImportPreview, AdminProductImportPreviewFailure>,
        SqlxError>> previewAdminProductImport(
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
    return const Ok(Err(AdminProductImportPreviewFailure.invalidFile));
  }
  String source;
  try {
    source = utf8.decode(bytes);
  } on FormatException {
    return const Ok(Err(AdminProductImportPreviewFailure.invalidCsv));
  }
  final parsed = parseAdminProductImport(source);
  if (parsed case Err()) {
    return const Ok(Err(AdminProductImportPreviewFailure.invalidCsv));
  }
  final document = (parsed as Ok<AdminProductImportDocument, String>).value;
  final encodedIdentities = jsonEncode(document.identities);
  final ambiguous = await imports.countAmbiguous(encodedIdentities);
  if (ambiguous case Err(:final error)) return Err(error);
  if ((ambiguous as Ok<int, SqlxError>).value > 0) {
    return const Ok(Err(AdminProductImportPreviewFailure.invalidCsv));
  }
  final identities = await imports.countExisting(encodedIdentities);
  if (identities case Err(:final error)) return Err(error);
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
  if (inserted case Err(:final error)) return Err(error);
  return Ok(Ok(AdminProductImportPreview(
    transactionId: transactionId,
    summary: AdminProductImportSummary(
      toCreate: toCreate,
      toUpdate: toUpdate,
    ),
  )));
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

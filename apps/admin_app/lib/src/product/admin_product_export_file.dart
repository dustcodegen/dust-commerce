import 'dart:convert';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';

/// Prompts for a destination and writes a UTF-8 product CSV snapshot.
Future<bool> saveAdminProductExport(String csv) async {
  const name = 'product-export.csv';
  final location = await getSaveLocation(
    suggestedName: name,
    acceptedTypeGroups: const [
      XTypeGroup(label: 'CSV', extensions: ['csv'], mimeTypes: ['text/csv']),
    ],
  );
  if (location == null) return false;
  final file = XFile.fromData(
    Uint8List.fromList(utf8.encode(csv)),
    mimeType: 'text/csv',
    name: name,
  );
  await file.saveTo(location.path);
  return true;
}

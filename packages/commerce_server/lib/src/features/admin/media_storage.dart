import 'dart:io';

import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_server/server.dart';

part 'local_media_storage.dart';
part 'media_format.dart';

/// Minimal storage-owned identity used while product attachment is in flight.
typedef AdminMediaClaim = ({String id, String url});

/// Maximum number of bytes accepted for one product image.
const int adminMediaFileLimit = 5 * 1024 * 1024;

/// Maximum number of images accepted in one upload request or product.
const int adminMediaFileCountLimit = 10;

/// Why a merchant upload cannot be stored.
enum AdminMediaFailure {
  /// The configured storage adapter is unavailable.
  unavailable,

  /// The part is empty or its signature is not a supported image.
  invalidImage,

  /// The request contains no files or too many files.
  invalidCount,
}

/// Typed media failure kept out of public response details.
final class AdminMediaException implements Exception {
  /// Creates a media failure.
  const AdminMediaException(this.failure);

  /// Classified failure mapped by the HTTP boundary.
  final AdminMediaFailure failure;
}

/// One immutable file ready to stream to a public product surface.
final class AdminStoredMediaAsset {
  /// Creates a stored media read result.
  const AdminStoredMediaAsset({
    required this.file,
    required this.mimeType,
    required this.size,
  });

  /// File opened only after the opaque key has passed validation.
  final File file;

  /// Content type inferred from the key written after signature validation.
  final String mimeType;

  /// Exact content length used by the public response.
  final int size;
}

/// Storage boundary used by upload, product creation, deletion, and reads.
abstract interface class AdminMediaStorage {
  /// Persists one streamed multipart file under a server-generated key.
  Future<AdminUploadedFile> store(MultipartPart part);

  /// Opens one public immutable file by opaque key.
  Future<Option<AdminStoredMediaAsset>> find(String key);

  /// Deletes one unreferenced staged file.
  Future<bool> delete(String key);

  /// Whether [key] and [url] are a pair issued by this storage adapter.
  bool accepts(String key, String url);

  /// Reserves existing staged files while a product transaction attaches them.
  bool claim(List<AdminMediaClaim> media);

  /// Releases reservations after the product transaction finishes.
  void release(List<AdminMediaClaim> media);

  /// Public URL corresponding to [key].
  String urlFor(String key);
}

/// Safe default for tests and embeddings that do not configure file storage.
final class UnavailableAdminMediaStorage implements AdminMediaStorage {
  /// Creates an unavailable storage adapter.
  const UnavailableAdminMediaStorage();

  @override
  bool accepts(String key, String url) => false;

  @override
  bool claim(List<AdminMediaClaim> media) => media.isEmpty;

  @override
  Future<bool> delete(String key) async => false;

  @override
  Future<Option<AdminStoredMediaAsset>> find(String key) async => const None();

  @override
  Future<AdminUploadedFile> store(MultipartPart part) async =>
      throw const AdminMediaException(AdminMediaFailure.unavailable);

  @override
  void release(List<AdminMediaClaim> media) {}

  @override
  String urlFor(String key) => '';
}

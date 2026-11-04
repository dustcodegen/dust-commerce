import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin/media_storage.dart';
import 'package:commerce_server/src/features/admin/model.dart';
import 'package:commerce_server/src/features/admin/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// Business reason an existing product gallery cannot be replaced.
enum AdminUpdateProductMediaFailure {
  /// No active product owns the requested identifier.
  notFound,

  /// Media is duplicated, mismatched, missing, or not owned by this server.
  invalidMedia,
}

/// Atomically replaces image order, membership, and thumbnail.
Future<
    Result<Result<AdminProductDetailResponse, AdminUpdateProductMediaFailure>,
        SqlxError>> updateAdminProductMedia(
  CommerceDatabase database,
  String productId,
  AdminUpdateProductMedia input, {
  required String Function() nextId,
  required AdminMediaStorage mediaStorage,
}) async {
  var claims = <AdminMediaClaim>[];
  var claimed = false;
  try {
    return await database.transaction((tx) async {
      final reads = AdminProductReadRepository(tx);
      final currentResult = await reads.findById(productId);
      if (currentResult case Err(:final error)) return Err(error);
      final current = optionOf(
        (currentResult as Ok<AdminProductDetailResponse?, SqlxError>).value,
      );
      if (current case None()) {
        return const Ok(Err(AdminUpdateProductMediaFailure.notFound));
      }

      final prepared = _prepareMediaUpdate(
        input.media,
        (current as Some<AdminProductDetailResponse>).value.images,
        mediaStorage,
      );
      if (prepared case Err()) {
        return const Ok(Err(AdminUpdateProductMediaFailure.invalidMedia));
      }
      final update =
          (prepared as Ok<_PreparedMediaUpdate, AdminUpdateProductMediaFailure>)
              .value;
      claims = update.claims;
      if (claims.isNotEmpty) {
        claimed = mediaStorage.claim(claims);
        if (!claimed) {
          return const Ok(Err(AdminUpdateProductMediaFailure.invalidMedia));
        }
      }

      final writes = AdminProductUpdateRepository(tx);
      final maxRank = await writes.maxImageRank(productId);
      if (maxRank case Err(:final error)) return Err(error);
      final offset =
          (maxRank as Ok<int, SqlxError>).value + update.media.length + 1;
      final shifted = await writes.shiftImageRanks(productId, offset);
      if (shifted case Err(:final error)) return Err(error);

      for (var rank = 0; rank < update.media.length; rank++) {
        final item = update.media[rank];
        final write = update.existingIds.contains(item.id)
            ? await writes.rankImage(item.id, productId, rank)
            : await writes.insertImage(nextId(), productId, item.url, rank);
        if (write case Err(:final error)) return Err(error);
      }

      final links = AdminProductImageVariantRepository(tx);
      final unlinked = await links.removeForShiftedImages(productId, offset);
      if (unlinked case Err(:final error)) return Err(error);
      final removed = await writes.deleteShiftedImages(productId, offset);
      if (removed case Err(:final error)) return Err(error);
      final thumbnail = await writes.updateThumbnail(
        productId,
        update.thumbnail,
      );
      if (thumbnail case Err(:final error)) return Err(error);

      final refreshed = await reads.findById(productId);
      if (refreshed case Err(:final error)) return Err(error);
      return switch (optionOf(
        (refreshed as Ok<AdminProductDetailResponse?, SqlxError>).value,
      )) {
        Some(:final value) => Ok(Ok(value)),
        None() => const Ok(Err(AdminUpdateProductMediaFailure.notFound)),
      };
    });
  } finally {
    if (claimed) mediaStorage.release(claims);
  }
}

Result<_PreparedMediaUpdate, AdminUpdateProductMediaFailure>
    _prepareMediaUpdate(
  List<AdminCreateProductMedia> media,
  List<AdminProductImage> current,
  AdminMediaStorage storage,
) {
  if (media.length > adminMediaFileCountLimit) {
    return const Err(AdminUpdateProductMediaFailure.invalidMedia);
  }
  final existing = {for (final image in current) image.id: image.url};
  final ids = <String>{};
  final urls = <String>{};
  final claims = <AdminMediaClaim>[];
  String? thumbnail;
  for (final item in media) {
    final existingUrl = existing[item.id];
    if (!item.validate().isValid ||
        !ids.add(item.id) ||
        !urls.add(item.url) ||
        (existingUrl != null
            ? existingUrl != item.url
            : !storage.accepts(item.id, item.url)) ||
        (item.isThumbnail && thumbnail != null)) {
      return const Err(AdminUpdateProductMediaFailure.invalidMedia);
    }
    if (existingUrl == null) claims.add((id: item.id, url: item.url));
    if (item.isThumbnail) thumbnail = item.url;
  }
  return Ok(_PreparedMediaUpdate(
    media: media,
    existingIds: existing.keys.toSet(),
    claims: claims,
    thumbnail: thumbnail,
  ));
}

final class _PreparedMediaUpdate {
  const _PreparedMediaUpdate({
    required this.media,
    required this.existingIds,
    required this.claims,
    required this.thumbnail,
  });

  final List<AdminMediaClaim> claims;
  final Set<String> existingIds;
  final List<AdminCreateProductMedia> media;
  final String? thumbnail;
}

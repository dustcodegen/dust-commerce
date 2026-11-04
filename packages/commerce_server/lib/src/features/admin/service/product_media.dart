part of 'create.dart';

Result<List<_PreparedMedia>, AdminCreateProductFailure> _prepareProductMedia(
  List<AdminCreateProductMedia> input,
  AdminMediaStorage storage,
) {
  if (input.length > adminMediaFileCountLimit) {
    return const Err(AdminCreateProductFailure.invalidMedia);
  }
  final ids = <String>{};
  final urls = <String>{};
  var thumbnails = 0;
  final media = <_PreparedMedia>[];
  for (final item in input) {
    if (!item.validate().isValid ||
        !ids.add(item.id) ||
        !urls.add(item.url) ||
        !storage.accepts(item.id, item.url) ||
        (item.isThumbnail && ++thumbnails > 1)) {
      return const Err(AdminCreateProductFailure.invalidMedia);
    }
    media.add(_PreparedMedia(item.url, isThumbnail: item.isThumbnail));
  }
  return Ok(media);
}

final class _PreparedMedia {
  const _PreparedMedia(this.url, {required this.isThumbnail});

  final bool isThumbnail;
  final String url;
}

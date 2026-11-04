part of 'media_storage.dart';

enum _MediaFormat {
  jpeg('jpg', 'image/jpeg'),
  png('png', 'image/png'),
  gif('gif', 'image/gif'),
  webp('webp', 'image/webp');

  const _MediaFormat(this.extension, this.mimeType);

  final String extension;
  final String mimeType;

  static _MediaFormat? fromHeader(List<int> bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return jpeg;
    }
    if (bytes.length >= 8 &&
        _matches(
            bytes, const [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])) {
      return png;
    }
    if (bytes.length >= 6 &&
        (_matches(bytes, 'GIF87a'.codeUnits) ||
            _matches(bytes, 'GIF89a'.codeUnits))) {
      return gif;
    }
    if (bytes.length >= 12 &&
        _matches(bytes, 'RIFF'.codeUnits) &&
        _matches(bytes, 'WEBP'.codeUnits, offset: 8)) {
      return webp;
    }
    return null;
  }

  static bool _matches(List<int> bytes, List<int> signature, {int offset = 0}) {
    if (bytes.length < offset + signature.length) return false;
    for (var index = 0; index < signature.length; index++) {
      if (bytes[offset + index] != signature[index]) return false;
    }
    return true;
  }
}

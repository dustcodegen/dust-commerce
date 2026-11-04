part of 'media_storage.dart';

/// Durable single-node media storage with streamed, signature-checked writes.
final class LocalAdminMediaStorage implements AdminMediaStorage {
  /// Creates a local storage adapter.
  LocalAdminMediaStorage({
    required Directory root,
    required Uri publicBaseUrl,
    required String Function() nextKey,
  })  : _root = root,
        _baseUrl = publicBaseUrl.toString().replaceFirst(RegExp(r'/$'), ''),
        _nextKey = nextKey;

  final Directory _root;
  final String _baseUrl;
  final String Function() _nextKey;
  final Set<String> _claimed = {};
  final Set<String> _deleting = {};

  /// Creates the storage directory before the server accepts traffic.
  Future<void> prepare() => _root.create(recursive: true);

  @override
  bool accepts(String key, String url) =>
      _validKey.hasMatch(key) && url == urlFor(key);

  @override
  bool claim(List<AdminMediaClaim> media) {
    final keys = media.map((item) => item.id).toList();
    if (keys.toSet().length != keys.length ||
        media.any((item) =>
            !accepts(item.id, item.url) ||
            _claimed.contains(item.id) ||
            _deleting.contains(item.id) ||
            !File('${_root.path}/${item.id}').existsSync())) {
      return false;
    }
    _claimed.addAll(keys);
    return true;
  }

  @override
  Future<bool> delete(String key) async {
    if (!_validKey.hasMatch(key) ||
        _claimed.contains(key) ||
        !_deleting.add(key)) {
      return false;
    }
    final file = File('${_root.path}/$key');
    try {
      if (!file.existsSync()) return false;
      await file.delete();
      return true;
    } finally {
      _deleting.remove(key);
    }
  }

  @override
  Future<Option<AdminStoredMediaAsset>> find(String key) async {
    if (!_validKey.hasMatch(key)) return const None();
    final format = _formatForKey(key);
    if (format == null) return const None();
    final file = File('${_root.path}/$key');
    if (!file.existsSync()) return const None();
    return Some(AdminStoredMediaAsset(
      file: file,
      mimeType: format.mimeType,
      size: await file.length(),
    ));
  }

  @override
  Future<AdminUploadedFile> store(MultipartPart part) async {
    if (!part.isFile) {
      throw const AdminMediaException(AdminMediaFailure.invalidImage);
    }
    await prepare();
    final opaque = _nextKey();
    if (!_opaqueKey.hasMatch(opaque)) {
      throw StateError('Media storage generated an unsafe key');
    }
    final pending = File('${_root.path}/.$opaque.pending');
    final sink = pending.openWrite(mode: FileMode.writeOnly);
    int size;
    try {
      size = await part.writeTo(sink, limit: adminMediaFileLimit);
    } on Object {
      await sink.close();
      if (pending.existsSync()) await pending.delete();
      rethrow;
    }
    await sink.close();

    try {
      if (size == 0) {
        throw const AdminMediaException(AdminMediaFailure.invalidImage);
      }
      final opened = await pending.open();
      final header = await opened.read(12);
      await opened.close();
      final format = _MediaFormat.fromHeader(header);
      if (format == null) {
        throw const AdminMediaException(AdminMediaFailure.invalidImage);
      }
      final key = '$opaque.${format.extension}';
      final stored = await pending.rename('${_root.path}/$key');
      return AdminUploadedFile(
        id: key,
        url: urlFor(key),
        filename: _safeFilename(part.filename!, format.extension),
        mimeType: format.mimeType,
        size: await stored.length(),
      );
    } on Object {
      if (pending.existsSync()) await pending.delete();
      rethrow;
    }
  }

  @override
  String urlFor(String key) => '$_baseUrl/uploads/$key';

  @override
  void release(List<AdminMediaClaim> media) {
    _claimed.removeAll(media.map((item) => item.id));
  }

  static final RegExp _opaqueKey = RegExp(r'^[A-Za-z0-9_-]{8,128}$');
  static final RegExp _validKey =
      RegExp(r'^[A-Za-z0-9_-]{8,128}\.(?:jpg|png|gif|webp)$');

  static _MediaFormat? _formatForKey(String key) =>
      switch (key.split('.').last) {
        'jpg' => _MediaFormat.jpeg,
        'png' => _MediaFormat.png,
        'gif' => _MediaFormat.gif,
        'webp' => _MediaFormat.webp,
        _ => null,
      };

  static String _safeFilename(String source, String extension) {
    final leaf = source.split(RegExp(r'[/\\]')).last;
    final printable = leaf.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '').trim();
    if (printable.isEmpty) return 'image.$extension';
    return printable.length <= 255 ? printable : printable.substring(0, 255);
  }
}

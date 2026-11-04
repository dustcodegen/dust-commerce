part of 'admin_product_media_editor.dart';

extension on _AdminProductMediaEditorState {
  Future<void> _pickMedia() async {
    final selected = await openFiles(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'Images',
          extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
        ),
      ],
    );
    if (!mounted || selected.isEmpty) return;
    if (selected.length > 10 - _media.length) {
      _showInputFailure('A product can have at most 10 images.');
      return;
    }
    final files = <MultipartFile>[];
    for (final file in selected) {
      final length = await file.length();
      if (length == 0 || length > 5 * 1024 * 1024) {
        _showInputFailure('Each image must be between 1 byte and 5 MB.');
        return;
      }
      files.add(MultipartFile.fromBytes(
        await file.readAsBytes(),
        filename: file.name,
      ));
    }
    if (!mounted) return;
    final uploaded =
        await context.readAdminProductDetailViewModel().uploadMedia(files);
    if (!mounted) return;
    if (uploaded case Some(:final value)) {
      _rebuild(() {
        for (final file in value) {
          _media.add(_MediaDraft(
            id: file.id,
            url: file.url,
            isThumbnail: _media.isEmpty,
            staged: true,
          ));
        }
      });
    }
  }

  void _reorder(int oldIndex, int newIndex) => _rebuild(() {
        final item = _media.removeAt(oldIndex);
        _media.insert(newIndex, item);
      });

  void _makeThumbnail(int index) => _rebuild(() {
        for (var item = 0; item < _media.length; item++) {
          _media[item].isThumbnail = item == index;
        }
      });

  void _toggleSelection(String id, bool selected) => _rebuild(() {
        selected ? _selection.add(id) : _selection.remove(id);
      });

  void _promoteSelection() {
    if (_selection.length != 1) return;
    final index = _media.indexWhere((item) => item.id == _selection.single);
    if (index < 0) return;
    _makeThumbnail(index);
    _rebuild(_selection.clear);
  }

  Future<void> _deleteSelection() async {
    final ids = _selection.toList(growable: false);
    for (final id in ids) {
      final index = _media.indexWhere((item) => item.id == id);
      if (index >= 0) await _remove(index);
      if (!mounted) return;
    }
    _rebuild(_selection.clear);
  }

  Future<void> _remove(int index) async {
    final item = _media[index];
    if (item.staged &&
        !await context
            .readAdminProductDetailViewModel()
            .discardUpload(item.id)) {
      return;
    }
    if (mounted) {
      _rebuild(() {
        _media.removeAt(index);
        _selection.remove(item.id);
      });
    }
  }

  Future<void> _save() async {
    final saved = await context.readAdminProductDetailViewModel().updateMedia(
          widget.product.id,
          AdminUpdateProductMedia(
            media: [
              for (final item in _media)
                AdminCreateProductMedia(
                  id: item.id,
                  url: item.url,
                  isThumbnail: item.isThumbnail,
                ),
            ],
          ),
        );
    if (saved && mounted) Navigator.of(context).pop(true);
  }

  Future<void> _cancel() async {
    if (_discarding) return;
    _rebuild(() => _discarding = true);
    for (final item in _media.where((item) => item.staged)) {
      final deleted = await context
          .readAdminProductDetailViewModel()
          .discardUpload(item.id);
      if (!mounted) return;
      if (!deleted) {
        _rebuild(() => _discarding = false);
        return;
      }
    }
    if (mounted) Navigator.of(context).pop(false);
  }

  void _showInputFailure(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
}

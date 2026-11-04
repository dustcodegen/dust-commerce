part of 'admin_product_create_page.dart';

extension on _AdminProductCreatePageState {
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
    final remaining = 10 - _media.length;
    if (selected.length > remaining) {
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
        await context.readAdminProductCreateViewModel().uploadMedia(files);
    if (!mounted) return;
    if (uploaded case Some(:final value)) {
      _rebuild(() {
        for (final file in value) {
          _media.add(_UploadedMediaDraft(
            file,
            isThumbnail: _media.isEmpty,
          ));
        }
      });
    }
  }

  void _reorderMedia(int oldIndex, int newIndex) {
    _rebuild(() {
      final item = _media.removeAt(oldIndex);
      _media.insert(newIndex, item);
    });
  }

  void _makeThumbnail(int index) => _rebuild(() {
        for (var item = 0; item < _media.length; item++) {
          _media[item].isThumbnail = item == index;
        }
      });

  Future<void> _removeMedia(int index) async {
    final item = _media[index];
    final deleted = await context
        .readAdminProductCreateViewModel()
        .discardUpload(item.file.id);
    if (!mounted || !deleted) return;
    _rebuild(() {
      final wasThumbnail = _media.removeAt(index).isThumbnail;
      if (wasThumbnail && _media.isNotEmpty) _media.first.isThumbnail = true;
    });
  }

  Future<void> _cancel() async {
    if (_discarding) return;
    _rebuild(() => _discarding = true);
    for (final item in List<_UploadedMediaDraft>.of(_media)) {
      final deleted = await context
          .readAdminProductCreateViewModel()
          .discardUpload(item.file.id);
      if (!mounted) return;
      if (!deleted) {
        _rebuild(() => _discarding = false);
        return;
      }
    }
    if (mounted) Navigator.of(context).pop();
  }
}

final class _UploadedMediaDraft {
  _UploadedMediaDraft(this.file, {required this.isThumbnail});

  final AdminUploadedFile file;
  bool isThumbnail;
}

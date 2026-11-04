import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:admin_app/src/product/admin_product_detail_state.dart';
import 'package:admin_app/src/product/admin_product_thumbnail_badge.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

part 'admin_product_media_editor_actions.dart';
part 'admin_product_media_editor_tile.dart';
part 'admin_product_media_editor_view.dart';

/// Opens the focused Medusa-shaped media management surface.
Future<bool?> showAdminProductMediaEditor(
  BuildContext context,
  AdminProductDetail product,
) =>
    showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Close media editor',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (_, __, ___) => _AdminProductMediaEditor(product: product),
    );

final class _AdminProductMediaEditor extends StatefulWidget {
  const _AdminProductMediaEditor({required this.product});

  final AdminProductDetail product;

  @override
  State<_AdminProductMediaEditor> createState() =>
      _AdminProductMediaEditorState();
}

final class _AdminProductMediaEditorState
    extends State<_AdminProductMediaEditor> {
  late final List<_MediaDraft> _media;
  final _selection = <String>{};
  var _discarding = false;

  @override
  void initState() {
    super.initState();
    _media = [
      for (var index = 0; index < widget.product.images.length; index++)
        _MediaDraft(
          id: widget.product.images[index].id,
          url: widget.product.images[index].url,
          isThumbnail:
              widget.product.images[index].url == widget.product.thumbnail,
        ),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminProductDetailViewModel().clearFailure();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductDetailViewModel().value;
    final busy = state.isSaving || _discarding;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _header(busy),
                Expanded(child: _editorBody(state, busy)),
                if (state.failure case Some(value: final message))
                  _failureBanner(message),
                _footer(busy),
              ],
            ),
            if (_selection.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: 76,
                child: Center(child: _commandBar(busy)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(bool busy) => Container(
        height: 56,
        padding: const EdgeInsets.only(left: 24, right: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Edit media',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: busy ? null : _cancel,
              icon: const Icon(Icons.close_rounded, size: 18),
            ),
          ],
        ),
      );

  Widget _footer(bool busy) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
                onPressed: busy ? null : _cancel, child: const Text('Cancel')),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: busy ? null : _save,
              child: _progress(busy, 'Save'),
            ),
          ],
        ),
      );

  Widget _progress(bool busy, String label) => busy
      ? const SizedBox.square(
          dimension: 15,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
      : Text(label);

  Widget _commandBar(bool busy) => Material(
        color: const Color(0xFF202020),
        borderRadius: BorderRadius.circular(8),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_selection.length} selected',
                style: const TextStyle(color: Colors.white),
              ),
              if (_selection.length == 1) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: busy ? null : _promoteSelection,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Make thumbnail'),
                ),
              ],
              const SizedBox(width: 8),
              TextButton(
                onPressed: busy ? null : _deleteSelection,
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
      );

  void _rebuild(VoidCallback callback) => setState(callback);
}

final class _MediaDraft {
  _MediaDraft({
    required this.id,
    required this.url,
    required this.isThumbnail,
    this.staged = false,
  });

  final String id;
  bool isThumbnail;
  final bool staged;
  final String url;
}

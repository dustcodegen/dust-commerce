import 'package:admin_app/src/product/admin_product_import_chrome.dart';
import 'package:admin_app/src/product/admin_product_import_template.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's right-side product-import preview flow.
Future<bool?> showAdminProductImportDrawer(BuildContext context) =>
    showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close product import',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => const Padding(
        padding: EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: _ProductImportDrawer(),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );

final class _ProductImportDrawer extends StatefulWidget {
  const _ProductImportDrawer();

  @override
  State<_ProductImportDrawer> createState() => _ProductImportDrawerState();
}

final class _ProductImportDrawerState extends State<_ProductImportDrawer> {
  XFile? _file;
  AdminProductImportPreview? _preview;
  String? _failure;
  var _busy = false;

  @override
  Widget build(BuildContext context) => AdminProductImportChrome(
        file: _file,
        preview: _preview,
        failure: _failure,
        busy: _busy,
        onPick: _busy ? null : _pick,
        onRemove: _busy ? null : _remove,
        onDownloadTemplate: _busy ? null : _downloadTemplate,
        onImport: _busy || _preview == null ? null : _confirm,
        onClose: _busy ? null : () => Navigator.pop(context),
      );

  Future<void> _pick() async {
    try {
      await _pickFile();
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _failure = 'Unable to read the CSV file. Try again.';
      });
    }
  }

  Future<void> _pickFile() async {
    final selected = await openFile(acceptedTypeGroups: const [
      XTypeGroup(
        label: 'CSV',
        extensions: ['csv'],
        mimeTypes: ['text/csv', 'application/vnd.ms-excel'],
      ),
    ]);
    if (!mounted || selected == null) return;
    final length = await selected.length();
    if (!mounted) return;
    if (!selected.name.toLowerCase().endsWith('.csv') ||
        length == 0 ||
        length > 5 * 1024 * 1024) {
      setState(() => _failure = 'Choose a non-empty CSV up to 5 MB.');
      return;
    }
    setState(() {
      _file = selected;
      _preview = null;
      _failure = null;
      _busy = true;
    });
    final file = MultipartFile.fromBytes(
      await selected.readAsBytes(),
      filename: selected.name,
      contentType: DioMediaType.parse('text/csv'),
    );
    if (!mounted) return;
    final result =
        await context.readAdminProductViewModel().previewImport(file);
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (result) {
        case Ok(:final value):
          _preview = value;
        case Err(:final error):
          _failure = error;
      }
    });
  }

  void _remove() => setState(() {
        _file = null;
        _preview = null;
        _failure = null;
      });

  Future<void> _downloadTemplate() async {
    try {
      await saveAdminProductImportTemplate();
    } on Object {
      if (mounted) {
        setState(() => _failure = 'Unable to save the template. Try again.');
      }
    }
  }

  Future<void> _confirm() async {
    final preview = _preview;
    if (preview == null) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await context
        .readAdminProductViewModel()
        .confirmImport(preview.transactionId);
    if (!mounted) return;
    switch (result) {
      case Ok():
        Navigator.pop(context, true);
      case Err(:final error):
        setState(() {
          _busy = false;
          _failure = error;
        });
    }
  }
}

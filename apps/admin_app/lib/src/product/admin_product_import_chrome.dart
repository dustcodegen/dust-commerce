import 'package:admin_app/src/product/admin_product_import_summary.dart';
import 'package:admin_app/src/product/admin_product_import_upload.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

part 'admin_product_import_chrome_sections.dart';

/// Stable drawer chrome around the product-import state and actions.
final class AdminProductImportChrome extends StatelessWidget {
  /// Creates the Medusa-shaped import layout.
  const AdminProductImportChrome({
    required this.file,
    required this.preview,
    required this.failure,
    required this.busy,
    required this.onPick,
    required this.onRemove,
    required this.onDownloadTemplate,
    required this.onImport,
    required this.onClose,
    super.key,
  });

  /// Whether local or server preprocessing is active.
  final bool busy;

  /// Selected CSV file.
  final XFile? file;

  /// Merchant-facing preprocessing failure.
  final String? failure;

  /// Closes the drawer without mutating the catalogue.
  final VoidCallback? onClose;

  /// Downloads the canonical CSV header template.
  final VoidCallback? onDownloadTemplate;

  /// Opens the platform CSV picker.
  final VoidCallback? onPick;

  /// Atomically consumes the staged import after a successful preview.
  final VoidCallback? onImport;

  /// Removes the current local and staged preview.
  final VoidCallback? onRemove;

  /// Server-owned product counts and transaction identifier.
  final AdminProductImportPreview? preview;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 16,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
          height: double.infinity,
          child: Column(children: [
            _AdminProductImportHeader(onClose: onClose),
            Expanded(
              child: _AdminProductImportBody(
                busy: busy,
                failure: failure,
                file: file,
                onDownloadTemplate: onDownloadTemplate,
                onPick: onPick,
                onRemove: onRemove,
                preview: preview,
              ),
            ),
            _AdminProductImportFooter(
              busy: busy,
              onClose: onClose,
              onImport: onImport,
            ),
          ]),
        ),
      );
}

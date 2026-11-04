import 'package:admin_app/src/product/admin_product_export_file.dart';
import 'package:admin_app/src/product/admin_product_export_filters.dart';
import 'package:admin_app/src/product/admin_product_state.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_product_export_drawer_chrome.dart';

/// Opens Medusa's right-side product export flow.
Future<bool?> showAdminProductExportDrawer(
  BuildContext context,
  AdminProductState state,
) =>
    showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close product export',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: _ProductExportDrawer(state: state),
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

final class _ProductExportDrawer extends StatefulWidget {
  const _ProductExportDrawer({required this.state});

  final AdminProductState state;

  @override
  State<_ProductExportDrawer> createState() => _ProductExportDrawerState();
}

final class _ProductExportDrawerState extends State<_ProductExportDrawer> {
  bool _busy = false;
  String? _failure;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 16,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
          height: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AdminProductExportHeader(
                busy: _busy,
                onClose: () => Navigator.pop(context, false),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    AdminProductExportFilters(state: widget.state),
                    if (_failure case final message?) ...[
                      const SizedBox(height: 16),
                      Text(message,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          )),
                    ],
                  ],
                ),
              ),
              _AdminProductExportFooter(
                busy: _busy,
                onCancel: () => Navigator.pop(context, false),
                onExport: _export,
              ),
            ],
          ),
        ),
      );

  Future<void> _export() async {
    setState(() {
      _busy = true;
      _failure = null;
    });
    final result = await context.readAdminProductViewModel().export();
    if (!mounted) return;
    if (result case Err(:final error)) {
      setState(() {
        _busy = false;
        _failure = error;
      });
      return;
    }
    try {
      final saved = await saveAdminProductExport(
        (result as Ok<String, String>).value,
      );
      if (!mounted) return;
      if (saved) Navigator.pop(context, true);
      if (!saved) setState(() => _busy = false);
    } on Object {
      if (mounted) {
        setState(() {
          _busy = false;
          _failure = 'Unable to save the export file. Try again.';
        });
      }
    }
  }
}

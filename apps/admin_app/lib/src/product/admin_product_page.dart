import 'package:admin_app/src/product/admin_product_delete.dart';
import 'package:admin_app/src/product/admin_product_export_drawer.dart';
import 'package:admin_app/src/product/admin_product_import_drawer.dart';
import 'package:admin_app/src/product/admin_product_page_body.dart';
import 'package:admin_app/src/product/admin_product_page_header.dart';
import 'package:admin_app/src/product/admin_product_pagination.dart';
import 'package:admin_app/src/product/admin_product_state.dart';
import 'package:admin_app/src/product/admin_product_toolbar.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped product route backed by the authenticated admin API.
final class AdminProductPage extends StatefulWidget {
  /// Creates the product route.
  const AdminProductPage({
    required this.searchFocus,
    required this.onOpenProduct,
    required this.onCreateProduct,
    super.key,
  });

  /// Opens the authenticated product creation focus surface.
  final VoidCallback onCreateProduct;

  /// Focus target shared with the sidebar search action.
  final FocusNode searchFocus;

  /// Opens one product detail from the result table.
  final ValueChanged<String> onOpenProduct;

  @override
  State<AdminProductPage> createState() => _AdminProductPageState();
}

final class _AdminProductPageState extends State<AdminProductPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductViewModel().value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            shadowColor: const Color(0x16000000),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminProductPageHeader(
                  onExport: () => _export(state),
                  onImport: _import,
                  onCreate: widget.onCreateProduct,
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                AdminProductToolbar(
                  controller: _query,
                  focusNode: widget.searchFocus,
                  state: state,
                  onSearch: () =>
                      context.readAdminProductViewModel().search(_query.text),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                AdminProductPageBody(
                  onDelete: (product) =>
                      deleteAdminProductSummary(context, product),
                  onOpen: widget.onOpenProduct,
                  onRetry: context.readAdminProductViewModel().load,
                  state: state,
                ),
                AdminProductPagination(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _export(AdminProductState state) async {
    final exported = await showAdminProductExportDrawer(context, state);
    if (!mounted || exported != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product export downloaded.')),
    );
  }

  Future<void> _import() async {
    final imported = await showAdminProductImportDrawer(context);
    if (!mounted || imported != true) return;
    await context.readAdminProductViewModel().load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product import completed.')),
    );
  }
}

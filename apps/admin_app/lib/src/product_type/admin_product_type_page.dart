import 'package:admin_app/src/product_type/admin_product_type_create_page.dart';
import 'package:admin_app/src/product_type/admin_product_type_delete.dart';
import 'package:admin_app/src/product_type/admin_product_type_edit_drawer.dart';
import 'package:admin_app/src/product_type/admin_product_type_page_header.dart';
import 'package:admin_app/src/product_type/admin_product_type_pagination.dart';
import 'package:admin_app/src/product_type/admin_product_type_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_table.dart';
import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa's product-types settings route backed by the authenticated API.
final class AdminProductTypePage extends StatefulWidget {
  /// Creates the product-types route.
  const AdminProductTypePage({
    required this.searchFocus,
    required this.onOpen,
    super.key,
  });

  /// Opens one complete product-type detail route.
  final ValueChanged<String> onOpen;

  /// Focus target shared with the sidebar search action.
  final FocusNode searchFocus;

  @override
  State<AdminProductTypePage> createState() => _AdminProductTypePageState();
}

final class _AdminProductTypePageState extends State<AdminProductTypePage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductTypeViewModel().value;
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
                AdminProductTypePageHeader(
                  controller: _query,
                  focusNode: widget.searchFocus,
                  onCreate: () => _create(context),
                  onSearch: () => context
                      .readAdminProductTypeViewModel()
                      .search(_query.text),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _body(context, state),
                AdminProductTypePagination(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AdminProductTypeState state) {
    if (state.status == AdminProductTypeStatus.loading &&
        state.productTypes.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.failure case Some(value: final message)) {
      return SizedBox(
        height: 120,
        child: Center(
          child: OutlinedButton(
            onPressed: context.readAdminProductTypeViewModel().load,
            child: Text('$message Retry'),
          ),
        ),
      );
    }
    if (state.productTypes.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No records')),
      );
    }
    return Stack(
      children: [
        AdminProductTypeTable(
          productTypes: state.productTypes,
          onOpen: widget.onOpen,
          onEdit: (productType) => _edit(context, productType),
          onDelete: (productType) => _delete(context, productType),
        ),
        if (state.status == AdminProductTypeStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }

  Future<void> _create(BuildContext context) async {
    final created = await showAdminProductTypeCreatePage(context);
    if (!context.mounted || created == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product type "${created.value}" created.')),
    );
  }

  Future<void> _edit(
    BuildContext context,
    AdminProductType productType,
  ) async {
    final updated = await showAdminProductTypeEditDrawer(context, productType);
    if (!context.mounted || updated == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product type "${updated.value}" updated.')),
    );
  }

  Future<void> _delete(
    BuildContext context,
    AdminProductType productType,
  ) async {
    if (!await confirmAdminProductTypeDelete(context, productType.value) ||
        !context.mounted) {
      return;
    }
    final outcome =
        await context.readAdminProductTypeViewModel().delete(productType.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(adminProductTypeDeleteMessage(outcome, productType.value)),
    ));
  }
}

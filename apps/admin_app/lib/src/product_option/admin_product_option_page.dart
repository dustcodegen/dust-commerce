import 'package:admin_app/src/product_option/admin_product_option_pagination.dart';
import 'package:admin_app/src/product_option/admin_product_option_delete.dart';
import 'package:admin_app/src/product_option/admin_product_option_page_header.dart';
import 'package:admin_app/src/product_option/admin_product_option_state.dart';
import 'package:admin_app/src/product_option/admin_product_option_table.dart';
import 'package:admin_app/src/product_option/admin_product_option_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa's global product-options route backed by the authenticated API.
final class AdminProductOptionPage extends StatefulWidget {
  /// Creates the product-options route.
  const AdminProductOptionPage({
    required this.searchFocus,
    required this.onOpen,
    required this.onCreate,
    super.key,
  });

  /// Opens the create-product-option focus surface.
  final VoidCallback onCreate;

  /// Opens one product-option detail.
  final ValueChanged<String> onOpen;

  /// Focus target shared with the sidebar search action.
  final FocusNode searchFocus;

  @override
  State<AdminProductOptionPage> createState() => _AdminProductOptionPageState();
}

final class _AdminProductOptionPageState extends State<AdminProductOptionPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductOptionViewModel().value;
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
                AdminProductOptionPageHeader(
                  controller: _query,
                  focusNode: widget.searchFocus,
                  onCreate: widget.onCreate,
                  onSearch: () => context
                      .readAdminProductOptionViewModel()
                      .search(_query.text),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                const AdminProductOptionToolbar(),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                _body(context, state),
                AdminProductOptionPagination(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AdminProductOptionState state) {
    if (state.status == AdminProductOptionStatus.loading &&
        state.productOptions.isEmpty) {
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
            onPressed: context.readAdminProductOptionViewModel().load,
            child: Text('$message Retry'),
          ),
        ),
      );
    }
    if (state.productOptions.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No records')),
      );
    }
    return Stack(
      children: [
        AdminProductOptionTable(
          productOptions: state.productOptions,
          onOpen: widget.onOpen,
          onDelete: (option) => _delete(context, option),
        ),
        if (state.status == AdminProductOptionStatus.loading)
          const LinearProgressIndicator(minHeight: 2),
      ],
    );
  }

  Future<void> _delete(
    BuildContext context,
    AdminProductOptionSummary option,
  ) async {
    if (!await confirmAdminProductOptionDelete(context, option.title) ||
        !context.mounted) {
      return;
    }
    final outcome =
        await context.readAdminProductOptionViewModel().delete(option.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(adminProductOptionDeleteMessage(
        outcome,
        option.title,
      ))),
    );
  }
}

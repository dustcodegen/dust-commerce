import 'package:admin_app/src/inventory/admin_stock_location_page_header.dart';
import 'package:admin_app/src/inventory/admin_stock_location_pagination.dart';
import 'package:admin_app/src/inventory/admin_stock_location_table.dart';
import 'package:admin_app/src/inventory/admin_stock_location_view_model.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped Inventory/Locations list backed by the protected API.
final class AdminStockLocationPage extends StatefulWidget {
  /// Creates the location list route.
  const AdminStockLocationPage({required this.searchFocus, super.key});

  /// Focus target shared with the shell search action.
  final FocusNode searchFocus;

  @override
  State<AdminStockLocationPage> createState() => _AdminStockLocationPageState();
}

final class _AdminStockLocationPageState extends State<AdminStockLocationPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminStockLocationViewModel().value;
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
                AdminStockLocationPageHeader(
                  controller: _query,
                  focusNode: widget.searchFocus,
                  onSearch: () => context
                      .readAdminStockLocationViewModel()
                      .search(_query.text),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                AdminStockLocationTableBody(state: state),
                AdminStockLocationPagination(state: state),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:admin_app/src/product/admin_product_filter_bar.dart';
import 'package:admin_app/src/product/admin_product_state.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa's product-table filter, sort, and search toolbar.
final class AdminProductToolbar extends StatelessWidget {
  /// Creates controls backed by the current server query state.
  const AdminProductToolbar({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.state,
    super.key,
  });

  /// Product-search input owned by the route.
  final TextEditingController controller;

  /// Search target shared with the Admin shell.
  final FocusNode focusNode;

  /// Submits the normalized product query.
  final VoidCallback onSearch;

  /// Current filter and ordering state.
  final AdminProductState state;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final queryControls = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: constraints.maxWidth < 560 ? 228 : 196,
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onSubmitted: (_) => onSearch(),
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search_rounded, size: 17),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _SortMenu(order: state.order),
              ],
            );
            final filters = AdminProductFilterBar(state: state);
            if (constraints.maxWidth < 560) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  queryControls,
                  const SizedBox(height: 8),
                  filters,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: filters),
                const SizedBox(width: 12),
                queryControls,
              ],
            );
          },
        ),
      );
}

final class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.order});

  final AdminProductOrder order;

  @override
  Widget build(BuildContext context) => PopupMenuButton<AdminProductOrder>(
        tooltip: 'Sort products',
        initialValue: order,
        onSelected: context.readAdminProductViewModel().orderBy,
        icon: const Icon(Icons.sort_rounded, size: 18),
        itemBuilder: (context) => [
          for (final value in AdminProductOrder.values)
            PopupMenuItem(
              value: value,
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: value == order
                        ? const Icon(Icons.check_rounded, size: 17)
                        : null,
                  ),
                  Text(_orderLabel(value)),
                ],
              ),
            ),
        ],
      );

  String _orderLabel(AdminProductOrder value) => switch (value) {
        AdminProductOrder.titleAsc => 'Title: A to Z',
        AdminProductOrder.titleDesc => 'Title: Z to A',
        AdminProductOrder.createdAtAsc => 'Created: oldest first',
        AdminProductOrder.createdAtDesc => 'Created: newest first',
        AdminProductOrder.updatedAtAsc => 'Updated: oldest first',
        AdminProductOrder.updatedAtDesc => 'Updated: newest first',
      };
}

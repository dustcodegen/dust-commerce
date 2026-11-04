import 'package:admin_app/src/order/admin_order_state.dart';
import 'package:admin_app/src/order/admin_order_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_order_sort_menu.dart';
part 'admin_order_filter_controls.dart';
part 'admin_order_region_filter.dart';
part 'admin_order_sales_channel_filter.dart';

/// Search, filters, and ordering backed by the Admin order query.
final class AdminOrderToolbar extends StatelessWidget {
  /// Creates functional order-table controls.
  const AdminOrderToolbar({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
    required this.state,
    super.key,
  });

  /// Current order search input.
  final TextEditingController controller;

  /// Search target shared with the Admin shell.
  final FocusNode focusNode;

  /// Submits the current search text.
  final VoidCallback onSearch;

  /// Active query state.
  final AdminOrderState state;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final filters = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _AddFilter(state: state),
                if (state.statuses.isNotEmpty)
                  _ActiveFilterChip(
                    label: Text('Status: ${_statuses(state.statuses)}'),
                    onRemove: () => context
                        .readAdminOrderViewModel()
                        .filterByStatuses(const []),
                  ),
                if (state.regionIds.isNotEmpty)
                  _RegionFilterChip(
                    regions: state.regions,
                    selected: state.regionIds,
                    onChanged:
                        context.readAdminOrderViewModel().filterByRegions,
                  ),
                if (state.salesChannelIds.isNotEmpty)
                  _SalesChannelFilterChip(
                    salesChannels: state.salesChannels,
                    selected: state.salesChannelIds,
                    onChanged:
                        context.readAdminOrderViewModel().filterBySalesChannels,
                  ),
                if (!state.createdAt.isEmpty)
                  _ActiveFilterChip(
                    label: const Text('Created: last 30 days'),
                    onRemove: () => _clearCreated(context),
                  ),
                if (!state.updatedAt.isEmpty)
                  _ActiveFilterChip(
                    label: const Text('Updated: last 30 days'),
                    onRemove: () => _clearUpdated(context),
                  ),
                if (state.hasFilters)
                  TextButton(
                    onPressed: context.readAdminOrderViewModel().clearFilters,
                    child: const Text('Clear all'),
                  ),
                if (state.filterOptionsStatus ==
                    AdminOrderFilterOptionsStatus.loading)
                  const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                if (state.filterOptionsStatus ==
                    AdminOrderFilterOptionsStatus.failed)
                  IconButton(
                    tooltip: state.filterOptionsFailure.match(
                      some: (message) => '$message Retry',
                      none: () => 'Retry filter choices',
                    ),
                    onPressed:
                        context.readAdminOrderViewModel().loadFilterOptions,
                    icon: const Icon(Icons.refresh_rounded, size: 17),
                  ),
              ],
            );
            final query = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: constraints.maxWidth < 620 ? 228 : 196,
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
            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [query, const SizedBox(height: 8), filters],
              );
            }
            return Row(
              children: [
                Expanded(child: filters),
                const SizedBox(width: 12),
                query,
              ],
            );
          },
        ),
      );

  void _clearCreated(BuildContext context) =>
      context.readAdminOrderViewModel().filterByCreatedAt(
            from: const None(),
            to: const None(),
          );

  void _clearUpdated(BuildContext context) =>
      context.readAdminOrderViewModel().filterByUpdatedAt(
            from: const None(),
            to: const None(),
          );

  String _statuses(List<AdminOrderStatus> values) => values
      .map(
          (value) => '${value.name[0].toUpperCase()}${value.name.substring(1)}')
      .join(', ');
}

import 'package:admin_app/src/customer_service/admin_customer_service_state.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_status_control.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Search, lifecycle filters, and ordering for the support inbox.
final class AdminCustomerServiceToolbar extends StatelessWidget {
  /// Creates functional inbox controls.
  const AdminCustomerServiceToolbar({
    required this.controller,
    required this.focusNode,
    required this.state,
    super.key,
  });

  /// Current merchant search input.
  final TextEditingController controller;

  /// Search target shared with the Admin shell.
  final FocusNode focusNode;

  /// Active query state.
  final AdminCustomerServiceState state;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onSubmitted:
                        context.readAdminCustomerServiceViewModel().search,
                    decoration: const InputDecoration(
                      hintText: 'Search requests',
                      prefixIcon: Icon(Icons.search_rounded, size: 17),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<AdminCustomerServiceOrder>(
                  tooltip: 'Sort requests',
                  onSelected: context.readAdminCustomerServiceViewModel().sort,
                  itemBuilder: (context) => [
                    for (final order in AdminCustomerServiceOrder.values)
                      PopupMenuItem(
                        value: order,
                        child: Text(_orderLabel(order)),
                      ),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.swap_vert_rounded, size: 17),
                    label: Text(_orderLabel(state.order)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final status in AdminCustomerServiceStatus.values)
                  FilterChip(
                    label: Text(adminCustomerServiceStatusLabel(status)),
                    selected: state.statuses.contains(status),
                    onSelected: (_) => _toggle(context, status),
                  ),
                if (state.hasFilters)
                  TextButton(
                    onPressed: context
                        .readAdminCustomerServiceViewModel()
                        .clearFilters,
                    child: const Text('Clear all'),
                  ),
              ],
            ),
          ],
        ),
      );

  void _toggle(BuildContext context, AdminCustomerServiceStatus status) {
    final statuses = [...state.statuses];
    statuses.contains(status) ? statuses.remove(status) : statuses.add(status);
    context.readAdminCustomerServiceViewModel().filter(statuses);
  }
}

String _orderLabel(AdminCustomerServiceOrder order) => switch (order) {
      AdminCustomerServiceOrder.createdAtAsc => 'Oldest first',
      AdminCustomerServiceOrder.createdAtDesc => 'Newest first',
      AdminCustomerServiceOrder.updatedAtAsc => 'Least recently updated',
      AdminCustomerServiceOrder.updatedAtDesc => 'Recently updated',
    };

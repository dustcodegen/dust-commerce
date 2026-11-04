import 'package:admin_app/src/customer_group/admin_customer_group_active_filters.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_filter_menu.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_sort.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Search, date-filter, and ordering controls for the group table.
final class AdminCustomerGroupToolbar extends StatefulWidget {
  /// Creates Medusa's customer-group query controls.
  const AdminCustomerGroupToolbar({
    required this.state,
    required this.searchFocus,
    super.key,
  });

  /// Sidebar search focus target.
  final FocusNode searchFocus;

  /// Current server query state.
  final AdminCustomerGroupState state;

  @override
  State<AdminCustomerGroupToolbar> createState() =>
      _AdminCustomerGroupToolbarState();
}

final class _AdminCustomerGroupToolbarState
    extends State<AdminCustomerGroupToolbar> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.state.query);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.readAdminCustomerGroupViewModel();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) => _AdminCustomerGroupQueryRow(
            compact: constraints.maxWidth < 620,
            filter: AdminCustomerGroupFilterMenu(
              createdAt: widget.state.createdAt,
              updatedAt: widget.state.updatedAt,
              onCreatedAtChanged: _createdAtChanged,
              onUpdatedAtChanged: _updatedAtChanged,
            ),
            query: _AdminCustomerGroupSearch(
              controller: _search,
              focusNode: widget.searchFocus,
              onSubmitted: viewModel.search,
            ),
            sort: AdminCustomerGroupSort(
              value: widget.state.order,
              onChanged: viewModel.orderBy,
            ),
          ),
        ),
      ),
      AdminCustomerGroupActiveFilters(
        state: widget.state,
        onCreatedAtChanged: _createdAtChanged,
        onUpdatedAtChanged: _updatedAtChanged,
        onClearAll: viewModel.clearFilters,
      ),
    ]);
  }

  Future<void> _createdAtChanged(AdminDateFilter value) =>
      context.readAdminCustomerGroupViewModel().filterByCreatedAt(
            from: value.greaterThanOrEqual,
            to: value.lessThanOrEqual,
          );

  Future<void> _updatedAtChanged(AdminDateFilter value) =>
      context.readAdminCustomerGroupViewModel().filterByUpdatedAt(
            from: value.greaterThanOrEqual,
            to: value.lessThanOrEqual,
          );
}

final class _AdminCustomerGroupQueryRow extends StatelessWidget {
  const _AdminCustomerGroupQueryRow({
    required this.compact,
    required this.filter,
    required this.query,
    required this.sort,
  });

  final bool compact;
  final Widget filter;
  final Widget query;
  final Widget sort;

  @override
  Widget build(BuildContext context) => compact
      ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: query), sort]),
          const SizedBox(height: 8),
          filter,
        ])
      : Row(children: [filter, const Spacer(), query, sort]);
}

final class _AdminCustomerGroupSearch extends StatelessWidget {
  const _AdminCustomerGroupSearch({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 220,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onSubmitted: onSubmitted,
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search_rounded, size: 17),
          ),
        ),
      );
}

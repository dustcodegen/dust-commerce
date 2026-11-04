import 'package:admin_app/src/customer/admin_customer_active_filters.dart';
import 'package:admin_app/src/customer/admin_customer_filter_menu.dart';
import 'package:admin_app/src/customer/admin_customer_sort.dart';
import 'package:admin_app/src/customer/admin_customer_state.dart';
import 'package:admin_app/src/customer/admin_customer_view_model.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Search, filter, and ordering controls for the customer table.
final class AdminCustomerToolbar extends StatefulWidget {
  /// Creates Medusa's customer query controls.
  const AdminCustomerToolbar({
    required this.state,
    required this.searchFocus,
    super.key,
  });

  /// Sidebar search focus target.
  final FocusNode searchFocus;

  /// Current server query state.
  final AdminCustomerState state;

  @override
  State<AdminCustomerToolbar> createState() => _AdminCustomerToolbarState();
}

final class _AdminCustomerToolbarState extends State<AdminCustomerToolbar> {
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
    final viewModel = context.readAdminCustomerViewModel();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: LayoutBuilder(
          builder: (context, constraints) => _AdminCustomerQueryRow(
            compact: constraints.maxWidth < 620,
            filter: AdminCustomerFilterMenu(onSelected: _editFilter),
            query: _AdminCustomerSearch(
              controller: _search,
              focusNode: widget.searchFocus,
              onSubmitted: viewModel.search,
            ),
            sort: AdminCustomerSort(
              value: widget.state.order,
              onChanged: viewModel.orderBy,
            ),
          ),
        ),
      ),
      AdminCustomerActiveFilters(
        state: widget.state,
        onClearAccount: () => viewModel.filterByAccount(const None()),
        onClearCreatedAt: () => viewModel.filterByCreatedAt(),
        onClearUpdatedAt: () => viewModel.filterByUpdatedAt(),
        onClearAll: viewModel.clearFilters,
      ),
    ]);
  }

  Future<void> _editFilter(AdminCustomerFilterKind kind) async {
    final viewModel = context.readAdminCustomerViewModel();
    switch (kind) {
      case AdminCustomerFilterKind.account:
        final account = await showAdminCustomerAccountFilter(context);
        if (account != null && mounted) {
          await viewModel.filterByAccount(account);
        }
      case AdminCustomerFilterKind.createdAt:
        await _pickDate(created: true);
      case AdminCustomerFilterKind.updatedAt:
        await _pickDate(created: false);
    }
  }

  Future<void> _pickDate({required bool created}) async {
    final today = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year + 1, 12, 31),
    );
    if (range == null || !mounted) return;
    final from = Some(range.start);
    final to = Some(DateTime(
      range.end.year,
      range.end.month,
      range.end.day,
      23,
      59,
      59,
      999,
      999,
    ));
    final viewModel = context.readAdminCustomerViewModel();
    if (created) {
      await viewModel.filterByCreatedAt(from: from, to: to);
    } else {
      await viewModel.filterByUpdatedAt(from: from, to: to);
    }
  }
}

final class _AdminCustomerQueryRow extends StatelessWidget {
  const _AdminCustomerQueryRow({
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

final class _AdminCustomerSearch extends StatelessWidget {
  const _AdminCustomerSearch({
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

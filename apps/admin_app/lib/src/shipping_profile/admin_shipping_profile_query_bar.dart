import 'package:admin_app/src/shipping_profile/admin_shipping_profile_active_filters.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_filter_menu.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_sort.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_state.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_text_filter_dialog.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_view_model.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Search, filter, and server-order controls for the profile table.
final class AdminShippingProfileQueryBar extends StatefulWidget {
  /// Creates Medusa's profile-table query controls.
  const AdminShippingProfileQueryBar({
    required this.state,
    required this.searchFocus,
    super.key,
  });

  /// Sidebar search focus target.
  final FocusNode searchFocus;

  /// Current server query state.
  final AdminShippingProfileState state;

  @override
  State<AdminShippingProfileQueryBar> createState() =>
      _AdminShippingProfileQueryBarState();
}

final class _AdminShippingProfileQueryBarState
    extends State<AdminShippingProfileQueryBar> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.state.query);
  }

  @override
  void didUpdateWidget(AdminShippingProfileQueryBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.query != _search.text && !_search.selection.isValid) {
      _search.text = widget.state.query;
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.readAdminShippingProfileViewModel();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(children: [
          AdminShippingProfileFilterMenu(onSelected: _editFilter),
          const Spacer(),
          SizedBox(
            width: 220,
            child: TextField(
              controller: _search,
              focusNode: widget.searchFocus,
              onSubmitted: viewModel.search,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search_rounded, size: 17),
              ),
            ),
          ),
          const SizedBox(width: 4),
          AdminShippingProfileSort(
            value: widget.state.order,
            onChanged: viewModel.orderBy,
          ),
        ]),
      ),
      AdminShippingProfileActiveFilters(
        state: widget.state,
        onClearName: () => viewModel.filterByName(''),
        onClearType: () => viewModel.filterByType(''),
        onClearCreatedAt: () => viewModel.filterByCreatedAt(
          from: const None(),
          to: const None(),
        ),
        onClearUpdatedAt: () => viewModel.filterByUpdatedAt(
          from: const None(),
          to: const None(),
        ),
        onClearAll: viewModel.clearFilters,
      ),
    ]);
  }

  Future<void> _editFilter(AdminShippingProfileFilterKind kind) async {
    final viewModel = context.readAdminShippingProfileViewModel();
    switch (kind) {
      case AdminShippingProfileFilterKind.name:
        final value = await showAdminShippingProfileTextFilterDialog(
          context,
          label: 'Name',
          initialValue: widget.state.name,
        );
        if (value != null && mounted) await viewModel.filterByName(value);
        return;
      case AdminShippingProfileFilterKind.type:
        final value = await showAdminShippingProfileTextFilterDialog(
          context,
          label: 'Type',
          initialValue: widget.state.type,
        );
        if (value != null && mounted) await viewModel.filterByType(value);
        return;
      case AdminShippingProfileFilterKind.createdAt:
        await _pickDate(created: true);
        return;
      case AdminShippingProfileFilterKind.updatedAt:
        await _pickDate(created: false);
        return;
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
    final viewModel = context.readAdminShippingProfileViewModel();
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
    if (created) {
      await viewModel.filterByCreatedAt(from: from, to: to);
    } else {
      await viewModel.filterByUpdatedAt(from: from, to: to);
    }
  }
}

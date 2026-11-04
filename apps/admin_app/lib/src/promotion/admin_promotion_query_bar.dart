import 'package:admin_app/src/promotion/admin_promotion_active_filters.dart';
import 'package:admin_app/src/promotion/admin_promotion_filter_menu.dart';
import 'package:admin_app/src/promotion/admin_promotion_sort.dart';
import 'package:admin_app/src/promotion/admin_promotion_state.dart';
import 'package:admin_app/src/promotion/admin_promotion_view_model.dart';
import 'package:flutter/material.dart';

/// Search, filter, and server-order controls for promotions.
final class AdminPromotionQueryBar extends StatefulWidget {
  /// Creates Medusa's promotion-table query controls.
  const AdminPromotionQueryBar({
    required this.state,
    required this.searchFocus,
    super.key,
  });

  /// Sidebar search focus target.
  final FocusNode searchFocus;

  /// Current server query state.
  final AdminPromotionState state;

  @override
  State<AdminPromotionQueryBar> createState() => _AdminPromotionQueryBarState();
}

final class _AdminPromotionQueryBarState extends State<AdminPromotionQueryBar> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.state.query);
  }

  @override
  void didUpdateWidget(AdminPromotionQueryBar oldWidget) {
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
    final viewModel = context.readAdminPromotionViewModel();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(children: [
          AdminPromotionFilterMenu(
            createdAt: widget.state.createdAt,
            updatedAt: widget.state.updatedAt,
            onCreatedAtChanged: viewModel.filterByCreatedAt,
            onUpdatedAtChanged: viewModel.filterByUpdatedAt,
          ),
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
          AdminPromotionSort(
            value: widget.state.order,
            onChanged: viewModel.orderBy,
          ),
        ]),
      ),
      AdminPromotionActiveFilters(
        state: widget.state,
        onCreatedAtChanged: viewModel.filterByCreatedAt,
        onUpdatedAtChanged: viewModel.filterByUpdatedAt,
        onClearAll: viewModel.clearFilters,
      ),
    ]);
  }
}

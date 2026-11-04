import 'package:admin_app/src/promotion/admin_promotion_state.dart';
import 'package:admin_app/src/promotion/admin_promotion_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned promotion paging controls.
final class AdminPromotionPagination extends StatelessWidget {
  /// Creates paging controls for [state].
  const AdminPromotionPagination({required this.state, super.key});

  /// Current list bounds and total.
  final AdminPromotionState state;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
          Text(_range),
          const Spacer(),
          Text('$_currentPage of $_pageCount pages'),
          const SizedBox(width: 18),
          TextButton(
            onPressed: state.hasPrevious
                ? context.readAdminPromotionViewModel().previous
                : null,
            child: const Text('Prev'),
          ),
          TextButton(
            onPressed: state.hasNext
                ? context.readAdminPromotionViewModel().next
                : null,
            child: const Text('Next'),
          ),
        ]),
      );

  int get _currentPage =>
      state.count == 0 ? 1 : state.offset ~/ state.limit + 1;

  int get _pageCount =>
      state.count == 0 ? 1 : (state.count / state.limit).ceil();

  String get _range => state.count == 0
      ? '0 of 0 results'
      : '${state.offset + 1} — '
          '${state.offset + state.promotions.length} of '
          '${state.count} results';
}

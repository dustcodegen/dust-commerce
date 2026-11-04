import 'package:admin_app/src/product_type/admin_product_type_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned product-type paging controls.
final class AdminProductTypePagination extends StatelessWidget {
  /// Creates product-type paging for [state].
  const AdminProductTypePagination({required this.state, super.key});

  /// Current list bounds and total.
  final AdminProductTypeState state;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Text(_range),
            const Spacer(),
            Text('$_currentPage of $_pageCount pages'),
            const SizedBox(width: 18),
            TextButton(
              onPressed: state.hasPrevious
                  ? context.readAdminProductTypeViewModel().previous
                  : null,
              child: const Text('Prev'),
            ),
            TextButton(
              onPressed: state.hasNext
                  ? context.readAdminProductTypeViewModel().next
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      );

  String get _range => state.count == 0
      ? '0 of 0 results'
      : '${state.offset + 1} — '
          '${state.offset + state.productTypes.length} of ${state.count} results';

  int get _currentPage =>
      state.count == 0 ? 1 : state.offset ~/ state.limit + 1;

  int get _pageCount =>
      state.count == 0 ? 1 : (state.count / state.limit).ceil();
}

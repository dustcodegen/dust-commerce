import 'package:admin_app/src/product_option/admin_product_option_state.dart';
import 'package:admin_app/src/product_option/admin_product_option_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned product-option paging controls.
final class AdminProductOptionPagination extends StatelessWidget {
  /// Creates option paging for [state].
  const AdminProductOptionPagination({required this.state, super.key});

  /// Current list bounds and total.
  final AdminProductOptionState state;

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
                  ? context.readAdminProductOptionViewModel().previous
                  : null,
              child: const Text('Prev'),
            ),
            TextButton(
              onPressed: state.hasNext
                  ? context.readAdminProductOptionViewModel().next
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      );

  String get _range => state.count == 0
      ? '0 of 0 results'
      : '${state.offset + 1} — '
          '${state.offset + state.productOptions.length} of ${state.count} results';

  int get _currentPage =>
      state.count == 0 ? 1 : state.offset ~/ state.limit + 1;

  int get _pageCount =>
      state.count == 0 ? 1 : (state.count / state.limit).ceil();
}

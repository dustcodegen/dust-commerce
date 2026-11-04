import 'package:admin_app/src/product/admin_product_state.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned product paging controls.
final class AdminProductPagination extends StatelessWidget {
  /// Creates catalogue paging for [state].
  const AdminProductPagination({required this.state, super.key});

  /// Current list bounds and total.
  final AdminProductState state;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            Text(
              '${state.count == 0 ? 0 : state.offset + 1} — '
              '${state.offset + state.products.length} '
              'of ${state.count} results',
            ),
            const Spacer(),
            Text('${state.offset ~/ state.limit + 1} of '
                '${(state.count / state.limit).ceil().clamp(1, 1 << 31)} pages'),
            const SizedBox(width: 20),
            TextButton(
              onPressed: state.hasPrevious
                  ? context.readAdminProductViewModel().previous
                  : null,
              child: const Text('Prev'),
            ),
            TextButton(
              onPressed: state.hasNext
                  ? context.readAdminProductViewModel().next
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      );
}

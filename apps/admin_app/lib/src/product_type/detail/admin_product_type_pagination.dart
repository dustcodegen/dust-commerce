import 'package:admin_app/src/product_type/admin_product_type_detail_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned pagination for one type's linked products.
final class AdminProductTypePagination extends StatelessWidget {
  /// Creates linked-product paging controls.
  const AdminProductTypePagination({required this.state, super.key});

  /// Current list bounds and total.
  final AdminProductTypeDetailState state;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(children: [
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
                ? context.readAdminProductTypeDetailViewModel().previous
                : null,
            child: const Text('Prev'),
          ),
          TextButton(
            onPressed: state.hasNext
                ? context.readAdminProductTypeDetailViewModel().next
                : null,
            child: const Text('Next'),
          ),
        ]),
      );
}

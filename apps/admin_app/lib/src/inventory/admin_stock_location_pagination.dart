import 'package:admin_app/src/inventory/admin_stock_location_state.dart';
import 'package:admin_app/src/inventory/admin_stock_location_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned location paging controls.
final class AdminStockLocationPagination extends StatelessWidget {
  /// Creates location paging.
  const AdminStockLocationPagination({required this.state, super.key});

  /// Current list bounds.
  final AdminStockLocationState state;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Text(_range),
            const Spacer(),
            TextButton(
              onPressed: state.hasPrevious
                  ? context.readAdminStockLocationViewModel().previous
                  : null,
              child: const Text('Prev'),
            ),
            TextButton(
              onPressed: state.hasNext
                  ? context.readAdminStockLocationViewModel().next
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      );

  String get _range => state.count == 0
      ? '0 of 0 results'
      : '${state.offset + 1} — '
          '${state.offset + state.stockLocations.length} of ${state.count} results';
}

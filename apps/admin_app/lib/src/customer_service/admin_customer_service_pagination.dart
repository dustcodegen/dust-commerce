import 'package:admin_app/src/customer_service/admin_customer_service_state.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_view_model.dart';
import 'package:flutter/material.dart';

/// Server-owned support-inbox paging controls.
final class AdminCustomerServicePagination extends StatelessWidget {
  /// Creates paging controls for [state].
  const AdminCustomerServicePagination({required this.state, super.key});

  /// Current list bounds and total.
  final AdminCustomerServiceState state;

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
            Text(state.count == 0
                ? '0 of 0 results'
                : '${state.offset + 1} — '
                    '${state.offset + state.requests.length} of '
                    '${state.count} results'),
            const Spacer(),
            Text('${state.offset ~/ state.limit + 1} of '
                '${(state.count / state.limit).ceil().clamp(1, 1 << 31)} pages'),
            const SizedBox(width: 18),
            TextButton(
              onPressed: state.hasPrevious
                  ? context.readAdminCustomerServiceViewModel().previous
                  : null,
              child: const Text('Prev'),
            ),
            TextButton(
              onPressed: state.hasNext
                  ? context.readAdminCustomerServiceViewModel().next
                  : null,
              child: const Text('Next'),
            ),
          ],
        ),
      );
}

import 'package:admin_app/src/customer_service/admin_customer_service_state.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_table.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Loading, failure, empty, and populated support-inbox body states.
final class AdminCustomerServiceBody extends StatelessWidget {
  /// Creates the body for [state].
  const AdminCustomerServiceBody({
    required this.state,
    required this.onRetry,
    required this.onOpen,
    super.key,
  });

  /// Opens one complete request.
  final ValueChanged<AdminCustomerServiceRequest> onOpen;

  /// Retries the active list query.
  final VoidCallback onRetry;

  /// Current inbox state.
  final AdminCustomerServiceState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == AdminCustomerServiceListStatus.loading &&
        state.requests.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (state.failure case Some(value: final message)
        when state.requests.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: Text('$message Retry'),
          ),
        ),
      );
    }
    if (state.requests.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No customer-service requests found')),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (state.failure case Some(value: final message))
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            color: Theme.of(context).colorScheme.errorContainer,
            child: Text(message),
          ),
        Stack(
          children: [
            AdminCustomerServiceTable(
              requests: state.requests,
              onOpen: onOpen,
            ),
            if (state.status == AdminCustomerServiceListStatus.loading)
              const LinearProgressIndicator(minHeight: 2),
          ],
        ),
      ],
    );
  }
}

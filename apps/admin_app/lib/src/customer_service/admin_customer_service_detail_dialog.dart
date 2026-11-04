import 'package:admin_app/src/customer_service/admin_customer_service_detail_field.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_status_control.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Full merchant detail for one customer-authored support request.
final class AdminCustomerServiceDetailDialog extends StatelessWidget {
  /// Creates the detail surface for [request].
  const AdminCustomerServiceDetailDialog({required this.request, super.key});

  /// Explicit Admin response selected from the inbox.
  final AdminCustomerServiceRequest request;

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerServiceViewModel().value;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 12, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Customer service request',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: Navigator.of(context).pop,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      request.subject,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 24,
                      runSpacing: 20,
                      children: [
                        AdminCustomerServiceDetailField(
                          label: 'Request ID',
                          value: request.id,
                        ),
                        AdminCustomerServiceDetailField(
                          label: 'Customer',
                          value: '${request.name}\n${request.email}',
                        ),
                        AdminCustomerServiceDetailField(
                          label: 'Account ID',
                          value: request.customerId.match(
                            some: (value) => value,
                            none: () => 'Guest',
                          ),
                        ),
                        AdminCustomerServiceDetailField(
                          label: 'Order reference',
                          value: request.orderReference.match(
                            some: (value) => value,
                            none: () => 'Not provided',
                          ),
                        ),
                        AdminCustomerServiceDetailField(
                          label: 'Received',
                          value: _date(request.createdAt),
                        ),
                        AdminCustomerServiceDetailField(
                          label: 'Last updated',
                          value: _date(request.updatedAt),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('Message',
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: SelectableText(request.message),
                    ),
                    if (state.failure case Some(value: final message)) ...[
                      const SizedBox(height: 16),
                      Text(
                        message,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text('Status'),
                  const SizedBox(width: 12),
                  AdminCustomerServiceStatusControl(
                    request: request,
                    onUpdated: Navigator.of(context).pop,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _date(DateTime value) =>
    DateFormat.yMMMd().add_jm().format(value.toLocal());

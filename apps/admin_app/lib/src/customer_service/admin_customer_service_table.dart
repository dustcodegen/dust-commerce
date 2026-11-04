import 'package:admin_app/src/customer_service/admin_customer_service_status_control.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Desktop-first table for explicitly allowlisted support responses.
final class AdminCustomerServiceTable extends StatelessWidget {
  /// Creates the request table.
  const AdminCustomerServiceTable({
    required this.requests,
    required this.onOpen,
    super.key,
  });

  /// Opens the complete request detail.
  final ValueChanged<AdminCustomerServiceRequest> onOpen;

  /// Current protected inbox page.
  final List<AdminCustomerServiceRequest> requests;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 1040 ? 1040 : constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _CustomerServiceHeader(),
                for (final request in requests)
                  _CustomerServiceRow(request: request, onOpen: onOpen),
              ],
            ),
          ),
        ),
      );
}

final class _CustomerServiceHeader extends StatelessWidget {
  const _CustomerServiceHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(
          children: [
            Expanded(flex: 3, child: Text('Received')),
            Expanded(flex: 4, child: Text('Customer')),
            Expanded(flex: 5, child: Text('Subject')),
            Expanded(flex: 3, child: Text('Order')),
            Expanded(flex: 3, child: Text('Status')),
            SizedBox(width: 32),
          ],
        ),
      );
}

final class _CustomerServiceRow extends StatelessWidget {
  const _CustomerServiceRow({required this.request, required this.onOpen});

  final ValueChanged<AdminCustomerServiceRequest> onOpen;
  final AdminCustomerServiceRequest request;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () => onOpen(request),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Tooltip(
                  message: DateFormat.yMMMd()
                      .add_jm()
                      .format(request.createdAt.toLocal()),
                  child: Text(
                    DateFormat.yMMMd().format(request.createdAt.toLocal()),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.name, overflow: TextOverflow.ellipsis),
                    Text(
                      request.email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(request.subject, overflow: TextOverflow.ellipsis),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  request.orderReference.match(
                    some: (value) => value,
                    none: () => '—',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AdminCustomerServiceStatusControl(request: request),
                ),
              ),
              const SizedBox(
                width: 32,
                child: Icon(Icons.chevron_right_rounded, size: 18),
              ),
            ],
          ),
        ),
      );
}

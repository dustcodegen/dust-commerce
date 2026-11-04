import 'package:admin_app/src/order/admin_cancel_order_action.dart';
import 'package:admin_app/src/order/admin_order_status_badge.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Medusa-shaped order heading with only modeled lifecycle facts.
final class AdminOrderGeneralSection extends StatelessWidget {
  /// Creates the order general section.
  const AdminOrderGeneralSection({required this.order, super.key});

  /// Complete merchant order snapshot.
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x12000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Wrap(
            runSpacing: 12,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '#${order.displayId}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Placed ${DateFormat.yMMMd().add_jm().format(order.placedAt.toLocal())}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      AdminOrderLifecycleBadge(status: order.status),
                      AdminOrderPaymentBadge(status: order.paymentStatus),
                      AdminOrderFulfillmentBadge(
                        status: order.fulfillmentStatus,
                      ),
                    ],
                  ),
                  AdminCancelOrderAction(order: order),
                ],
              ),
            ],
          ),
        ),
      );
}

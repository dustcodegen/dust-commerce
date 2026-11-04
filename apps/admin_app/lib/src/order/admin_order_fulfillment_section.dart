import 'package:admin_app/src/order/admin_create_fulfillment_action.dart';
import 'package:admin_app/src/order/admin_order_fulfillment_card.dart';
import 'package:admin_app/src/order/admin_order_status_badge.dart';
import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Fulfillment history and creation entry point for one order.
final class AdminOrderFulfillmentSection extends StatelessWidget {
  /// Creates the fulfillment section.
  const AdminOrderFulfillmentSection({required this.order, super.key});

  /// Complete merchant order snapshot.
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Fulfillment',
        action: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AdminOrderFulfillmentBadge(status: order.fulfillmentStatus),
            const SizedBox(width: 8),
            AdminCreateFulfillmentAction(order: order),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.fulfillments.isEmpty)
                const Text('No fulfillments have been created.')
              else
                for (var index = 0; index < order.fulfillments.length; index++)
                  AdminOrderFulfillmentCard(
                    order: order,
                    fulfillment: order.fulfillments[index],
                    index: index,
                  ),
              if (order.shippingName case Some(value: final name)) ...[
                const SizedBox(height: 6),
                Text(
                  'Shipping method: $name',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
}

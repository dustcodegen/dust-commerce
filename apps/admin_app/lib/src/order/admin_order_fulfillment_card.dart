import 'package:admin_app/src/order/admin_create_shipment_action.dart';
import 'package:admin_app/src/order/admin_cancel_fulfillment_action.dart';
import 'package:admin_app/src/order/admin_mark_delivered_action.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'admin_order_fulfillment_card_sections.dart';
part 'admin_order_fulfillment_card_header.dart';

/// Medusa-shaped lifecycle card for one order fulfillment.
final class AdminOrderFulfillmentCard extends StatelessWidget {
  /// Creates the numbered fulfillment card.
  const AdminOrderFulfillmentCard({
    required this.order,
    required this.fulfillment,
    required this.index,
    super.key,
  });

  /// Merchant-visible fulfillment snapshot.
  final AdminOrderFulfillment fulfillment;

  /// Zero-based display position.
  final int index;

  /// Parent order used by lifecycle actions.
  final AdminOrderDetail order;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          _AdminFulfillmentCardHeader(
            order: order,
            fulfillment: fulfillment,
            index: index,
          ),
          _AdminFulfillmentItems(fulfillment: fulfillment),
          _AdminFulfillmentFact(
            label: 'Shipping from',
            value: 'Location ${fulfillment.locationId}',
          ),
          _AdminFulfillmentFact(
            label: 'Provider',
            value: _providerName(fulfillment.providerId),
          ),
          _AdminFulfillmentTracking(fulfillment: fulfillment),
          _AdminFulfillmentCardActions(
            order: order,
            fulfillment: fulfillment,
          ),
        ]),
      );
}

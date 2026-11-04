import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';

/// Remaining positive quantities after subtracting active fulfillments.
Map<String, int> adminFulfillableQuantities(AdminOrderDetail order) {
  final fulfilled = <String, int>{};
  for (final fulfillment in order.fulfillments) {
    if (fulfillment.canceledAt case Some()) continue;
    for (final item in fulfillment.items) {
      if (item.lineItemId case Some(:final value)) {
        fulfilled[value] = (fulfilled[value] ?? 0) + item.quantity;
      }
    }
  }
  return {
    for (final item in order.items)
      if (item.quantity - (fulfilled[item.id] ?? 0) > 0)
        item.id: item.quantity - (fulfilled[item.id] ?? 0),
  };
}

/// Builds one safe command after quantity and profile compatibility checks.
Option<AdminCreateFulfillment> buildAdminFulfillmentCommand({
  required AdminOrderDetail order,
  required String locationId,
  required AdminFulfillmentShippingOption shippingOption,
  required Map<String, int> quantities,
}) {
  if (locationId.trim().isEmpty) return const None();
  final remaining = adminFulfillableQuantities(order);
  final items = <AdminCreateFulfillmentItem>[];
  for (final item in order.items) {
    final requested = quantities[item.id] ?? 0;
    final available = remaining[item.id] ?? 0;
    if (requested < 0 || requested > available) return const None();
    if (requested == 0) continue;
    if (item.shippingProfileId != Some(shippingOption.shippingProfileId)) {
      continue;
    }
    items.add(AdminCreateFulfillmentItem(id: item.id, quantity: requested));
  }
  if (items.isEmpty) return const None();
  return Some(AdminCreateFulfillment(
    items: items,
    locationId: locationId,
    noNotification: true,
    shippingOptionIdValue: shippingOption.id,
  ));
}

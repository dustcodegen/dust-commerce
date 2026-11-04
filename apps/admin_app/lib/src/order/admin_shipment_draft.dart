import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';

/// Editable carrier-label row used before creating a shipment.
final class AdminShipmentLabelDraft {
  /// Creates one raw form row.
  const AdminShipmentLabelDraft({
    required this.trackingNumber,
    required this.trackingUrl,
    required this.labelUrl,
  });

  /// Printable label URL entered by the merchant.
  final String labelUrl;

  /// Carrier tracking identifier entered by the merchant.
  final String trackingNumber;

  /// Carrier tracking URL entered by the merchant.
  final String trackingUrl;
}

/// Builds one exact, safe shipment command or rejects the whole draft.
Option<AdminCreateShipment> buildAdminShipmentCommand({
  required AdminOrderFulfillment fulfillment,
  required List<AdminShipmentLabelDraft> labels,
}) {
  if (!fulfillment.requiresShipping ||
      fulfillment.canceledAt is Some<DateTime> ||
      fulfillment.shippedAt is Some<DateTime> ||
      fulfillment.deliveredAt is Some<DateTime>) {
    return const None();
  }

  final items = <AdminCreateShipmentItem>[];
  for (final item in fulfillment.items) {
    final lineId = switch (item.lineItemId) {
      Some(:final value) => value,
      None() => '',
    };
    if (lineId.isEmpty || item.quantity <= 0) return const None();
    items.add(AdminCreateShipmentItem(id: lineId, quantity: item.quantity));
  }
  if (items.isEmpty) return const None();

  final prepared = <AdminCreateShipmentLabel>[];
  for (final row in labels) {
    final number = row.trackingNumber.trim();
    final tracking = row.trackingUrl.trim();
    final label = row.labelUrl.trim();
    if (number.isEmpty && tracking.isEmpty && label.isEmpty) continue;
    if (number.length > 255 || !_safeUrl(tracking) || !_safeUrl(label)) {
      return const None();
    }
    prepared.add(AdminCreateShipmentLabel(
      trackingNumber: number,
      trackingUrl: tracking.isEmpty ? '#' : tracking,
      labelUrl: label.isEmpty ? '#' : label,
    ));
  }
  return Some(AdminCreateShipment(
    items: items,
    labels: prepared,
    noNotification: true,
  ));
}

bool _safeUrl(String value) {
  if (value.isEmpty || value == '#') return true;
  if (value.length > 2048) return false;
  final uri = Uri.tryParse(value);
  if (uri == null || uri.host.isEmpty) return false;
  final scheme = uri.scheme.toLowerCase();
  return scheme == 'http' || scheme == 'https';
}

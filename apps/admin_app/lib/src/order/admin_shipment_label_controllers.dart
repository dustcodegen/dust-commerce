import 'package:admin_app/src/order/admin_shipment_draft.dart';
import 'package:flutter/material.dart';

/// Text owners for one editable shipment-label row.
final class AdminShipmentLabelControllers {
  /// Creates one empty tracking row.
  AdminShipmentLabelControllers()
      : trackingNumber = TextEditingController(),
        trackingUrl = TextEditingController(),
        labelUrl = TextEditingController();

  /// Printable-label URL controller.
  final TextEditingController labelUrl;

  /// Carrier tracking identifier controller.
  final TextEditingController trackingNumber;

  /// Carrier tracking URL controller.
  final TextEditingController trackingUrl;

  /// Current immutable form values.
  AdminShipmentLabelDraft get draft => AdminShipmentLabelDraft(
        trackingNumber: trackingNumber.text,
        trackingUrl: trackingUrl.text,
        labelUrl: labelUrl.text,
      );

  /// Releases every controller owned by this row.
  void dispose() {
    trackingNumber.dispose();
    trackingUrl.dispose();
    labelUrl.dispose();
  }
}

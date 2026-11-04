import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';

/// Resolves the requested, checkout, or first compatible shipping method.
Option<AdminFulfillmentShippingOption> resolveAdminFulfillmentShippingOption(
  List<AdminFulfillmentShippingOption> options,
  Option<String> requested,
  Option<String> original,
) {
  final requestedId = switch (requested) {
    Some(:final value) => value,
    None() => switch (original) {
        Some(:final value) => value,
        None() => '',
      },
  };
  for (final option in options) {
    if (option.id == requestedId) return Some(option);
  }
  return options.isEmpty ? const None() : Some(options.first);
}

/// Whether the form selects a different method from checkout.
bool adminUsesDifferentFulfillmentOption(
  Option<AdminFulfillmentShippingOption> selected,
  AdminOrderDetail order,
) {
  if (selected case Some(value: final option)) {
    if (order.shippingOptionId case Some(value: final original)) {
      return option.id != original;
    }
  }
  return false;
}

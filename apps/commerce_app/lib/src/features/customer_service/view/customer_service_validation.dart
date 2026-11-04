import 'package:dust_flutter/i18n.dart';
import 'package:flutter/widgets.dart';

/// Validates a required bounded customer-service field.
String? customerServiceRequired(
  BuildContext context,
  String? value, {
  required int maximum,
}) {
  final normalized = value?.trim() ?? '';
  if (normalized.isEmpty) {
    return context.tr(
      'shop_customer_service_required',
      defaultText: 'This field is required.',
    );
  }
  return _bounded(context, normalized, maximum);
}

/// Validates the customer-service reply address.
String? customerServiceEmail(BuildContext context, String? value) {
  final normalized = value?.trim() ?? '';
  final valid = normalized.length >= 3 &&
      normalized.length <= 254 &&
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(normalized);
  return valid
      ? null
      : context.tr(
          'shop_customer_service_email_invalid',
          defaultText: 'Enter a valid email address.',
        );
}

/// Validates a bounded optional customer-service field.
String? customerServiceOptional(
  BuildContext context,
  String? value, {
  required int maximum,
}) =>
    _bounded(context, value?.trim() ?? '', maximum);

String? _bounded(BuildContext context, String value, int maximum) =>
    value.length <= maximum
        ? null
        : context.tr(
            'shop_customer_service_too_long',
            defaultText: 'Use at most {count} characters.',
            args: {'count': maximum},
          );

import 'package:commerce_app/commerce_app.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Localized support failure that never echoes server internals.
final class CustomerServiceFailureText extends StatelessWidget {
  /// Creates a live-region failure from classified state.
  const CustomerServiceFailureText({required this.failure, super.key});

  /// Latest classified failure.
  final Option<CustomerServiceFailure> failure;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Text(
          failure.match(
            some: (value) => switch (value) {
              CustomerServiceFailure.invalidInput => context.tr(
                  'shop_customer_service_invalid',
                  defaultText: 'Check the form and try again.',
                ),
              CustomerServiceFailure.sessionExpired => context.tr(
                  'shop_customer_service_session_expired',
                  defaultText:
                      'Your session expired. Sign in again or clear it to continue as a guest.',
                ),
              CustomerServiceFailure.retryable => context.tr(
                  'shop_customer_service_failed',
                  defaultText:
                      'We could not send your message. Please try again.',
                ),
            },
            none: () => context.tr(
              'shop_customer_service_failed',
              defaultText: 'We could not send your message. Please try again.',
            ),
          ),
          style: const TextStyle(color: StoreColors.danger),
        ),
      );
}

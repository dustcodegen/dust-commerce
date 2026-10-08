import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_payment_choice.dart';
import 'checkout_primary_action.dart';

/// Expanded region-backed payment choices and progression action.
final class CheckoutPaymentChoices extends StatelessWidget {
  /// Creates the payment-choice list.
  const CheckoutPaymentChoices({required this.state, super.key});

  /// Retained provider selection and request state.
  final CheckoutState state;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!state.paymentProvidersLoaded && state.isBusy)
            const Center(child: CircularProgressIndicator())
          else if (!state.paymentProvidersLoaded) ...[
            if (state.message != null) StoreErrorMessage(state.message!),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () =>
                    context.readCheckoutViewModel().loadPaymentMethods(),
                child: const TranslatedText(
                  'shop_checkout_retry_payment_methods',
                  defaultText: 'Retry payment methods',
                ),
              ),
            ),
          ] else if (state.paymentProviders.isEmpty)
            const TranslatedText(
              'shop_checkout_no_payment_methods',
              defaultText: 'No payment methods are available.',
            )
          else ...[
            for (final provider in state.paymentProviders) ...[
              CheckoutPaymentChoice(
                provider: provider,
                selected: state.isPaymentSelected(provider.id),
                enabled: !state.isBusy,
              ),
              const SizedBox(height: 8),
            ],
            if (state.message != null) StoreErrorMessage(state.message!),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: CheckoutPrimaryAction(
                label: context.tr(
                  'shop_checkout_continue_review',
                  defaultText: 'Continue to review',
                ),
                onPressed: state.hasAvailablePaymentMethod && !state.isBusy
                    ? () => context.pushCheckoutStep('review')
                    : null,
              ),
            ),
          ],
        ],
      );
}

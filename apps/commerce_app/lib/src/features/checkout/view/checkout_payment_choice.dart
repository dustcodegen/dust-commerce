import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

import 'checkout_payment_summary.dart';
import 'checkout_radio_mark.dart';

/// Source-shaped payment radio row with explicit selection semantics.
final class CheckoutPaymentChoice extends StatelessWidget {
  /// Creates one region-enabled payment provider choice.
  const CheckoutPaymentChoice({
    required this.provider,
    required this.selected,
    required this.enabled,
    super.key,
  });

  /// Whether another payment mutation permits interaction.
  final bool enabled;

  /// Public provider returned for the cart's region.
  final PaymentProviderView provider;

  /// Whether this provider is retained on the cart.
  final bool selected;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        checked: selected,
        enabled: enabled,
        inMutuallyExclusiveGroup: true,
        label: PaymentProviderTitle.label(context, provider.id),
        child: ExcludeSemantics(
          child: Material(
            color: StoreColors.base,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: selected ? StoreColors.interactive : StoreColors.border,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: enabled
                  ? () =>
                      context.readCheckoutViewModel().selectPayment(provider.id)
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    CheckoutRadioMark(selected: selected, enabled: enabled),
                    const SizedBox(width: 16),
                    Expanded(child: PaymentProviderTitle(id: provider.id)),
                    const Icon(Icons.credit_card, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

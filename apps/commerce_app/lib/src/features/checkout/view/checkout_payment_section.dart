import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_payment_choices.dart';
import 'checkout_payment_summary.dart';
import 'checkout_step_header.dart';

/// Region-backed provider choices translated from Medusa Payment.
final class CheckoutPaymentSection extends StatelessWidget {
  /// Creates the payment step.
  const CheckoutPaymentSection({
    required this.open,
    required this.state,
    super.key,
  });

  /// Whether payment selection is expanded.
  final bool open;

  /// Retained payment selection and progress.
  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    final selected = state.hasPaymentMethod;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutStepHeader(
          title: context.tr('shop_checkout_payment', defaultText: 'Payment'),
          open: open,
          complete: selected,
          onEdit: () => context.pushCheckoutStep('payment'),
        ),
        if (open)
          CheckoutPaymentChoices(state: state)
        else if (selected)
          CheckoutPaymentSummary(state: state),
        const CheckoutSectionDivider(),
      ],
    );
  }
}

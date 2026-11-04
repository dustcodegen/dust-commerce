import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_address_controllers.dart';
import 'checkout_form_controls.dart';

/// Contact row that follows Medusa's billing-address checkbox.
final class CheckoutContactFields extends StatelessWidget {
  /// Creates the email and optional phone inputs.
  const CheckoutContactFields({
    required this.controllers,
    required this.email,
    super.key,
  });

  /// Shipping-address controllers own the courier phone value.
  final CheckoutAddressControllers controllers;

  /// Checkout receipt email controller.
  final TextEditingController email;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CheckoutFormField(
              controller: email,
              label: context.tr(
                'shop_checkout_email',
                defaultText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: CheckoutFormField(
              controller: controllers.phone,
              label: context.tr(
                'shop_checkout_phone',
                defaultText: 'Phone',
              ),
              keyboardType: TextInputType.phone,
              required: false,
            ),
          ),
        ],
      );
}

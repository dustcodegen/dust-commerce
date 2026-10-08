import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// Source-shaped checkout failure copy from Medusa ErrorMessage.
final class CheckoutErrorMessage extends StatelessWidget {
  /// Creates an inline checkout error message.
  const CheckoutErrorMessage(this.message, {super.key});

  /// Customer-facing error returned by the checkout operation.
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(message, style: _checkoutErrorStyle),
      );
}

const _checkoutErrorStyle = TextStyle(
  color: StoreColors.rose,
  fontSize: 12,
  height: 20 / 12,
);

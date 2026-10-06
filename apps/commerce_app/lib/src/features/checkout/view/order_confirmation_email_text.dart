import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Confirmation sentence matching Medusa OrderDetails' semibold email span.
final class OrderConfirmationEmailText extends StatelessWidget {
  /// Creates the confirmation sentence for [email].
  const OrderConfirmationEmailText({required this.email, super.key});

  /// Address receiving the confirmation details.
  final String email;

  @override
  Widget build(BuildContext context) {
    final text = context.tr(
      'shop_checkout_confirmation_sent',
      defaultText: 'We have sent the order confirmation details to {email}.',
      args: {'email': email},
    );
    final start = text.indexOf(email);
    if (start < 0) return Text(text);

    return Text.rich(
      TextSpan(children: [
        TextSpan(text: text.substring(0, start)),
        TextSpan(
          text: email,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        TextSpan(text: text.substring(start + email.length)),
      ]),
    );
  }
}

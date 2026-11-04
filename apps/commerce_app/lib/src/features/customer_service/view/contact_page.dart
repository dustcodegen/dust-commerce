import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:flutter/material.dart';

/// Contact destination linked by Medusa's order help component.
@AppRoute('/contact', name: 'contact', guards: [])
final class ContactPage extends StatelessWidget {
  /// Creates the contact alias with an optional order prefill.
  const ContactPage({this.orderReference = '', super.key});

  /// Human-facing order number carried from an order screen.
  final String orderReference;

  @override
  Widget build(BuildContext context) => StoreScaffold(
        body: CustomerServiceContent(orderReference: orderReference),
      );
}

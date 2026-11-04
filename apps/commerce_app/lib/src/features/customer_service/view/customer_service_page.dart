import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:flutter/material.dart';

/// Customer Service destination linked by the Medusa account layout.
@AppRoute('/customer-service', name: 'customerService', guards: [])
final class CustomerServicePage extends StatelessWidget {
  /// Creates the support route with an optional order prefill.
  const CustomerServicePage({this.orderReference = '', super.key});

  /// Human-facing order number carried from another Store route.
  final String orderReference;

  @override
  Widget build(BuildContext context) => StoreScaffold(
        body: CustomerServiceContent(orderReference: orderReference),
      );
}

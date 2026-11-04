import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

import 'checkout_address_section.dart';
import 'checkout_attribution.dart';
import 'checkout_delivery_section.dart';
import 'checkout_payment_section.dart';
import 'checkout_review_section.dart';
import 'checkout_summary.dart';

/// Responsive source checkout grid: form plus a 416px summary.
final class CheckoutLayout extends StatelessWidget {
  /// Creates the checkout layout.
  const CheckoutLayout({
    required this.step,
    required this.checkout,
    required this.cart,
    required this.customer,
    required this.addressBook,
    super.key,
  });

  /// Separately loaded saved destinations for authenticated checkout.
  final AddressBookState addressBook;

  /// Server-authoritative cart rendered by the summary.
  final CartState cart;

  /// Server-proven customer, absent for guest checkout.
  final Customer? customer;

  /// Retained checkout workflow state.
  final CheckoutState checkout;

  /// Active source-compatible query step.
  final String step;

  @override
  Widget build(BuildContext context) {
    final view = cart.cart!;
    final form = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutAddressSection(
          key: ValueKey(
            '${view.cart.id}:${customer?.id ?? 'guest'}',
          ),
          open: step == 'address',
          state: checkout,
          countries: view.cart.region.countries,
          customer: customer,
          addressBook: addressBook,
        ),
        const SizedBox(height: 32),
        CheckoutDeliverySection(
          open: step == 'delivery',
          state: checkout,
          cart: cart,
        ),
        const SizedBox(height: 32),
        CheckoutPaymentSection(
          open: step == 'payment',
          state: checkout,
        ),
        const SizedBox(height: 32),
        CheckoutReviewSection(open: step == 'review', state: checkout),
      ],
    );
    final summary = CheckoutSummary(view: view, state: cart);
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1440),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 44, 24, 48),
                child: MediaQuery.sizeOf(context).width >= 1024
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: form),
                          const SizedBox(width: 160),
                          SizedBox(width: 416, child: summary),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [form, const SizedBox(height: 48), summary],
                      ),
              ),
            ),
          ),
          const CheckoutAttribution(),
        ],
      ),
    );
  }
}

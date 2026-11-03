import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Shipping information route from the Medusa storefront.
@AppRoute('/shipping', name: 'shipping', guards: [])
final class ShippingPage extends StatelessWidget {
  /// Creates the shipping information page.
  const ShippingPage({super.key});

  @override
  Widget build(BuildContext context) => _PolicyPage(
        title: context.tr(
          'shop_policy_shipping_title',
          defaultText: 'Shipping information',
        ),
        summary: context.tr(
          'shop_policy_shipping_summary',
          defaultText:
              'Shipping methods and final costs are calculated for your destination at checkout.',
        ),
      );
}

/// Return policy route from the Medusa storefront.
@AppRoute('/returns', name: 'returns', guards: [])
final class ReturnsPage extends StatelessWidget {
  /// Creates the return policy page.
  const ReturnsPage({super.key});

  @override
  Widget build(BuildContext context) => _PolicyPage(
        title: context.tr(
          'shop_policy_returns_title',
          defaultText: 'Return policy',
        ),
        summary: context.tr(
          'shop_policy_returns_summary',
          defaultText:
              'Return eligibility and instructions are confirmed by customer service for each order.',
        ),
      );
}

/// Privacy policy route from the Medusa storefront.
@AppRoute('/privacy', name: 'privacy', guards: [])
final class PrivacyPage extends StatelessWidget {
  /// Creates the privacy policy page.
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) => _PolicyPage(
        title: context.tr(
          'shop_policy_privacy_title',
          defaultText: 'Privacy policy',
        ),
        summary: context.tr(
          'shop_policy_privacy_summary',
          defaultText:
              'Privacy details are not configured for this storefront yet. Contact support for the current policy.',
        ),
      );
}

/// Terms route from the Medusa storefront.
@AppRoute('/terms', name: 'terms', guards: [])
final class TermsPage extends StatelessWidget {
  /// Creates the terms page.
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) => _PolicyPage(
        title: context.tr(
          'shop_policy_terms_title',
          defaultText: 'Terms of service',
        ),
        summary: context.tr(
          'shop_policy_terms_summary',
          defaultText:
              'Purchase terms are not configured for this storefront yet. Contact support before placing an order.',
        ),
      );
}

final class _PolicyPage extends StatelessWidget {
  const _PolicyPage({required this.title, required this.summary});

  final String summary;
  final String title;

  @override
  Widget build(BuildContext context) => StoreScaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 896),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 48, 24, 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 30,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          context.tr(
                            'shop_policy_unavailable',
                            defaultText: 'Policy information unavailable',
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary,
                          style: const TextStyle(
                            color: StoreColors.foregroundSubtle,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FilledButton(
                            onPressed: () =>
                                context.navigator.customerService().go(),
                            child: Text(
                              context.tr(
                                'shop_policy_contact_customer_service',
                                defaultText: 'Contact customer service',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const StoreFooter(),
            ],
          ),
        ),
      );
}

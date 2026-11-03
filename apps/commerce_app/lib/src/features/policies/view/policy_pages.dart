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
  Widget build(BuildContext context) => PolicyPage(
        title: context.tr(
          'shop_policy_shipping_title',
          defaultText: 'Shipping information',
        ),
        children: const [PoliciesUnavailable()],
      );
}

/// Return policy route from the Medusa storefront.
@AppRoute('/returns', name: 'returns', guards: [])
final class ReturnsPage extends StatelessWidget {
  /// Creates the return policy page.
  const ReturnsPage({super.key});

  @override
  Widget build(BuildContext context) => PolicyPage(
        title: context.tr(
          'shop_policy_returns_title',
          defaultText: 'Return policy',
        ),
        children: const [PoliciesUnavailable()],
      );
}

/// Privacy policy route from the Medusa storefront.
@AppRoute('/privacy', name: 'privacy', guards: [])
final class PrivacyPage extends StatelessWidget {
  /// Creates the privacy policy page.
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) => PolicyPage(
        title: context.tr(
          'shop_policy_privacy_title',
          defaultText: 'Privacy policy',
        ),
        children: [
          const PlaceholderNotice(),
          Text(
            context.tr(
              'shop_policy_privacy_collection',
              defaultText:
                  'Morrow collects the information you provide at checkout, such as your name, email address and shipping address, to process and deliver your order.',
            ),
          ),
          Text(
            context.tr(
              'shop_policy_privacy_payment',
              defaultText:
                  'Payment details are handled by our payment provider and are not stored by the store. Cookies are used to keep your cart and sign-in session.',
            ),
          ),
        ],
      );
}

/// Terms route from the Medusa storefront.
@AppRoute('/terms', name: 'terms', guards: [])
final class TermsPage extends StatelessWidget {
  /// Creates the terms page.
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) => PolicyPage(
        title: context.tr(
          'shop_policy_terms_title',
          defaultText: 'Terms of service',
        ),
        children: [
          const PlaceholderNotice(),
          Text(
            context.tr(
              'shop_policy_terms_agreement',
              defaultText:
                  'By placing an order with Morrow you agree to these terms. Prices, product availability and shipping options are shown on the product pages and at checkout, and may change without notice.',
            ),
          ),
          Text(
            context.tr(
              'shop_policy_terms_orders',
              defaultText:
                  'Orders are confirmed by email once payment is received. Returns and refunds are handled according to our return policy.',
            ),
          ),
        ],
      );
}

/// Shared source-shaped policy page shell.
final class PolicyPage extends StatelessWidget {
  /// Creates a policy page with source-ordered content blocks.
  const PolicyPage({required this.title, required this.children, super.key});

  /// Content blocks below the title.
  final List<Widget> children;

  /// Page heading.
  final String title;

  @override
  Widget build(BuildContext context) => StoreScaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
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
                        const SizedBox(height: 32),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: children.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 24),
                          itemBuilder: (_, index) => DefaultTextStyle(
                            style: const TextStyle(
                              color: StoreColors.foreground,
                              fontSize: 16,
                              height: 1.5,
                            ),
                            child: children[index],
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

/// Source-compatible notice used when regional policy metadata is absent.
final class PoliciesUnavailable extends StatelessWidget {
  /// Creates the published-policy boundary.
  const PoliciesUnavailable({super.key});

  @override
  Widget build(BuildContext context) => Text(
        context.tr(
          'shop_policy_published_unavailable',
          defaultText:
              "Policy details for this region haven't been published yet.",
        ),
        style: const TextStyle(color: StoreColors.foregroundSubtle),
      );
}

/// Source placeholder notice kept visible until store-owned copy replaces it.
final class PlaceholderNotice extends StatelessWidget {
  /// Creates the starter placeholder notice.
  const PlaceholderNotice({super.key});

  @override
  Widget build(BuildContext context) => Text(
        context.tr(
          'shop_policy_placeholder',
          defaultText:
              "This is placeholder content from the Medusa starter. Replace it with your store's own text before launch.",
        ),
        style: const TextStyle(color: StoreColors.foregroundSubtle),
      );
}

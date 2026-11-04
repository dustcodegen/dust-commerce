import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

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

/// Renders regional shipping policy data without inventing defaults.
final class ShippingPolicyContent extends StatelessWidget {
  /// Creates the regional shipping policy content.
  const ShippingPolicyContent({
    required this.countryCode,
    required this.region,
    super.key,
  });

  /// Country shown in the source-compatible shipping sentence.
  final String countryCode;

  /// Active selling region.
  final Region region;

  @override
  Widget build(BuildContext context) {
    final policy = region.policy;
    if (policy == null) return const PoliciesUnavailable();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr(
            'shop_policy_shipping_country',
            defaultText:
                'Orders to {country} ship with the following rates and delivery times.',
            args: {'country': countryCode.toUpperCase()},
          ),
        ),
        const SizedBox(height: 24),
        Table(
          columnWidths: const {0: IntrinsicColumnWidth(), 1: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.top,
          children: [
            TableRow(
              children: [
                _PolicyLabel(
                  context.tr(
                    'shop_policy_shipping_rate',
                    defaultText: 'Shipping rate',
                  ),
                ),
                Text(
                    formatPolicyRate(policy.shippingRate, region.currencyCode)),
              ],
            ),
            TableRow(
              children: [
                _PolicyLabel(
                  context.tr(
                    'shop_policy_processing_time',
                    defaultText: 'Processing time',
                  ),
                ),
                Text(
                  '${formatPolicyDays(policy.handlingDaysMin, policy.handlingDaysMax)} ${context.tr('shop_policy_business_days', defaultText: 'business days')}',
                ),
              ],
            ),
            TableRow(
              children: [
                _PolicyLabel(
                  context.tr(
                    'shop_policy_delivery_time',
                    defaultText: 'Delivery time',
                  ),
                ),
                Text(
                  '${formatPolicyDays(policy.transitDaysMin, policy.transitDaysMax)} ${context.tr('shop_policy_business_days_after_dispatch', defaultText: 'business days after dispatch')}',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          context.tr(
            'shop_policy_shipping_checkout',
            defaultText:
                'Available shipping methods and final costs are shown at checkout.',
          ),
          style: const TextStyle(color: StoreColors.foregroundSubtle),
        ),
      ],
    );
  }
}

/// Renders regional return policy data without guessing missing values.
final class ReturnsPolicyContent extends StatelessWidget {
  /// Creates the regional return policy content.
  const ReturnsPolicyContent({required this.region, super.key});

  /// Active selling region.
  final Region region;

  @override
  Widget build(BuildContext context) {
    final policy = region.policy;
    if (policy == null) return const PoliciesUnavailable();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.tr(
            'shop_policy_returns_window',
            defaultText:
                'You can return items within {days} days of delivery. Items are returned by mail.',
            args: {'days': '${policy.returnWindowDays}'},
          ),
        ),
        const SizedBox(height: 24),
        Text(
          policy.freeReturns
              ? context.tr(
                  'shop_policy_returns_free',
                  defaultText: 'Return shipping is free.',
                )
              : context.tr(
                  'shop_policy_returns_paid',
                  defaultText:
                      'Return shipping costs are paid by the customer.',
                ),
        ),
      ],
    );
  }
}

/// Formats a source-policy rate without floating-point conversion.
String formatPolicyRate(String rate, String currencyCode) =>
    rate == '0' ? 'Free' : '${currencyCode.toUpperCase()} $rate';

/// Formats a source-policy business-day range.
String formatPolicyDays(int minimum, int maximum) =>
    minimum == maximum ? '$minimum' : '$minimum-$maximum';

final class _PolicyLabel extends StatelessWidget {
  const _PolicyLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 24, bottom: 8),
        child: Text(
          text,
          style: const TextStyle(color: StoreColors.foregroundSubtle),
        ),
      );
}

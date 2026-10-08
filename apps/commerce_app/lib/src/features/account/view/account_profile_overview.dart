import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_recent_orders.dart';

/// Customer identity, completion, addresses, and recent-order summary.
final class AccountProfileOverview extends StatelessWidget {
  /// Creates the source-shaped desktop overview.
  const AccountProfileOverview({
    required this.customer,
    required this.addresses,
    required this.orders,
    super.key,
  });

  /// Customer-owned address state.
  final AddressBookState addresses;

  /// Server-proven customer.
  final Customer customer;

  /// Customer-owned order state.
  final AccountOrdersState orders;

  @override
  Widget build(BuildContext context) {
    final summary = AccountOverviewSummary.from(
      customer: customer,
      addresses: addresses.addresses,
      orders: orders.orders,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 8,
          children: [
            Text(
              context.tr(
                'shop_account_hello',
                defaultText: 'Hello {name}',
                args: {'name': customer.firstName ?? customer.displayName},
              ),
              style: const TextStyle(
                fontSize: 24,
                height: 36 / 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text.rich(
              TextSpan(
                text: context.tr(
                  'shop_account_signed_in_as',
                  defaultText: 'Signed in as: ',
                ),
                children: [
                  TextSpan(
                    text: customer.email,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 12, height: 20 / 12),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 32),
        Wrap(
          spacing: 64,
          runSpacing: 24,
          children: [
            _OverviewMetric(
              label: context.tr(
                'shop_account_profile',
                defaultText: 'Profile',
              ),
              value:
                  addresses.hasLoaded ? '${summary.profileCompletion}%' : '—',
              suffix: context.tr(
                'shop_account_completed',
                defaultText: 'COMPLETED',
              ),
            ),
            _OverviewMetric(
              label: context.tr(
                'shop_account_addresses',
                defaultText: 'Addresses',
              ),
              value: addresses.hasLoaded ? '${summary.addressCount}' : '—',
              suffix: context.tr(
                'shop_account_saved',
                defaultText: 'SAVED',
              ),
            ),
          ],
        ),
        if (!addresses.hasLoaded &&
            addresses.status == AddressBookStatus.failed) ...[
          const SizedBox(height: 16),
          Text(context.tr(
            'shop_account_address_error',
            defaultText: 'We could not load your address book.',
          )),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: context.readAddressBookViewModel().load,
              child: const TranslatedText(
                'shop_retry',
                defaultText: 'Try again',
              ),
            ),
          ),
        ],
        const SizedBox(height: 40),
        const TranslatedText(
          'shop_account_recent_orders',
          defaultText: 'Recent orders',
          style: TextStyle(
            fontSize: 16,
            height: 24 / 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        AccountRecentOrders(state: orders, orders: summary.recentOrders),
      ],
    );
  }
}

final class _OverviewMetric extends StatelessWidget {
  const _OverviewMetric({
    required this.label,
    required this.value,
    required this.suffix,
  });

  final String label;
  final String suffix;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              height: 24 / 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                suffix,
                style: const TextStyle(
                  color: StoreColors.foregroundSubtle,
                  fontSize: 14,
                  height: 24 / 14,
                ),
              ),
            ],
          ),
        ],
      );
}

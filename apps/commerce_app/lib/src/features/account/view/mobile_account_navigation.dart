import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_section.dart';
import 'account_navigation_items.dart';

/// Compact account navigation translated from Medusa's mobile AccountNav.
final class MobileAccountNavigation extends StatelessWidget {
  /// Creates compact navigation for the current account route.
  const MobileAccountNavigation({
    required this.customer,
    required this.state,
    required this.active,
    super.key,
  });

  /// Active account route.
  final AccountSection active;

  /// Server-proven customer.
  final Customer customer;

  /// Current session state.
  final AccountState state;

  @override
  Widget build(BuildContext context) {
    if (active != AccountSection.overview) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: () => context.navigator.account().go(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 8),
            minimumSize: Size.zero,
            foregroundColor: StoreColors.foreground,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: const TextStyle(fontSize: 12, height: 20 / 12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.keyboard_arrow_left, size: 16),
              SizedBox(width: 8),
              TranslatedText(
                'shop_account_title',
                defaultText: 'Account',
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            context.tr(
              'shop_account_hello',
              defaultText: 'Hello {name}',
              args: {'name': customer.firstName ?? customer.displayName},
            ),
            style: const TextStyle(
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        MobileAccountNavigationItem(
          icon: Icons.person_outline,
          label: context.tr('shop_account_profile', defaultText: 'Profile'),
          onTap: () => context.navigator.accountProfile().go(),
        ),
        MobileAccountNavigationItem(
          icon: Icons.location_on_outlined,
          label: context.tr(
            'shop_account_addresses',
            defaultText: 'Addresses',
          ),
          onTap: () => context.navigator.accountAddresses().go(),
        ),
        MobileAccountNavigationItem(
          icon: Icons.inventory_2_outlined,
          label: context.tr('shop_account_orders', defaultText: 'Orders'),
          onTap: () => context.navigator.accountOrders().go(),
        ),
        MobileAccountNavigationItem(
          icon: Icons.logout,
          label: context.tr('shop_account_log_out', defaultText: 'Log out'),
          onTap: context.readAccountViewModel().signOut,
          enabled: !state.isBusy,
        ),
      ],
    );
  }
}

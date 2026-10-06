import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_section.dart';
import 'account_navigation_items.dart';

const _accountNavTitleStyle = TextStyle(
  fontSize: 16,
  height: 1.5,
  fontWeight: FontWeight.w600,
);

/// Desktop account section navigation translated from Medusa AccountNav.
final class AccountNavigation extends StatelessWidget {
  /// Creates the navigation for [active].
  const AccountNavigation(
      {required this.state, required this.active, super.key});

  /// Active account route.
  final AccountSection active;

  /// Current session and sign-out state.
  final AccountState state;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'shop_account_title',
            defaultText: 'Account',
            style: _accountNavTitleStyle,
          ),
          const SizedBox(height: 16),
          AccountNavigationLink(
            active: active,
            section: AccountSection.overview,
            label: context.tr(
              'shop_account_overview',
              defaultText: 'Overview',
            ),
            onPressed: () => context.navigator.account().go(),
          ),
          AccountNavigationLink(
            active: active,
            section: AccountSection.profile,
            label: context.tr(
              'shop_account_profile',
              defaultText: 'Profile',
            ),
            onPressed: () => context.navigator.accountProfile().go(),
          ),
          AccountNavigationLink(
            active: active,
            section: AccountSection.addresses,
            label: context.tr(
              'shop_account_addresses',
              defaultText: 'Addresses',
            ),
            onPressed: () => context.navigator.accountAddresses().go(),
          ),
          AccountNavigationLink(
            active: active,
            section: AccountSection.orders,
            label: context.tr(
              'shop_account_orders',
              defaultText: 'Orders',
            ),
            onPressed: () => context.navigator.accountOrders().go(),
          ),
          TextButton(
            onPressed:
                state.isBusy ? null : context.readAccountViewModel().signOut,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              foregroundColor: StoreColors.foregroundSubtle,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: const TextStyle(fontSize: 16, height: 1.5),
            ),
            child: state.operation == AccountOperation.signOut && state.isBusy
                ? const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const TranslatedText(
                    'shop_account_log_out',
                    defaultText: 'Log out',
                  ),
          ),
          if (state.status == AccountStatus.failed &&
              state.operation == AccountOperation.signOut) ...[
            const SizedBox(height: 12),
            Text(
              state.message ?? '',
              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          ],
        ],
      );
}

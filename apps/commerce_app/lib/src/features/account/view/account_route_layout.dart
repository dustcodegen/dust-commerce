import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/material.dart';

import 'account_navigation.dart';
import 'account_section.dart';
import 'account_support.dart';
import 'mobile_account_navigation.dart';

/// Shared Medusa account shell for overview, profile, addresses, and orders.
final class AccountRouteLayout extends StatelessWidget {
  /// Creates the authenticated account layout.
  const AccountRouteLayout({
    required this.customer,
    required this.state,
    required this.active,
    required this.child,
    super.key,
  });

  /// Active account route.
  final AccountSection active;

  /// Route-specific content.
  final Widget child;

  /// Server-proven customer.
  final Customer customer;

  /// Current session state.
  final AccountState state;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1024;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: desktop ? 48 : 0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: desktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 240,
                                    child: AccountNavigation(
                                      state: state,
                                      active: active,
                                    ),
                                  ),
                                  Expanded(child: child),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  MobileAccountNavigation(
                                    customer: customer,
                                    state: state,
                                    active: active,
                                  ),
                                  if (active != AccountSection.overview) ...[
                                    const SizedBox(height: 32),
                                    child,
                                  ],
                                ],
                              ),
                      ),
                      if (desktop) const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: AccountSupport(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const StoreFooter(),
        ],
      ),
    );
  }
}

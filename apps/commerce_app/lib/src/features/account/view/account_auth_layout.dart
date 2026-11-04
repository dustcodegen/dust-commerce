import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

import 'account_support.dart';

/// Signed-out account shell translated from the DTC AccountLayout.
final class AccountAuthLayout extends StatelessWidget {
  /// Creates the public account shell around [child].
  const AccountAuthLayout({required this.child, super.key});

  /// Sign-in or registration content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 1024;
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              // CSS content-container padding is inside max-w-5xl. Flutter's
              // padding is outside its child, so 1040 keeps the 1024px source
              // content box after the 24px viewport gutters are normalized.
              constraints: const BoxConstraints(maxWidth: 1040),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: desktop ? 48 : 0,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: desktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 240),
                                Expanded(child: child),
                              ],
                            )
                          : child,
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
          const StoreFooter(),
        ],
      ),
    );
  }
}

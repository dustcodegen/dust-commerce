import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _sourceTextSmall = TextStyle(fontSize: 12, height: 20 / 12);

/// Honest read-only rendering of the customer's sign-in email.
final class ProfileEmailInfo extends StatelessWidget {
  /// Creates email information for [customer].
  const ProfileEmailInfo({required this.customer, super.key});

  /// Current public customer profile.
  final Customer customer;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context
                      .tr('shop_account_email', defaultText: 'Email')
                      .toUpperCase(),
                  style: _sourceTextSmall,
                ),
                Text(
                  customer.email,
                  style: _sourceTextSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            context.tr(
              'shop_account_sign_in_email',
              defaultText: 'Sign-in email',
            ),
            style: _sourceTextSmall.copyWith(
              color: StoreColors.foregroundMuted,
            ),
          ),
        ],
      );
}

import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Registration consent copy with the same actionable policy links as Medusa.
final class AccountPolicyNotice extends StatelessWidget {
  /// Creates the registration consent notice.
  const AccountPolicyNotice({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            context.tr(
              'shop_account_policy_prefix',
              defaultText: "By creating an account, you agree to Morrow's ",
            ),
            style: TextStyle(fontSize: 12, height: 20 / 12),
          ),
          _AccountPolicyLink(
            label: context.tr(
              'shop_account_policy_privacy',
              defaultText: 'Privacy Policy',
            ),
            onPressed: () => context.navigator.privacy().go(),
          ),
          Text(
            context.tr('shop_account_policy_and', defaultText: ' and '),
            style: TextStyle(fontSize: 12, height: 20 / 12),
          ),
          _AccountPolicyLink(
            label: context.tr(
              'shop_account_policy_terms',
              defaultText: 'Terms of Use',
            ),
            onPressed: () => context.navigator.terms().go(),
          ),
          Text(
            context.tr('shop_account_policy_end', defaultText: '.'),
            style: const TextStyle(fontSize: 12, height: 20 / 12),
          ),
        ],
      );
}

final class _AccountPolicyLink extends StatelessWidget {
  const _AccountPolicyLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontSize: 12,
            height: 20 / 12,
            decoration: TextDecoration.underline,
          ),
        ),
        child: Text(label),
      );
}

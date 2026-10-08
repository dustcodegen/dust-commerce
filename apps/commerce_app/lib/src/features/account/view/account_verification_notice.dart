import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-shaped registration or sign-in verification notice.
final class AccountVerificationNotice extends StatelessWidget {
  /// Creates the notice for a credential-proven [email].
  const AccountVerificationNotice({
    required this.email,
    required this.bottomMargin,
    super.key,
  });

  /// Space before the form that follows this notice.
  final double bottomMargin;

  /// Normalized recipient returned by the registration flow.
  final String email;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.only(bottom: bottomMargin),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StoreColors.subtle,
          border: Border.all(color: StoreColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          context.tr(
            'shop_account_verification_sent',
            defaultText: 'We sent a verification link to {email}. Please '
                'check your inbox to verify your email, then sign in.',
            args: {'email': email},
          ),
          textAlign: TextAlign.center,
        ),
      );
}

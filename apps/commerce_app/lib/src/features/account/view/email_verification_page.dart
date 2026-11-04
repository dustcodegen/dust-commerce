import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa-compatible public email capability route.
@AppRoute('/verify-account', name: 'verifyAccount', guards: [])
final class EmailVerificationPage extends StatefulWidget {
  /// Creates the verification route from its query [token].
  const EmailVerificationPage({this.token = '', super.key});

  /// Secret query value used only for the confirmation request.
  final String token;

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Option<String> _requestedToken = const None();

  @override
  void initState() {
    super.initState();
    _verify();
  }

  @override
  void didUpdateWidget(EmailVerificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token) _verify();
  }

  void _verify() {
    if (_requestedToken case Some(:final value) when value == widget.token) {
      return;
    }
    _requestedToken = Some(widget.token);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(
            context.readEmailVerificationViewModel().verify(widget.token));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchEmailVerificationViewModel().value;
    return StoreScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 384),
                  child: _VerificationContent(status: state.status),
                ),
              ),
            ),
            const StoreFooter(),
          ],
        ),
      ),
    );
  }
}

final class _VerificationContent extends StatelessWidget {
  const _VerificationContent({required this.status});

  final EmailVerificationStatus status;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const TranslatedText(
            'shop_email_verification_title',
            defaultText: 'EMAIL VERIFICATION',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            _message(context),
            textAlign: TextAlign.center,
          ),
          if (status == EmailVerificationStatus.success ||
              status == EmailVerificationStatus.failed) ...[
            const SizedBox(height: 16),
            status == EmailVerificationStatus.success
                ? FilledButton(
                    onPressed: () => context.navigator.account().go(),
                    child: const TranslatedText(
                      'shop_email_verification_sign_in',
                      defaultText: 'Go to sign in',
                    ),
                  )
                : OutlinedButton(
                    onPressed: () => context.navigator.account().go(),
                    child: const TranslatedText(
                      'shop_email_verification_sign_in',
                      defaultText: 'Go to sign in',
                    ),
                  ),
          ],
        ],
      );

  String _message(BuildContext context) => switch (status) {
        EmailVerificationStatus.success => context.tr(
            'shop_email_verification_success',
            defaultText:
                'Your email is verified. You can now sign in to your account.',
          ),
        EmailVerificationStatus.failed => context.tr(
            'shop_email_verification_failed',
            defaultText: 'This verification link is invalid or has expired. '
                'Sign in to receive a new verification email.',
          ),
        _ => context.tr(
            'shop_email_verification_loading',
            defaultText: 'Verifying your email...',
          ),
      };
}

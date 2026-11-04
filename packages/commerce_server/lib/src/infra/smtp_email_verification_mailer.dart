import 'dart:convert';

import 'package:commerce_server/src/features/account/mail.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/fp.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

/// Sends customer verification links through a TLS-enforcing SMTP connection.
final class SmtpEmailVerificationMailer implements EmailVerificationMailer {
  /// Creates the server-only SMTP adapter.
  SmtpEmailVerificationMailer({
    required String host,
    required int port,
    required bool ssl,
    required Option<String> username,
    required Option<String> password,
    required this.from,
    required this.fromName,
    required this.storefrontBaseUri,
    required Duration timeout,
  })  : _timeout = timeout,
        _server = SmtpServer(
          host,
          port: port,
          ssl: ssl,
          allowInsecure: false,
          ignoreBadCertificate: false,
          username: nullableOf(username),
          password: nullableOf(password),
        );

  /// Envelope and message sender address.
  final String from;

  /// Sender name visible to the customer.
  final String fromName;

  /// Public storefront origin used to build the confirmation route.
  final Uri storefrontBaseUri;

  final SmtpServer _server;
  final Duration _timeout;

  @override
  bool get isAvailable => true;

  @override
  Future<void> send(EmailVerificationMail mail) async {
    final link = _verificationUri(mail.token);
    final text = '''
Verify your Morrow email address: $link

This link expires at ${mail.expiresAt.toUtc().toIso8601String()}.
If you did not create this account, ignore this email.
''';
    final safeLink =
        const HtmlEscape(HtmlEscapeMode.attribute).convert(link.toString());
    final message = mailer.Message()
      ..validator = const mailer.PracticalAddressValidator()
      ..from = mailer.Address(from, fromName)
      ..recipients.add(mailer.Address(mail.recipient))
      ..subject = 'Verify your Morrow email'
      ..text = text
      ..html = '''
<p>Verify your Morrow email address.</p>
<p><a href="$safeLink">Verify email</a></p>
<p>This link expires at ${mail.expiresAt.toUtc().toIso8601String()}.</p>
<p>If you did not create this account, ignore this email.</p>
''';
    await mailer.send(message, _server, timeout: _timeout);
  }

  Uri _verificationUri(String token) => storefrontBaseUri.replace(
        pathSegments: [
          ...storefrontBaseUri.pathSegments
              .where((segment) => segment.isNotEmpty),
          'verify-account',
        ],
        queryParameters: {'token': token},
        fragment: null,
      );
}

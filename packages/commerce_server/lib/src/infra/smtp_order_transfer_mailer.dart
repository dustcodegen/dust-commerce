import 'dart:convert';

import 'package:commerce_server/src/features/order_transfer/mail.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/fp.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart';

/// Sends order-transfer capabilities through a TLS-enforcing SMTP connection.
final class SmtpOrderTransferMailer implements OrderTransferMailer {
  /// Creates the server-only SMTP adapter.
  SmtpOrderTransferMailer({
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

  /// Customer-facing sender name.
  final String fromName;

  /// Public storefront origin used to build the capability route.
  final Uri storefrontBaseUri;

  final SmtpServer _server;
  final Duration _timeout;

  @override
  bool get isAvailable => true;

  @override
  Future<void> send(OrderTransferMail mail) async {
    final link = _decisionUri(mail.orderId, mail.token);
    final headerOrder = mail.orderId.replaceAll(RegExp(r'[\r\n\x00]'), '');
    final text = '''
Someone asked to connect order ${mail.orderId} to their Morrow account.

Review the request: $link

This link expires at ${mail.expiresAt.toUtc().toIso8601String()}.
If you did not expect this request, decline it or ignore this email.
''';
    final safeOrder = const HtmlEscape().convert(mail.orderId);
    final safeLink =
        const HtmlEscape(HtmlEscapeMode.attribute).convert(link.toString());
    final message = mailer.Message()
      ..validator = const mailer.PracticalAddressValidator()
      ..from = mailer.Address(from, fromName)
      ..recipients.add(mailer.Address(mail.recipient))
      ..subject = 'Review the transfer of order $headerOrder'
      ..text = text
      ..html = '''
<p>Someone asked to connect order <strong>$safeOrder</strong> to their Morrow account.</p>
<p><a href="$safeLink">Review the transfer request</a></p>
<p>This link expires at ${mail.expiresAt.toUtc().toIso8601String()}.</p>
<p>If you did not expect this request, decline it or ignore this email.</p>
''';
    await mailer.send(message, _server, timeout: _timeout);
  }

  Uri _decisionUri(String orderId, String token) => storefrontBaseUri.replace(
        pathSegments: [
          ...storefrontBaseUri.pathSegments
              .where((segment) => segment.isNotEmpty),
          'order',
          orderId,
          'transfer',
          token,
        ],
        query: null,
        fragment: null,
      );
}

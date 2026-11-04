import 'package:commerce_server/src/features/account/mail.dart';
import 'package:commerce_server/src/features/order_transfer/mail.dart';
import 'package:commerce_server/src/infra/smtp_email_verification_mailer.dart';
import 'package:commerce_server/src/infra/smtp_order_transfer_mailer.dart';
import 'package:dust_dart/fp.dart';
import 'package:mailer/mailer.dart';

part 'mail_config_parsing.dart';

/// Validated server-only SMTP settings shared by transactional email.
final class OrderTransferMailConfig {
  /// Creates already-validated SMTP settings.
  const OrderTransferMailConfig({
    required this.host,
    required this.port,
    required this.ssl,
    required this.username,
    required this.password,
    required this.from,
    required this.fromName,
    required this.storefrontBaseUri,
    required this.timeout,
  });

  /// Parses optional settings without representing absence as `null`.
  static Option<OrderTransferMailConfig> optionFromEnvironment(
    Map<String, String> environment,
  ) {
    if (!_keys.any(environment.containsKey)) {
      return const None<OrderTransferMailConfig>();
    }
    final host = _required(environment, 'COMMERCE_SMTP_HOST');
    final from = _required(environment, 'COMMERCE_SMTP_FROM');
    final storefrontText = _required(
      environment,
      'COMMERCE_STOREFRONT_URL',
    );
    final storefront = Uri.tryParse(storefrontText);
    if (storefront == null ||
        !storefront.isAbsolute ||
        !const {'http', 'https'}.contains(storefront.scheme) ||
        storefront.host.isEmpty ||
        storefront.hasQuery ||
        storefront.hasFragment) {
      throw const FormatException(
        'COMMERCE_STOREFRONT_URL must be an absolute HTTP(S) URL without a query or fragment.',
      );
    }
    if (!const PracticalAddressValidator().validate(Address(from))) {
      throw const FormatException(
          'COMMERCE_SMTP_FROM is not a deliverable email address.');
    }

    final username = _optional(environment, 'COMMERCE_SMTP_USERNAME');
    final password = _optionalRaw(environment, 'COMMERCE_SMTP_PASSWORD');
    if (username.isSome != password.isSome) {
      throw const FormatException(
        'COMMERCE_SMTP_USERNAME and COMMERCE_SMTP_PASSWORD must be set together.',
      );
    }

    return Some(OrderTransferMailConfig(
      host: host,
      port: _integer(environment, 'COMMERCE_SMTP_PORT', 587, 1, 65535),
      ssl: _boolean(environment, 'COMMERCE_SMTP_SSL', false),
      username: username,
      password: password,
      from: from,
      fromName:
          _optional(environment, 'COMMERCE_SMTP_FROM_NAME').unwrapOr('Morrow'),
      storefrontBaseUri: storefront,
      timeout: Duration(
        seconds: _integer(
          environment,
          'COMMERCE_SMTP_TIMEOUT_SECONDS',
          15,
          1,
          60,
        ),
      ),
    ));
  }

  /// Builds the outbound adapter without exposing credentials to the app.
  OrderTransferMailer build() => SmtpOrderTransferMailer(
        host: host,
        port: port,
        ssl: ssl,
        username: username,
        password: password,
        from: from,
        fromName: fromName,
        storefrontBaseUri: storefrontBaseUri,
        timeout: timeout,
      );

  /// Builds customer verification delivery from the same SMTP boundary.
  EmailVerificationMailer buildEmailVerification() =>
      SmtpEmailVerificationMailer(
        host: host,
        port: port,
        ssl: ssl,
        username: username,
        password: password,
        from: from,
        fromName: fromName,
        storefrontBaseUri: storefrontBaseUri,
        timeout: timeout,
      );

  /// Sender address.
  final String from;

  /// Sender display name.
  final String fromName;

  /// SMTP host without a URL scheme.
  final String host;

  /// SMTP password kept only in process memory.
  final Option<String> password;

  /// SMTP TCP port.
  final int port;

  /// Whether the connection starts with implicit TLS instead of STARTTLS.
  final bool ssl;

  /// Public Flutter storefront base URL.
  final Uri storefrontBaseUri;

  /// Network deadline for one SMTP transaction.
  final Duration timeout;

  /// SMTP username, absent for an unauthenticated relay.
  final Option<String> username;

  static const _keys = <String>{
    'COMMERCE_SMTP_HOST',
    'COMMERCE_SMTP_PORT',
    'COMMERCE_SMTP_SSL',
    'COMMERCE_SMTP_USERNAME',
    'COMMERCE_SMTP_PASSWORD',
    'COMMERCE_SMTP_FROM',
    'COMMERCE_SMTP_FROM_NAME',
    'COMMERCE_SMTP_TIMEOUT_SECONDS',
    'COMMERCE_STOREFRONT_URL',
  };
}

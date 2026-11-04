import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  test('email remains disabled when no related setting exists', () {
    expect(
      OrderTransferMailConfig.optionFromEnvironment(const {}),
      const None<OrderTransferMailConfig>(),
    );
  });

  test('complete settings build a TLS-enforcing mail adapter', () {
    final parsed = OrderTransferMailConfig.optionFromEnvironment({
      'COMMERCE_SMTP_HOST': 'smtp.example.com',
      'COMMERCE_SMTP_PORT': '465',
      'COMMERCE_SMTP_SSL': 'true',
      'COMMERCE_SMTP_USERNAME': 'mailer@example.com',
      'COMMERCE_SMTP_PASSWORD': ' secret with spaces ',
      'COMMERCE_SMTP_FROM': 'orders@example.com',
      'COMMERCE_SMTP_FROM_NAME': 'Morrow Orders',
      'COMMERCE_SMTP_TIMEOUT_SECONDS': '20',
      'COMMERCE_STOREFRONT_URL': 'https://shop.example.com/base/',
    });

    expect(parsed, isA<Some<OrderTransferMailConfig>>());
    final config = (parsed as Some<OrderTransferMailConfig>).value;
    expect(config.host, 'smtp.example.com');
    expect(config.port, 465);
    expect(config.ssl, isTrue);
    expect(config.username, const Some('mailer@example.com'));
    expect(config.password, const Some(' secret with spaces '));
    expect(config.timeout, const Duration(seconds: 20));
    expect(config.buildEmailVerification(), isA<SmtpEmailVerificationMailer>());
    expect(config.build(), isA<SmtpOrderTransferMailer>());
  });

  test('partial configuration fails at process startup', () {
    expect(
      () => OrderTransferMailConfig.optionFromEnvironment({
        'COMMERCE_SMTP_HOST': 'smtp.example.com',
      }),
      throwsFormatException,
    );
  });

  test('credentials must be supplied as a pair', () {
    expect(
      () => OrderTransferMailConfig.optionFromEnvironment({
        'COMMERCE_SMTP_HOST': 'smtp.example.com',
        'COMMERCE_SMTP_USERNAME': 'mailer@example.com',
        'COMMERCE_SMTP_FROM': 'orders@example.com',
        'COMMERCE_STOREFRONT_URL': 'https://shop.example.com',
      }),
      throwsFormatException,
    );
  });

  test('invalid transport and public URL values fail fast', () {
    Map<String, String> settings() => {
          'COMMERCE_SMTP_HOST': 'smtp.example.com',
          'COMMERCE_SMTP_FROM': 'orders@example.com',
          'COMMERCE_STOREFRONT_URL': 'https://shop.example.com',
        };

    expect(
      () => OrderTransferMailConfig.optionFromEnvironment(
        settings()..['COMMERCE_SMTP_PORT'] = '0',
      ),
      throwsFormatException,
    );
    expect(
      () => OrderTransferMailConfig.optionFromEnvironment(
        settings()..['COMMERCE_SMTP_SSL'] = 'yes',
      ),
      throwsFormatException,
    );
    expect(
      () => OrderTransferMailConfig.optionFromEnvironment(
        settings()..['COMMERCE_STOREFRONT_URL'] = '/relative',
      ),
      throwsFormatException,
    );
    expect(
      () => OrderTransferMailConfig.optionFromEnvironment(
        settings()..['COMMERCE_SMTP_FROM_NAME'] = 'Morrow\r\nBcc: attacker',
      ),
      throwsFormatException,
    );
  });
}

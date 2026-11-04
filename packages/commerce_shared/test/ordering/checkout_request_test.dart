import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  AddressInput addressInput({
    String firstName = 'Ada',
    String line1 = '12 Analytical Way',
    String postalCode = '10115',
    String countryCode = 'de',
    String? company,
    String? line2,
  }) =>
      AddressInput(
        firstName: firstName,
        lastName: 'Lovelace',
        company: company,
        line1: line1,
        line2: line2,
        city: 'Berlin',
        postalCode: postalCode,
        countryCode: countryCode,
      );

  CheckoutRequest request({
    String email = 'ada@example.com',
    String cartId = 'cart_1',
    AddressInput? shipping,
  }) =>
      CheckoutRequest(
        cartId: cartId,
        email: email,
        shippingAddress: shipping ?? addressInput(),
      );

  group('CheckoutRequest validation', () {
    test('accepts a complete request', () {
      expect(request().validate().isValid, isTrue);
    });

    test('rejects an address that is not an email', () {
      final result = request(email: 'ada-at-example').validate();

      expect(result.isValid, isFalse);
      expect(result.errors.map((error) => error.field), contains('email'));
    });

    test('rejects an empty email', () {
      expect(request(email: '').validate().isValid, isFalse);
    });

    test('rejects an empty cart id', () {
      expect(request(cartId: '').validate().isValid, isFalse);
    });
  });

  group('AddressInput validation', () {
    test('accepts a complete address', () {
      expect(addressInput().validate().isValid, isTrue);
    });

    test('rejects a missing recipient name', () {
      expect(addressInput(firstName: '').validate().isValid, isFalse);
    });

    test('rejects a missing street', () {
      expect(addressInput(line1: '').validate().isValid, isFalse);
    });

    test('rejects a country code that is not two letters', () {
      expect(addressInput(countryCode: 'deu').validate().isValid, isFalse);
      expect(addressInput(countryCode: '').validate().isValid, isFalse);
    });

    test('names every field that failed, not just the first', () {
      final result = addressInput(firstName: '', line1: '').validate();
      final fields = result.errors.map((error) => error.field).toSet();

      expect(fields, containsAll(<String>['firstName', 'line1']));
    });
  });

  group('conversion', () {
    test('becomes an Address once valid', () {
      final address = addressInput(
        countryCode: 'DE',
        company: 'Analytical Engines',
        line2: 'Suite 2',
      ).toAddress();

      expect(address.countryCode, 'de');
      expect(address.fullName, 'Ada Lovelace');
      expect(address.company, 'Analytical Engines');
      expect(address.line2, 'Suite 2');
    });
  });

  group('json', () {
    test('round-trips through the generated codec', () {
      expect(CheckoutRequest.fromJson(request().toJson()), request());
    });

    test('carries snake_case keys, as the API speaks', () {
      expect(request().toJson().containsKey('cart_id'), isTrue);
      expect(request().toJson().containsKey('shipping_address'), isTrue);
    });

    test('normalizes transport whitespace before validation and conversion',
        () {
      final decoded = CheckoutRequest.fromJson({
        'cart_id': 'cart_1',
        'email': '  ada@example.com  ',
        'shipping_address': {
          ...addressInput(countryCode: ' US ').toJson(),
          'company': '   ',
          'line2': '  Suite 2  ',
        },
      });

      expect(decoded.validate().isValid, isTrue);
      expect(decoded.email, 'ada@example.com');
      expect(decoded.shippingAddress.toAddress().countryCode, 'us');
      expect(decoded.shippingAddress.toAddress().company, isNull);
      expect(decoded.shippingAddress.toAddress().line2, 'Suite 2');
    });
  });
}

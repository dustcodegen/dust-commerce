import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:test/test.dart';

void main() {
  test('promotion creation normalizes code and currency', () {
    final input = AdminCreatePromotion.fromJson({
      'code': '  spring_10  ',
      'type': 'fixed',
      'value': 500,
      'currency_code': ' USD ',
      'usage_limit': 10,
      'starts_at': '2099-01-01T00:00:00Z',
      'ends_at': '2099-02-01T00:00:00Z',
    });

    expect(input.code, 'SPRING_10');
    expect(input.currencyCodeValue, 'usd');
    expect(input.startsAtValue!.isUtc, isTrue);
    expect(input.validate().isValid, isTrue);
    expect(input.toJson(), {
      'code': 'SPRING_10',
      'type': 'fixed',
      'value': 500,
      'currency_code': 'usd',
      'usage_limit': 10,
      'starts_at': '2099-01-01T00:00:00.000Z',
      'ends_at': '2099-02-01T00:00:00.000Z',
    });
  });

  test('promotion response keeps the explicit Admin allowlist', () {
    final response = AdminPromotionDetail.fromJson({
      'promotion': {
        'id': 'promo_spring',
        'code': 'SPRING_10',
        'type': 'percentage',
        'value': 1000,
        'is_automatic': false,
        'status': 'active',
        'currency_code': null,
        'starts_at': null,
        'ends_at': null,
        'usage_limit': null,
        'usage_count': 0,
        'created_at': '2026-11-06T04:00:00.000Z',
        'updated_at': '2026-11-06T04:00:00.000Z',
      },
    });

    expect(response.promotion.id, 'promo_spring');
    expect(response.promotion.currencyCode, isA<None<String>>());
    expect(response.toJson().keys, {'promotion'});
  });

  test('promotion input rejects invalid type and value', () {
    const input = AdminCreatePromotion(
      code: 'BAD',
      type: 'percentage',
      value: -1,
      currencyCodeValue: null,
      startsAtValue: null,
      endsAtValue: null,
      usageLimitValue: 0,
    );

    expect(input.validate().isValid, isFalse);
  });
}

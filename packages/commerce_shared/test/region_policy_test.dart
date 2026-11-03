import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

void main() {
  test('accepts complete Medusa policy metadata without floating money', () {
    final policy = StoreRegionPolicy.fromMetadata({
      'return_window_days': '30',
      'free_returns': 'false',
      'shipping_rate': 10.00,
      'handling_days_min': 0,
      'handling_days_max': 1,
      'transit_days_min': 2,
      'transit_days_max': 3,
    });

    expect(policy, isNotNull);
    expect(policy!.shippingRate, '10');
    expect(policy.returnWindowDays, 30);
    expect(policy.freeReturns, isFalse);
  });

  test('omits incomplete or inverted metadata', () {
    expect(
      StoreRegionPolicy.fromMetadata({
        'return_window_days': 30,
        'free_returns': true,
        'shipping_rate': 10,
        'handling_days_min': 2,
        'handling_days_max': 1,
        'transit_days_min': 2,
        'transit_days_max': 3,
      }),
      isNull,
    );
  });

  test('defaults an absent free-returns flag to false like Medusa', () {
    final policy = StoreRegionPolicy.fromMetadata({
      'return_window_days': 30,
      'shipping_rate': 10,
      'handling_days_min': 0,
      'handling_days_max': 1,
      'transit_days_min': 2,
      'transit_days_max': 3,
    });

    expect(policy, isNotNull);
    expect(policy!.freeReturns, isFalse);
  });
}

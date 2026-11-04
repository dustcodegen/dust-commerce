import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('completion matches the four fields in the Medusa source', () {
    final complete = AccountOverviewSummary.from(
      customer: _customer,
      addresses: const [_billingAddress],
      orders: const [],
    );
    final emailOnly = AccountOverviewSummary.from(
      customer: const Customer(id: 'cus_1', email: 'ada@example.com'),
      addresses: const [_nonBillingAddress],
      orders: const [],
    );

    expect(complete.profileCompletion, 100);
    expect(complete.addressCount, 1);
    expect(emailOnly.profileCompletion, 25);
  });

  test('recent orders preserves the newest-first server order and takes five',
      () {
    final orders = [for (var index = 0; index < 7; index++) _order(index)];

    final summary = AccountOverviewSummary.from(
      customer: _customer,
      addresses: const [],
      orders: orders,
    );

    expect(summary.recentOrders.map((order) => order.id), [
      'order_0',
      'order_1',
      'order_2',
      'order_3',
      'order_4',
    ]);
    expect(() => summary.recentOrders.add(_order(8)), throwsUnsupportedError);
  });
}

const _customer = Customer(
  id: 'cus_1',
  email: 'ada@example.com',
  firstName: 'Ada',
  lastName: 'Lovelace',
  phone: '+1 555 0101',
);

const _billingAddress = CustomerAddressView(
  id: 'addr_billing',
  firstName: 'Ada',
  lastName: 'Lovelace',
  line1: '12 Analytical Way',
  city: 'Washington',
  postalCode: '20001',
  countryCode: 'us',
  isDefaultShipping: false,
  isDefaultBilling: true,
);

const _nonBillingAddress = CustomerAddressView(
  id: 'addr_shipping',
  firstName: 'Ada',
  lastName: 'Lovelace',
  line1: '12 Analytical Way',
  city: 'Washington',
  postalCode: '20001',
  countryCode: 'us',
  isDefaultShipping: true,
  isDefaultBilling: false,
);

Order _order(int index) => Order(
      id: 'order_$index',
      displayId: index + 1,
      email: 'ada@example.com',
      customerId: 'cus_1',
      region: _region,
      items: const [],
      subtotal: _zero,
      shippingTotal: _zero,
      discountTotal: _zero,
      tax: _zero,
      total: _zero,
      shippingAddress: _address,
      billingAddress: _address,
      placedAt: DateTime.utc(2026, 9, 6).subtract(Duration(days: index)),
    );

const _zero = Money(amount: 0, currencyCode: 'usd');
const _region = Region(
  id: 'reg_us',
  name: 'United States',
  currencyCode: 'usd',
  taxRate: 0,
  countries: ['us'],
);
const _address = Address(
  firstName: 'Ada',
  lastName: 'Lovelace',
  line1: '12 Analytical Way',
  city: 'Washington',
  postalCode: '20001',
  countryCode: 'us',
);

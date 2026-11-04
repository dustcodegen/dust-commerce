import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('loads one customer-owned frozen order', () async {
    final model = AccountOrderDetailViewModel(
      AccountOrderDetailViewModelArgs(api: _OrderApi((_) async => _order)),
    );

    await model.load(_order.id);

    expect(model.state.status, AccountOrderDetailStatus.ready);
    expect(model.state.order, Some(_order));
    expect(model.state.failure, const None<AccountOrderDetailFailure>());
    model.dispose();
  });

  test('reset ignores an in-flight response from a previous identity',
      () async {
    final deferred = Completer<Order>();
    final model = AccountOrderDetailViewModel(
      AccountOrderDetailViewModelArgs(api: _OrderApi((_) => deferred.future)),
    );

    final loading = model.load(_order.id);
    model.reset();
    deferred.complete(_order);
    await loading;

    expect(model.state, const AccountOrderDetailState());
    model.dispose();
  });

  test('an unowned or missing order becomes the same unavailable state',
      () async {
    final error = DioException(
      requestOptions: RequestOptions(path: '/store/orders/order_other'),
      response: Response<void>(
        requestOptions: RequestOptions(path: '/store/orders/order_other'),
        statusCode: 404,
      ),
    );
    final model = AccountOrderDetailViewModel(
      AccountOrderDetailViewModelArgs(
        api: _OrderApi((_) => Future<Order>.error(error)),
      ),
    );

    await model.load('order_other');

    expect(model.state.status, AccountOrderDetailStatus.failed);
    expect(
      model.state.failure,
      const Some(AccountOrderDetailFailure.unavailable),
    );
    expect(model.state.order, const None<Order>());
    model.dispose();
  });
}

final class _OrderApi implements CommerceApi {
  const _OrderApi(this.load);

  final Future<Order> Function(String id) load;

  @override
  Future<Order> order(String id) => load(id);

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unused API method');
}

final _order = Order(
  id: 'order_1',
  displayId: 1,
  email: 'ada@example.com',
  customerId: 'cus_ada',
  region: const Region(
    id: 'reg_us',
    name: 'United States',
    currencyCode: 'usd',
    taxRate: 0,
    countries: ['us'],
  ),
  items: const [
    OrderLineItem(
      id: 'item_1',
      variantId: 'var_1',
      productId: 'prod_1',
      productHandle: 'shirt',
      title: 'Shirt',
      variantTitle: 'Small',
      unitPrice: Money(amount: 2000, currencyCode: 'usd'),
      quantity: 1,
      detail: OrderLineItemDetail(
        deliveredQuantity: 0,
        returnRequestedQuantity: 0,
        returnReceivedQuantity: 0,
        returnDismissedQuantity: 0,
      ),
    ),
  ],
  subtotal: const Money(amount: 2000, currencyCode: 'usd'),
  shippingTotal: const Money(amount: 0, currencyCode: 'usd'),
  discountTotal: const Money(amount: 0, currencyCode: 'usd'),
  tax: const Money(amount: 0, currencyCode: 'usd'),
  total: const Money(amount: 2000, currencyCode: 'usd'),
  shippingAddress: const Address(
    firstName: 'Ada',
    lastName: 'Lovelace',
    line1: '12 Analytical Way',
    city: 'Washington',
    postalCode: '20001',
    countryCode: 'us',
  ),
  billingAddress: const Address(
    firstName: 'Ada',
    lastName: 'Lovelace',
    line1: '12 Analytical Way',
    city: 'Washington',
    postalCode: '20001',
    countryCode: 'us',
  ),
  placedAt: DateTime.utc(2026, 9, 5, 12),
);

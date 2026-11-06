import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late CommerceApi api;
  var counter = 0;

  setUp(() async {
    counter = 0;
    directory = await Directory.systemTemp.createTemp('commerce_checkout');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedRoundTripCatalog(database);
    server = await TestClient.serve(
      buildApp(
        database,
        nextId: () => 'id_${++counter}',
        now: () => DateTime.utc(2100, 1, 1, 12),
      ),
    );
    api = CommerceApi(Dio(), baseUrl: server.origin);
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('places an order the client decodes as the shared Order', () async {
    final cart = await api.createCart(const CreateCartBody());
    await api.addLine(
      cart.cart.id,
      const AddLineBody(variantId: 'var_small', quantity: 2),
    );
    await api.chooseShipping(
      cart.cart.id,
      const ChooseShippingBody(optionId: 'ship_standard'),
    );
    await api.choosePayment(
      cart.cart.id,
      const ChoosePaymentBody(providerId: 'manual'),
    );

    final order = await api.checkout(_request(cart.cart.id));

    expect(order, isA<Order>());
    expect(order.total, Money.of(4398, 'usd'));
    expect(order.status, OrderStatus.pending);
    expect(order.paymentStatus, PaymentStatus.awaiting);
    expect(order.isPaid, isFalse);
    expect(order.shippingAddress.fullName, 'Ada Lovelace');
    expect(order.billingAddress, order.shippingAddress);
  });

  test('reads and lists only the authenticated customer order', () async {
    final dio = Dio()
      ..options.headers['authorization'] =
          'Bearer ${await server.customerToken()}';
    final customerApi = CommerceApi(dio, baseUrl: server.origin);
    final cart = await customerApi.createCart(const CreateCartBody());
    await customerApi.addLine(
      cart.cart.id,
      const AddLineBody(variantId: 'var_small'),
    );
    await customerApi.chooseShipping(
      cart.cart.id,
      const ChooseShippingBody(optionId: 'ship_standard'),
    );
    await customerApi.choosePayment(
      cart.cart.id,
      const ChoosePaymentBody(providerId: 'manual'),
    );
    final placed = await customerApi.checkout(_request(cart.cart.id));

    final fetched = await customerApi.order(placed.id);
    expect(fetched.id, placed.id);
    expect(fetched.total, placed.total);

    final history = await customerApi.orders();
    expect(history.count, 1);
    expect(history.orders.single.id, placed.id);
  });
}

CheckoutRequest _request(String cartId) => CheckoutRequest(
      cartId: cartId,
      email: 'ada@example.com',
      shippingAddress: const AddressInput(
        firstName: 'Ada',
        lastName: 'Lovelace',
        line1: '12 Analytical Way',
        city: 'London',
        postalCode: 'EC1A',
        countryCode: 'us',
      ),
    );

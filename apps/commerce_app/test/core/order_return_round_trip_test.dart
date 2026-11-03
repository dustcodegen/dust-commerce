import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('generated client requests a return for an owned paid order', () async {
    final directory = await Directory.systemTemp.createTemp('return_client');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedRoundTripCatalog(database);
    final server = await TestClient.serve(buildApp(database));
    final sessions = MemoryAuthSessionStore();
    final dio = Dio()
      ..interceptors.add(AuthorizationInterceptor(sessions: sessions));
    final api = CommerceApi(dio, baseUrl: server.origin);
    final historyApi = OrderReturnHistoryApi(dio, baseUrl: server.origin);
    addTearDown(() async {
      await server.close();
      await database.close();
      await directory.delete(recursive: true);
    });

    await api.registerAccount(const RegisterAccountBody(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
      firstName: 'Order',
      lastName: 'Owner',
    ));
    await sessions.write(await api.signIn(const Credentials(
      email: 'owner@example.com',
      password: 'correct horse battery staple',
    )));
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
    final placed = await api.checkout(CheckoutRequest(
      cartId: cart.cart.id,
      email: 'owner@example.com',
      shippingAddress: const AddressInput(
        firstName: 'Order',
        lastName: 'Owner',
        line1: '12 Analytical Way',
        city: 'London',
        postalCode: 'EC1A',
        countryCode: 'us',
      ),
    ));
    await api.authorizePayment(placed.id);
    final paid = await api.capturePayment(placed.id);
    await queryExecute(
      "INSERT INTO fulfillments "
      "(id, order_id, location_id, provider_id, delivered_at) "
      "VALUES ('ful_client', ?, 'location_test', 'manual', "
      "strftime('%Y-%m-%dT%H:%M:%fZ', 'now'))",
      [paid.id],
    ).execute(database.executor);
    await queryExecute(
      "INSERT INTO fulfillment_items "
      "(id, fulfillment_id, title, quantity, sku, barcode, line_item_id) "
      "VALUES ('fulitem_client', 'ful_client', ?, 2, '', '', ?)",
      [paid.items.single.title, paid.items.single.id],
    ).execute(database.executor);

    final returned = await api.requestOrderReturn(OrderReturnRequestBody(
      orderId: paid.id,
      items: [
        OrderReturnItemInput(itemId: paid.items.single.id, quantity: 1),
      ],
      noteValue: 'The item does not fit',
    ));

    expect(returned.orderId, paid.id);
    expect(returned.status, OrderReturnStatus.requested);
    expect(returned.itemQuantity, 1);
    expect(returned.requestedAt.isUtc, isTrue);

    final history = await historyApi.returns(paid.id);
    expect(history.count, 1);
    expect(history.returns.single, returned);
  });
}

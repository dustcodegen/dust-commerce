import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support.dart';

void main() {
  test('generated client requests and accepts an order transfer', () async {
    final directory = await Directory.systemTemp.createTemp('transfer_client');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedRoundTripCatalog(database);
    final mailer = _RecordingMailer();
    var id = 0;
    final server = await TestClient.serve(buildApp(
      database,
      nextId: () => 'id_${++id}',
      now: () => DateTime.utc(2100, 1, 1, 12),
      orderTransferMailer: mailer,
    ));
    final sessions = MemoryAuthSessionStore();
    final dio = Dio()
      ..interceptors.add(AuthorizationInterceptor(sessions: sessions));
    final api = CommerceApi(dio, baseUrl: server.origin);
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
    await api.addLine(cart.cart.id, const AddLineBody(variantId: 'var_small'));
    await api.chooseShipping(
      cart.cart.id,
      const ChooseShippingBody(optionId: 'ship_standard'),
    );
    await api.choosePayment(
      cart.cart.id,
      const ChoosePaymentBody(providerId: 'manual'),
    );
    final order = await api.checkout(CheckoutRequest(
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

    final target = await api.registerAccount(const RegisterAccountBody(
      email: 'target@example.com',
      password: 'correct horse battery staple',
      firstName: 'Target',
      lastName: 'Customer',
    ));
    await sessions.write(await api.signIn(const Credentials(
      email: 'target@example.com',
      password: 'correct horse battery staple',
    )));

    final requested = await api.requestOrderTransfer(order.id);
    final delivered = (mailer.last as Some<OrderTransferMail>).value;
    final accepted = await api.acceptOrderTransfer(
      order.id,
      OrderTransferDecisionBody(token: delivered.token),
    );

    expect(requested.orderId, order.id);
    expect(requested.status, OrderTransferStatus.requested);
    expect(requested.deliveryStatus, OrderTransferDeliveryStatus.sent);
    expect(requested.expiresAt, DateTime.utc(2100, 1, 2, 12));
    expect(delivered.recipient, 'owner@example.com');
    expect(accepted.status, OrderTransferStatus.accepted);
    expect((await api.order(order.id)).customerId, target.customer.id);
  });
}

final class _RecordingMailer implements OrderTransferMailer {
  Option<OrderTransferMail> last = const None();

  @override
  bool get isAvailable => true;

  @override
  Future<void> send(OrderTransferMail mail) async => last = Some(mail);
}

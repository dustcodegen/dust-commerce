import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late CommerceApi api;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('payment_round_trip');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seed(database);
    server = await TestClient.serve(buildApp(database));
    api = CommerceApi(Dio(), baseUrl: server.origin);
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('retries checkout and manual payment without duplicate work', () async {
    final cart = await api.createCart(const CreateCartBody());
    await api.addLine(
      cart.cart.id,
      const AddLineBody(variantId: 'var_small'),
    );
    await api.chooseShipping(
      cart.cart.id,
      const ChooseShippingBody(optionId: 'ship_standard'),
    );
    await api.choosePayment(
      cart.cart.id,
      const ChoosePaymentBody(providerId: 'manual'),
    );
    final request = CheckoutRequest(
      cartId: cart.cart.id,
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

    final placed = await api.checkout(request);
    expect((await api.checkout(request)).id, placed.id);

    await api.authorizePayment(placed.id, guestEmail: placed.email);
    await api.authorizePayment(placed.id, guestEmail: placed.email);
    final paid = await api.capturePayment(
      placed.id,
      guestEmail: placed.email,
    );
    final retried = await api.capturePayment(
      placed.id,
      guestEmail: placed.email,
    );

    expect(paid.paymentStatus, PaymentStatus.captured);
    expect(retried.id, placed.id);
    expect(retried.paymentStatus, PaymentStatus.captured);
    expect(retried.status, OrderStatus.pending);
  });
}

Future<void> _seed(CommerceDatabase database) async {
  Future<void> run(String sql) =>
      queryExecute(sql, []).execute(database.executor);

  await run(
    r"INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
    r"VALUES ('reg_us', 'United States', 'usd', 1000, 'us')",
  );
  await run(
    r"INSERT INTO region_payment_providers (region_id, provider_id) "
    r"VALUES ('reg_us', 'manual')",
  );
  await run(
    r"INSERT INTO shipping_options (id, region_id, name, amount, currency_code) "
    r"VALUES ('ship_standard', 'reg_us', 'Standard', 0, 'usd')",
  );
  await run(
    r"INSERT INTO products (id, title, handle, status) "
    r"VALUES ('prod_shirt', 'T-Shirt', 't-shirt', 'published')",
  );
  await run(
    r"INSERT INTO product_variants "
    r"(id, product_id, title, inventory_quantity) "
    r"VALUES ('var_small', 'prod_shirt', 'Small', 50)",
  );
  await run(
    r"INSERT INTO variant_prices (variant_id, currency_code, amount) "
    r"VALUES ('var_small', 'usd', 1999)",
  );
}

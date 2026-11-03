import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late CommerceApi api;
  late MemoryAuthSessionStore sessions;
  late MemoryCartIdStore storage;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('cart_view_model');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    server = await TestClient.serve(buildApp(database));
    sessions = MemoryAuthSessionStore();
    final dio = Dio()
      ..interceptors.add(AuthorizationInterceptor(sessions: sessions));
    api = CommerceApi(dio, baseUrl: server.origin);
    storage = MemoryCartIdStore();
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  CartViewModel model({String scope = 'guest', Region? region}) =>
      CartViewModel(
        CartViewModelArgs(
          api: api,
          cartIds: storage,
          selectedRegion: () => Some(region ?? _usRegion),
          storageScope: scope,
        ),
      );

  Future<ProductVariant> variant() async =>
      (await api.product('t-shirt')).variantById('var_tshirt_m_white')!;

  Future<void> signInCustomer() async {
    await api.registerAccount(const RegisterAccountBody(
      email: 'ada@example.com',
      password: 'correct horse battery staple',
      firstName: 'Ada',
      lastName: 'Lovelace',
    ));
    await sessions.write(await api.signIn(const Credentials(
      email: 'ada@example.com',
      password: 'correct horse battery staple',
    )));
  }

  test('persists and restores the opaque cart capability', () async {
    final first = model();
    await first.restore();
    expect(await first.add(await variant()), isTrue);
    final id = first.state.cart!.cart.id;
    expect(storage.values['guest'], id);
    expect(first.state.cart!.cart.items.single.title, 'Essential T-Shirt');
    expect(first.state.cart!.cart.items.single.productHandle, 't-shirt');

    final restarted = model();
    await restarted.restore();

    expect(restarted.state.status, CartStatus.ready);
    expect(restarted.state.cart?.cart.id, id);
    expect(restarted.state.itemCount, 1);
  });

  test('forgets a stale capability after the server returns 404', () async {
    storage.values['guest'] = 'missing';
    final restarted = model();

    await restarted.restore();

    expect(restarted.state.status, CartStatus.ready);
    expect(restarted.state.cart, isNull);
    expect(storage.values, isNot(contains('guest')));
  });

  test('a failed restore can be retried', () async {
    storage.readError = StateError('secure storage temporarily unavailable');
    final restarted = model();

    await restarted.restore();
    expect(restarted.state.status, CartStatus.failed);

    await restarted.restore();
    expect(restarted.state.status, CartStatus.ready);
  });

  test('quantity and removal always take totals from server responses',
      () async {
    final cart = model();
    await cart.restore();
    await cart.add(await variant());
    final line = cart.state.cart!.cart.items.single;

    expect(await cart.updateQuantity(line.id, 3), isTrue);
    expect(cart.state.itemCount, 3);
    expect(cart.state.cart!.subtotal.amount, line.unitPrice.amount * 3);

    expect(await cart.remove(line.id), isTrue);
    expect(cart.state.itemCount, 0);
    expect(cart.state.cart!.total, Money.zero('usd'));
  });

  test('promotion and shipping mutations retain authoritative totals',
      () async {
    final cart = model();
    await cart.restore();
    await cart.add(await variant());

    expect(cart.state.shippingOptions, hasLength(3));
    expect(await cart.loadShippingOptions(), isTrue);
    expect(cart.state.shippingOptions, hasLength(3));
    expect(await cart.chooseShipping('ship_standard'), isTrue);
    expect(cart.state.cart!.shippingTotal, Money.of(500, 'usd'));
    expect(await cart.choosePayment('manual'), isTrue);
    expect(
      cart.state.cart!.cart.paymentSession,
      const CartPaymentSession(providerId: 'manual'),
    );

    expect(await cart.applyPromotion('welcome10'), isTrue);
    expect(cart.state.cart!.cart.promotions.single.code, 'WELCOME10');
    expect(cart.state.cart!.cart.promotions.single.value, 1000);
    expect(cart.state.cart!.discountTotal.amount, greaterThan(0));
    expect(await cart.removePromotion(), isTrue);
    expect(cart.state.cart!.cart.promotions, isEmpty);
    expect(cart.state.cart!.discountTotal, Money.zero('usd'));
  });

  test('storage scopes never overwrite one another', () async {
    final guest = model();
    final customer = model(scope: 'customer_1');
    await guest.restore();
    await customer.restore();
    await guest.add(await variant());
    await customer.add(await variant());

    expect(storage.values['guest'], isNot(storage.values['customer_1']));
  });

  test('claims the guest cart after authentication', () async {
    final cart = model();
    await cart.restore();
    await cart.add(await variant());
    final cartId = cart.state.cart!.cart.id;
    await signInCustomer();

    expect(
      await Future.wait([
        cart.transferToCustomer(),
        cart.transferToCustomer(),
      ]),
      [true, true],
    );

    expect(cart.state.status, CartStatus.ready);
    expect(cart.state.cart!.cart.id, cartId);
    expect(cart.state.cart!.cart.customerId, isNotNull);
    expect(cart.state.cart!.cart.email, 'ada@example.com');
    expect(cart.state.transferFailure, const None<CartTransferFailure>());
  });

  test('keeps the guest cart recoverable when transfer is unauthorized',
      () async {
    final cart = model();
    await cart.restore();
    await cart.add(await variant());
    final cartId = cart.state.cart!.cart.id;

    expect(await cart.transferToCustomer(), isFalse);

    expect(cart.state.cart!.cart.id, cartId);
    expect(storage.values['guest'], cartId);
    expect(
      cart.state.transferFailure,
      const Some(CartTransferFailure.unauthorized),
    );
  });

  test('sign-out forgets the customer cart on this device', () async {
    final cart = model();
    await cart.restore();
    await cart.add(await variant());

    await cart.clearForSignOut();

    expect(cart.state.status, CartStatus.ready);
    expect(cart.state.cart, isNull);
    expect(storage.values, isNot(contains('guest')));
  });
}

const _usRegion = Region(
  id: 'reg_us',
  name: 'United States',
  currencyCode: 'usd',
  taxRate: 1000,
  countries: ['us'],
);

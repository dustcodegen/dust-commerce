import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';

import '../core/support.dart';

final class CheckoutTestContext {
  CheckoutTestContext._(
    this.directory,
    this.database,
    this.server,
    this.api,
    this.cartIds,
    this.cart,
    this.receipts,
  );

  final Directory directory;
  final CommerceDatabase database;
  final TestClient server;
  final CommerceApi api;
  final MemoryCartIdStore cartIds;
  final CartViewModel cart;
  final MemoryReceiptStore receipts;

  static Future<CheckoutTestContext> start() async {
    final directory =
        await Directory.systemTemp.createTemp('checkout_view_model');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    await seedDevelopmentDemoCatalog(database);
    final server = await TestClient.serve(buildApp(database));
    final api = CommerceApi(Dio(), baseUrl: server.origin);
    final cartIds = MemoryCartIdStore();
    final cart = testCart(
      api,
      storage: cartIds,
      region: const Region(
        id: 'reg_us',
        name: 'United States',
        currencyCode: 'usd',
        taxRate: 0,
        countries: ['us'],
      ),
    );
    final receipts = MemoryReceiptStore();
    await cart.restore();
    final product = await api.product('t-shirt');
    await cart.add(product.variants.first);
    return CheckoutTestContext._(
      directory,
      database,
      server,
      api,
      cartIds,
      cart,
      receipts,
    );
  }

  Future<void> stop() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  }

  CheckoutViewModel checkout({CommerceApi? client, Customer? customer}) =>
      CheckoutViewModel(
        CheckoutViewModelArgs(
          api: client ?? api,
          cart: cart,
          receipts: receipts,
          currentCustomer: () => customer,
        ),
      );
}

Future<bool> saveTestAddress(CheckoutViewModel model) => model.saveAddresses(
      email: 'ada@example.com',
      shipping: const CheckoutAddressDraft(
        firstName: 'Ada',
        lastName: 'Lovelace',
        line1: '12 Analytical Way',
        city: 'London',
        postalCode: 'EC1A',
        countryCode: 'us',
      ),
      billing: const CheckoutAddressDraft(),
      sameAsBilling: true,
    );

final class MemoryReceiptStore implements OrderReceiptStore {
  Order? value;

  @override
  Future<Order?> read(String orderId) async =>
      value?.id == orderId ? value : null;

  @override
  Future<void> write(Order order) async => value = order;
}

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

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('cart_region_model');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    server = await TestClient.serve(buildApp(database));
    api = CommerceApi(Dio(), baseUrl: server.origin);
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('creates and reprices the cart in the selected selling region',
      () async {
    final cart = CartViewModel(CartViewModelArgs(
      api: api,
      cartIds: MemoryCartIdStore(),
      selectedRegion: () => const Some(_europeRegion),
    ));
    addTearDown(cart.dispose);

    await cart.restore();
    final variant =
        (await api.product('t-shirt')).variantById('var_tshirt_m_white')!;
    await cart.add(variant);

    expect(cart.state.cart!.cart.region.id, 'reg_eu');
    expect(cart.state.cart!.subtotal.currencyCode, 'eur');
    expect(await cart.changeRegion('reg_us'), isTrue);
    expect(cart.state.cart!.cart.region.id, 'reg_us');
    expect(cart.state.cart!.subtotal.currencyCode, 'usd');
    expect(cart.state.shippingOptions, hasLength(3));
  });

  test('restores an existing cart into the current shell region', () async {
    final storage = MemoryCartIdStore();
    final created = await api.createCart(
      const CreateCartBody(regionId: 'reg_us'),
    );
    await api.addLine(
      created.cart.id,
      const AddLineBody(variantId: 'var_tshirt_m_white'),
    );
    await storage.write('guest', created.cart.id);
    final cart = CartViewModel(CartViewModelArgs(
      api: api,
      cartIds: storage,
      selectedRegion: () => const Some(_europeRegion),
    ));
    addTearDown(cart.dispose);

    await cart.restore();

    expect(cart.state.status, CartStatus.ready);
    expect(cart.state.cart!.cart.region.id, 'reg_eu');
    expect(cart.state.cart!.cart.items.single.unitPrice.currencyCode, 'eur');
  });
}

const _europeRegion = Region(
  id: 'reg_eu',
  name: 'Europe',
  currencyCode: 'eur',
  taxRate: 0,
  countries: ['dk', 'de', 'gb', 'se', 'fr', 'es', 'it'],
);

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
  late MemoryCartIdStore storage;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('cart_resume');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    server = await TestClient.serve(buildApp(database));
    api = CommerceApi(Dio(), baseUrl: server.origin);
    storage = MemoryCartIdStore();
  });

  tearDown(() async {
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  CartViewModel model() => CartViewModel(
        CartViewModelArgs(
          api: api,
          cartIds: storage,
          selectedRegion: () => Some(_usRegion),
        ),
      );

  Future<ProductVariant> variant() async =>
      (await api.product('t-shirt')).variantById('var_tshirt_m_white')!;

  test('resumes an external cart capability for checkout', () async {
    final source = model();
    await source.restore();
    await source.add(await variant());
    final id = source.state.cart!.cart.id;
    final resumed = model();

    expect(await resumed.restoreCapability(id), isTrue);
    expect(resumed.state.cart?.cart.id, id);
    expect(storage.values['guest'], id);
  });

  test('rejects an empty external cart capability', () async {
    final resumed = model();

    expect(await resumed.restoreCapability('  '), isFalse);
    expect(resumed.state.status, CartStatus.idle);
  });
}

const _usRegion = Region(
  id: 'reg_us',
  name: 'United States',
  currencyCode: 'usd',
  taxRate: 1000,
  countries: ['us'],
);

import 'dart:async';
import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late MemoryAuthSessionStore sessions;
  late CommerceApi api;
  late AddressBookViewModel addresses;
  final now = DateTime.utc(2100, 1, 1, 12);

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('address_book_model');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await queryExecute(
      r"INSERT INTO regions "
      r"(id, name, currency_code, tax_rate, countries) "
      r"VALUES ('reg_us', 'United States', 'usd', 0, 'us,ca')",
      const [],
    ).execute(database.executor);
    server = await TestClient.serve(buildApp(database, now: () => now));
    sessions = MemoryAuthSessionStore();
    final dio = Dio()
      ..interceptors.add(
        AuthorizationInterceptor(sessions: sessions, now: () => now),
      );
    api = CommerceApi(dio, baseUrl: server.origin);
    final account = AccountViewModel(
      AccountViewModelArgs(api: api, sessions: sessions, now: () => now),
    );
    await account.register(
      email: 'ada@example.com',
      password: 'correct horse battery staple',
      firstName: 'Ada',
      lastName: 'Lovelace',
    );
    addresses = AddressBookViewModel(AddressBookViewModelArgs(api: api));
  });

  tearDown(() async {
    addresses.dispose();
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads and mutates the owned address book with server responses',
      () async {
    await addresses.load();
    expect(addresses.state.hasLoaded, isTrue);
    expect(addresses.state.addresses, isEmpty);
    expect(addresses.state.countries, ['us', 'ca']);

    expect(await addresses.create(_input), isTrue);
    expect(addresses.state.addresses.single.city, 'Washington');
    expect(addresses.state.addresses.single.isDefaultShipping, isTrue);

    final created = addresses.state.addresses.single;
    expect(
      await addresses.update(
        created.id,
        CustomerAddressInput(
          firstName: created.firstName,
          lastName: created.lastName,
          line1: created.line1,
          line2: created.line2,
          city: 'Arlington',
          province: created.province,
          postalCode: created.postalCode,
          countryCode: created.countryCode,
          phone: created.phone,
          isDefaultBilling: true,
          isDefaultShipping: true,
        ),
      ),
      isTrue,
    );
    expect(addresses.state.addresses.single.city, 'Arlington');
    expect(addresses.state.addresses.single.isDefaultBilling, isTrue);

    expect(await addresses.delete(created.id), isTrue);
    expect(addresses.state.addresses, isEmpty);

    addresses.reset();
    expect(addresses.state.status, AddressBookStatus.idle);
    expect(addresses.state.hasLoaded, isFalse);
    expect(addresses.state.countries, isEmpty);
  });

  test('a response from a previous customer cannot repopulate state', () async {
    final deferred = _DeferredAddressApi();
    final model = AddressBookViewModel(AddressBookViewModelArgs(api: deferred));

    final loading = model.load();
    model.reset();
    deferred.addresses.complete(
      const CustomerAddressListView(addresses: [], count: 0),
    );
    deferred.sellingRegions.complete(
      const SellingRegionListView(
        regions: [
          Region(
            id: 'reg_us',
            name: 'United States',
            currencyCode: 'usd',
            taxRate: 0,
            countries: ['us'],
          ),
        ],
        count: 1,
      ),
    );
    await loading;

    expect(model.state.status, AddressBookStatus.idle);
    expect(model.state.hasLoaded, isFalse);
    expect(model.state.addresses, isEmpty);
    expect(model.state.countries, isEmpty);
    model.dispose();
  });
}

const _input = CustomerAddressInput(
  firstName: 'Ada',
  lastName: 'Lovelace',
  line1: '12 First Street',
  city: 'Washington',
  province: 'DC',
  postalCode: '20001',
  countryCode: 'us',
  phone: '+1 555 0101',
  isDefaultShipping: true,
);

final class _DeferredAddressApi implements CommerceApi {
  final addresses = Completer<CustomerAddressListView>();
  final sellingRegions = Completer<SellingRegionListView>();

  @override
  Future<CustomerAddressListView> customerAddresses() => addresses.future;

  @override
  Future<SellingRegionListView> regions() => sellingRegions.future;

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Unused API method');
}

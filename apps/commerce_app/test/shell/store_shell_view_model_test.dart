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
  late _MemoryCountryPreferenceStore countries;
  late _MemoryLocalePreferenceStore locales;
  late StoreShellViewModel viewModel;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_shell');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedDevelopmentStore(database);
    server = await TestClient.serve(buildApp(database));
    api = CommerceApi(Dio(), baseUrl: server.origin);
    countries = _MemoryCountryPreferenceStore();
    locales = _MemoryLocalePreferenceStore();
    viewModel = StoreShellViewModel(
      StoreShellViewModelArgs(
        api: api,
        countries: countries,
        locales: locales,
        supportedLocales: const ['en', 'my'],
      ),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('loads public footer taxonomy in source order', () async {
    final states = <StoreShellStatus>[];
    viewModel.addListener(() => states.add(viewModel.state.status));

    await viewModel.load();

    expect(states, [StoreShellStatus.loading, StoreShellStatus.ready]);
    expect(viewModel.state.collections.single.handle, 'featured');
    expect(
      viewModel.state.categories
          .where((category) => category.parentId == null)
          .map((category) => category.name),
      ['Shirts', 'Sweatshirts', 'Pants', 'Merch'],
    );
    expect(viewModel.state.regions, hasLength(2));
    expect(viewModel.state.selectedCountryCode, const Some('dk'));
    expect(viewModel.state.currencyCode, 'eur');
    expect(viewModel.state.supportedLocales, ['en', 'my']);
    expect(viewModel.state.selectedLocaleCode, const None());
  });

  test('restores, persists and clears a supported language choice', () async {
    locales.value = const Some('my');

    await viewModel.load();
    expect(viewModel.state.selectedLocaleCode, const Some('my'));
    expect(viewModel.state.localeOr('en'), 'my');

    expect(await viewModel.selectLocale(const Some('en')), isTrue);
    expect(locales.value, const Some('en'));
    expect(await viewModel.selectLocale(const None()), isTrue);
    expect(viewModel.state.selectedLocaleCode, const None());
    expect(locales.value, const None());
  });

  test('rejects an unsupported language without changing preference', () async {
    locales.value = const Some('fr');

    await viewModel.load();
    expect(viewModel.state.selectedLocaleCode, const None());
    expect(await viewModel.selectLocale(const Some('fr')), isFalse);
    expect(locales.value, const Some('fr'));
  });

  test('restores and persists a valid country choice', () async {
    countries.value = const Some('us');

    await viewModel.load();
    expect(viewModel.state.selectedCountryCode, const Some('us'));
    expect(viewModel.state.currencyCode, 'usd');

    await viewModel.selectCountry('dk');
    expect(viewModel.state.selectedCountryCode, const Some('dk'));
    expect(countries.value, const Some('dk'));
  });

  test('one unavailable footer column does not hide the other', () async {
    final resilient = StoreShellViewModel(
      StoreShellViewModelArgs(
        api: _CollectionFailureApi(api),
        countries: countries,
        locales: locales,
        supportedLocales: const ['en', 'my'],
      ),
    );
    addTearDown(resilient.dispose);

    await resilient.load();

    expect(resilient.state.status, StoreShellStatus.ready);
    expect(resilient.state.collections, isEmpty);
    expect(resilient.state.categories, isNotEmpty);
  });
}

final class _MemoryCountryPreferenceStore implements CountryPreferenceStore {
  Option<String> value = const None();

  @override
  Future<Option<String>> read() async => value;

  @override
  Future<void> write(String countryCode) async {
    value = Some(countryCode);
  }
}

final class _MemoryLocalePreferenceStore implements LocalePreferenceStore {
  Option<String> value = const None();

  @override
  Future<void> clear() async => value = const None();

  @override
  Future<Option<String>> read() async => value;

  @override
  Future<void> write(String localeCode) async {
    value = Some(localeCode);
  }
}

final class _CollectionFailureApi implements CommerceApi {
  const _CollectionFailureApi(this.delegate);

  final CommerceApi delegate;

  @override
  Future<ProductCategoryListView> categories({
    String? handle,
    int? limit,
    int? offset,
  }) =>
      delegate.categories(handle: handle, limit: limit, offset: offset);

  @override
  Future<ProductCollectionListView> collections({
    String? handle,
    int? limit,
    int? offset,
  }) =>
      Future.error(Exception('collections unavailable'));

  @override
  Future<SellingRegionListView> regions() => delegate.regions();

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unused API method');
}

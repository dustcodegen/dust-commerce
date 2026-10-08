import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';
import 'product_listing_test_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late ProductListingViewModel viewModel;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_listing');
    database = CommerceDatabase.open(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedRoundTripCatalog(database);
    await seedListingPage(database);
    server = await TestClient.serve(buildApp(database));
    viewModel = ProductListingViewModel(
      ProductListingViewModelArgs(
        api: CommerceApi(Dio(), baseUrl: server.origin),
      ),
    );
  });

  tearDown(() async {
    viewModel.dispose();
    await server.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('collection route resolves metadata, filters, and pages by twelve',
      () async {
    await viewModel.loadCollection('summer');

    expect(viewModel.state.status, ProductListingStatus.ready);
    expect(viewModel.state.title, 'Summer');
    expect(viewModel.state.products, hasLength(12));
    expect(viewModel.state.totalPages, 2);

    await viewModel.loadCollection('summer', page: 2);
    expect(viewModel.state.products, hasLength(2));
    expect(viewModel.state.currentPage, 2);
  });

  test('category route reconstructs parents and direct children', () async {
    await viewModel.loadCategory('clothing/shirts');

    expect(viewModel.state.title, 'Shirts');
    expect(viewModel.state.parents.map((it) => it.name), ['Clothing']);
    expect(viewModel.state.products, hasLength(12));

    await viewModel.loadCategory('clothing');
    expect(viewModel.state.children.map((it) => it.name), ['Shirts']);
  });

  test('price choices sort in the requested currency', () async {
    await viewModel.loadCollection('summer', sortBy: 'price_asc');
    expect(
      viewModel.state.products.first.cheapestIn('usd')?.amount,
      100,
    );

    await viewModel.loadCollection('summer', sortBy: 'price_desc');
    expect(
      viewModel.state.products.first.cheapestIn('usd')?.amount,
      1999,
    );
  });

  test('current Medusa title choices sort by product title', () async {
    await viewModel.loadStore(sortBy: 'title_asc');
    expect(viewModel.state.products.first.title, 'Product 01');

    await viewModel.loadStore(sortBy: 'title_desc');
    expect(viewModel.state.products.first.title, 'T-Shirt');
  });

  test('store defaults to current Medusa relevance sort', () async {
    await viewModel.loadStore();

    expect(viewModel.state.sortBy, 'relevance');
  });

  test('currency is part of the listing request identity', () async {
    await viewModel.loadCollection('summer');
    final usdKey = viewModel.state.requestKey;

    await viewModel.loadCollection('summer', currency: 'eur');

    expect(viewModel.state.currencyCode, 'eur');
    expect(viewModel.state.requestKey, isNot(usdKey));
    expect(viewModel.state.products, hasLength(1));
    expect(viewModel.state.products.single.cheapestIn('eur'), isNotNull);
  });

  test('store exposes stable options and filters by selected values', () async {
    await viewModel.loadStore(optionValueIds: const ['optval_small']);

    expect(viewModel.state.status, ProductListingStatus.ready);
    expect(viewModel.state.selectedOptionValueIds, ['optval_small']);
    expect(viewModel.state.optionFilters.single.id, 'opt_size');
    expect(viewModel.state.optionFilters.single.values.first.count, 1);
    expect(viewModel.state.products.map((product) => product.handle), [
      't-shirt',
    ]);
  });

  test('store exposes categories and filters by selected handles', () async {
    await viewModel.loadStore();

    expect(viewModel.state.categoryFilters.map((filter) => filter.name), [
      'Shirts',
      'Accessories',
    ]);
    expect(viewModel.state.categoryFilters.map((filter) => filter.count), [
      13,
      1,
    ]);

    await viewModel.loadStore(categoryHandles: const ['accessories']);

    expect(viewModel.state.selectedCategoryHandles, ['accessories']);
    expect(viewModel.state.products.map((product) => product.handle), [
      'product-13',
    ]);
  });

  test('store exposes labels and filters by selected values', () async {
    await viewModel.loadStore();

    expect(viewModel.state.labelFilters.map((filter) => filter.value), [
      'Cotton',
      'Gift',
    ]);

    await viewModel.loadStore(labels: const ['Gift']);

    expect(viewModel.state.selectedLabelValues, ['Gift']);
    expect(viewModel.state.products.map((product) => product.handle), [
      'product-13',
    ]);
  });

  test('store exposes price bounds and filters by selected range', () async {
    await viewModel.loadStore();
    final bounds = viewModel.state.priceBounds as Some<ProductPriceBounds>;

    expect(bounds.value.min, 100);
    expect(bounds.value.max, 1999);

    await viewModel.loadStore(
      minPrice: const Some<int>(1200),
      maxPrice: const Some<int>(1300),
    );

    expect(viewModel.state.selectedMinPrice, const Some<int>(1200));
    expect(viewModel.state.selectedMaxPrice, const Some<int>(1300));
    expect(viewModel.state.products.map((product) => product.handle).toSet(), {
      'product-12',
      'product-13',
    });
  });

  test('store exposes sale toggle and filters discounted products', () async {
    await viewModel.loadStore();

    expect(viewModel.state.canRefineOnSale, isTrue);
    expect(viewModel.state.products.any((it) => it.isOnSaleIn('usd')), isTrue);

    await viewModel.loadStore(onSale: true);

    expect(viewModel.state.selectedOnSale, isTrue);
    expect(viewModel.state.products.map((product) => product.handle), [
      'product-13',
    ]);
    expect(
      viewModel.state.products.single.cheapestOriginalIn('usd'),
      Money.of(1700, 'usd'),
    );
  });

  test('store search filters products and keys the route identity', () async {
    await viewModel.loadStore(query: ' Product 01 ');

    expect(viewModel.state.status, ProductListingStatus.ready);
    expect(viewModel.state.searchQuery, 'Product 01');
    expect(viewModel.state.requestKey, contains(':Product 01'));
    expect(viewModel.state.products.map((product) => product.handle), [
      'product-01',
    ]);
  });

  test('option discovery failure does not take down products', () async {
    final resilient = ProductListingViewModel(
      ProductListingViewModelArgs(api: OptionFailureApi(viewModel.args.api)),
    );
    addTearDown(resilient.dispose);

    await resilient.loadStore();

    expect(resilient.state.status, ProductListingStatus.ready);
    expect(resilient.state.products, isNotEmpty);
    expect(resilient.state.optionFilters, isEmpty);
  });

  test('unknown taxonomy becomes missing without exposing an exception',
      () async {
    await viewModel.loadCollection('unknown');
    expect(viewModel.state.status, ProductListingStatus.missing);

    await viewModel.loadCategory('unknown');
    expect(viewModel.state.status, ProductListingStatus.missing);
  });
}

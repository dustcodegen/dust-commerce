import 'dart:io';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_server/commerce_server.dart';
import 'package:dust_dart/http.dart';
import 'package:dust_server/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import '../core/support.dart';
import 'support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient server;
  late CommerceApi api;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('storefront_flow');
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

  test('catalogue product options resolve to a real variant', () async {
    final product = ProductViewModel(ProductViewModelArgs(api: api));

    await product.load('t-shirt');
    expect(product.state.status, ProductDetailStatus.ready);
    expect(product.state.product?.variants, hasLength(8));
    expect(product.state.selectedVariant, isNull);

    product.select('opt_size', 'M');
    expect(product.state.selectedVariant, isNull);
    product.select('opt_color', 'White');

    expect(product.state.selectedVariant?.id, 'var_tshirt_m_white');
    expect(product.state.selectedVariant?.isInStock, isTrue);
  });

  test('a Medusa v_id restores the complete product selection', () async {
    final product = ProductViewModel(ProductViewModelArgs(api: api));

    await product.load('t-shirt', variantId: 'var_tshirt_l_black');

    expect(product.state.selection, {
      'opt_color': 'Black',
      'opt_size': 'L',
    });
    expect(product.state.selectedVariant?.id, 'var_tshirt_l_black');
  });

  test('product details load prices in the selected region currency', () async {
    final product = ProductViewModel(ProductViewModelArgs(api: api));

    await product.load('t-shirt', currency: 'eur');

    expect(product.state.currencyCode, 'eur');
    expect(
      product.state.product!.variants.every(
        (variant) => variant.prices.single.currencyCode == 'eur',
      ),
      isTrue,
    );
  });

  test('a missing product enters the main-route not-found state', () async {
    final product = ProductViewModel(ProductViewModelArgs(api: api));

    await product.load('does-not-exist');

    expect(product.state.status, ProductDetailStatus.missing);
    expect(product.state.message, isNull);
  });

  test('related products come from the API and exclude the current item',
      () async {
    final product = ProductViewModel(ProductViewModelArgs(api: api));

    await product.load('t-shirt');

    expect(product.state.relatedStatus, RelatedProductsStatus.ready);
    expect(product.state.relatedProducts, hasLength(3));
    expect(
      product.state.relatedProducts.map((item) => item.id),
      isNot(contains('prod_tshirt')),
    );
    expect(
      product.state.relatedProducts.every(
        (item) => item.cheapestIn(product.state.currencyCode) != null,
      ),
      isTrue,
    );
  });

  test('an empty related result does not hide the main product', () async {
    await queryExecute(
      "DELETE FROM products WHERE id <> 'prod_tshirt'",
      const [],
    ).execute(database.executor);
    final product = ProductViewModel(ProductViewModelArgs(api: api));

    await product.load('t-shirt');

    expect(product.state.status, ProductDetailStatus.ready);
    expect(product.state.relatedStatus, RelatedProductsStatus.ready);
    expect(product.state.relatedProducts, isEmpty);
  });

  test('a related-products failure leaves the main product usable', () async {
    final product = ProductViewModel(
      ProductViewModelArgs(api: RelatedFailureApi(api)),
    );

    await product.load('t-shirt');

    expect(product.state.status, ProductDetailStatus.ready);
    expect(product.state.product?.id, 'prod_tshirt');
    expect(product.state.relatedStatus, RelatedProductsStatus.failed);
    expect(product.state.relatedMessage, isNotNull);
  });

  test('demo product exposes a source-visible unavailable combination',
      () async {
    await seedDevelopmentDemoCatalog(database);
    final product = await api.product('split-raglan-tee', currency: 'usd');
    final state = ProductDetailState(
      status: ProductDetailStatus.ready,
      product: product,
      selection: const {'opt_size': 'S'},
    );

    expect(state.canSelect('opt_color', 'Black'), isTrue);
    expect(state.canSelect('opt_color', 'White'), isTrue);
    expect(
        product.variantFor(const {
          'opt_size': 'S',
          'opt_color': 'Black',
        })?.id,
        'var_demo_21_s_black');
    expect(
      state.copyWith(selection: const {
        'opt_size': 'S',
        'opt_color': 'White',
      }).selectedVariant,
      isNull,
    );
  });

  test('unavailable reload keeps the partial option selection', () async {
    await seedDevelopmentDemoCatalog(database);
    final product = ProductViewModel(ProductViewModelArgs(api: api));

    await product.load(
      'split-raglan-tee',
      variantId: 'var_demo_21_s_black',
    );
    product.select('opt_color', 'White');
    expect(product.state.selectedVariant, isNull);

    await product.load('split-raglan-tee');
    product.select('opt_size', 'M');

    expect(product.state.selection, {
      'opt_color': 'White',
      'opt_size': 'M',
    });
    expect(product.state.selectedVariant?.id, 'var_demo_21_m_white');
  });

  test('selected variant creates a server cart and line item', () async {
    final product = await api.product('t-shirt', currency: 'usd');
    final cart = CartViewModel(
      CartViewModelArgs(
        api: api,
        cartIds: MemoryCartIdStore(),
        selectedRegion: () => const None(),
      ),
    );
    final small = product.variants.firstWhere(
      (variant) => variant.id == 'var_tshirt_s_black',
    );

    final added = await cart.add(small);

    expect(added, isTrue);
    expect(cart.state.status, CartStatus.ready);
    expect(cart.state.itemCount, 1);
    expect(
      cart.state.cart?.cart.items.single.variantId,
      'var_tshirt_s_black',
    );
    expect(cart.state.cart?.total.amount, greaterThan(0));
  });
}

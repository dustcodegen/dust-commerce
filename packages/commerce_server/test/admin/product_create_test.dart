import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product creation and create context require an admin bearer', () async {
    (await harness.client.get('/admin/products/create-context').send())
        .assertUnauthorized();
    final request = harness.client.post('/admin/products')..json(_body());
    (await request.send()).assertUnauthorized();
  });

  test('create context lists active storefront currencies', () async {
    final token = await harness.adminToken();
    final request = harness.client.get('/admin/products/create-context')
      ..bearer(token);

    final response = await request.send();

    response.assertOk();
    expect(response.json, {
      'currency_codes': ['eur', 'usd'],
    });
  });

  test('creates a complete product graph that is immediately storefront-ready',
      () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_body());

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json['title'], 'Canvas Tote');
    expect(json['handle'], 'canvas-tote');
    expect(json['status'], 'published');
    expect(json['options'], [
      {
        'id': isA<String>(),
        'title': 'Color',
        'values': ['Black', 'Natural'],
      },
    ]);
    expect(json['variants'], hasLength(2));

    final usdStorefront = await harness.client
        .get('/store/products/canvas-tote?currency=usd')
        .send();
    final eurStorefront = await harness.client
        .get('/store/products/canvas-tote?currency=eur')
        .send();
    usdStorefront.assertOk();
    eurStorefront.assertOk();
    final usdProduct = Product.fromJson(
      usdStorefront.json! as Map<String, Object?>,
    );
    final eurProduct = Product.fromJson(
      eurStorefront.json! as Map<String, Object?>,
    );
    expect(usdProduct.title, 'Canvas Tote');
    expect(usdProduct.variants, hasLength(2));
    expect(usdProduct.cheapestIn('usd'), Money.of(2500, 'usd'));
    expect(eurProduct.cheapestIn('eur'), Money.of(2300, 'eur'));
    expect(usdProduct.isPurchasable, isTrue);
    expect(
      usdProduct.variants.map((variant) => variant.optionValues.values.single),
      ['Black', 'Natural'],
    );
  });

  test('duplicate handle rolls back the whole graph', () async {
    final token = await harness.adminToken();
    final first = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_body());
    final second = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_body(title: 'Duplicate'));

    (await first.send()).assertOk();
    (await second.send()).assertConflict();

    final products = await harness.raw(
      "SELECT count(*) FROM products WHERE handle = 'canvas-tote'",
    );
    final options = await harness.raw(
      "SELECT count(*) FROM product_product_options "
      "WHERE product_id LIKE 'id_%'",
    );
    expect(products.single.readIndex<int>(0), 1);
    expect(options.single.readIndex<int>(0), 1);
  });

  test('duplicate SKU rolls back the product and its option graph', () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_body(sku: 'TSHIRT-S-BLACK'));

    (await request.send()).assertConflict();

    final products = await harness.raw(
      "SELECT count(*) FROM products WHERE handle = 'canvas-tote'",
    );
    final options = await harness.raw(
      "SELECT count(*) FROM product_product_options "
      "WHERE product_id LIKE 'id_%'",
    );
    expect(products.single.readIndex<int>(0), 0);
    expect(options.single.readIndex<int>(0), 0);
  });

  test('incomplete option selections and prices are rejected atomically',
      () async {
    final token = await harness.adminToken();
    final badSelection = _body();
    final variants = badSelection['variants']! as List<Object?>;
    (variants.first! as Map<String, Object?>)['option_values'] =
        <String, String>{};
    final missingPrice = _body();
    final pricedVariants = missingPrice['variants']! as List<Object?>;
    final firstVariant = pricedVariants.first! as Map<String, Object?>;
    firstVariant['prices'] = [
      {'currency_code': 'usd', 'amount': 2500},
    ];

    final selectionRequest = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(badSelection);
    final priceRequest = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(missingPrice);
    (await selectionRequest.send()).assertUnprocessable();
    (await priceRequest.send()).assertUnprocessable();

    final products = await harness.raw(
      "SELECT count(*) FROM products WHERE handle = 'canvas-tote'",
    );
    expect(products.single.readIndex<int>(0), 0);
  });
}

Map<String, Object?> _body({
  String title = '  Canvas Tote  ',
  String sku = 'TOTE-BLACK',
}) =>
    {
      'title': title,
      'handle': 'canvas-tote',
      'subtitle': '  Everyday carry  ',
      'material': '  Cotton canvas  ',
      'description': '  A durable bag for daily essentials.  ',
      'discountable': true,
      'status': 'published',
      'media': [],
      'options': [
        {
          'title': 'Color',
          'values': ['Black', 'Natural'],
        },
      ],
      'variants': [
        {
          'title': 'Black',
          'sku': sku,
          'inventory_quantity': 12,
          'manage_inventory': true,
          'allow_backorder': false,
          'option_values': {'Color': 'Black'},
          'prices': [
            {'currency_code': 'eur', 'amount': 2300},
            {'currency_code': 'usd', 'amount': 2500},
          ],
        },
        {
          'title': 'Natural',
          'sku': 'TOTE-NATURAL',
          'inventory_quantity': 8,
          'manage_inventory': true,
          'allow_backorder': false,
          'option_values': {'Color': 'Natural'},
          'prices': [
            {'currency_code': 'eur', 'amount': 2400},
            {'currency_code': 'usd', 'amount': 2600},
          ],
        },
      ],
    };

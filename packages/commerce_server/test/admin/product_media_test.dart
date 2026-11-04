import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('rejects a syntactically valid image that was never uploaded', () async {
    final token = await harness.adminToken();
    final request = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_productBody({
        'id': 'missing_media.png',
        'url': 'http://media.test/uploads/missing_media.png',
      }));

    (await request.send()).assertUnprocessable();
    final products = await harness.raw(
      "SELECT count(*) FROM products WHERE handle = 'media-product'",
    );
    expect(products.single.readIndex<int>(0), 0);
  });

  test('attached media reaches the storefront and cannot be discarded',
      () async {
    final uploaded = await harness.uploadPng();
    final token = await harness.adminToken();
    final create = harness.client.post('/admin/products')
      ..bearer(token)
      ..json(_productBody(uploaded));

    final created = await create.send();
    created.assertOk();
    final json = created.json! as Map<String, Object?>;
    expect(json['thumbnail'], uploaded['url']);
    expect(json['images'], [
      {
        'id': isA<String>(),
        'url': uploaded['url'],
        'variant_ids': <String>[],
      },
    ]);

    final storefront = await harness.client
        .get('/store/products/media-product?currency=usd')
        .send();
    storefront.assertOk();
    final product = Product.fromJson(
      storefront.json! as Map<String, Object?>,
    );
    expect(product.thumbnail, uploaded['url']);
    expect(product.images.map((image) => image.url), [uploaded['url']]);

    final remove = harness.client.delete('/admin/uploads/${uploaded['id']}')
      ..bearer(token);
    (await remove.send()).assertConflict();
  });
}

Map<String, Object?> _productBody(Map<String, Object?> uploaded) => {
      'title': 'Media Product',
      'handle': 'media-product',
      'discountable': true,
      'status': 'published',
      'media': [
        {
          'id': uploaded['id'],
          'url': uploaded['url'],
          'is_thumbnail': true,
        },
      ],
      'options': [
        {
          'title': 'Style',
          'values': ['Default'],
        },
      ],
      'variants': [
        {
          'title': 'Default',
          'inventory_quantity': 2,
          'manage_inventory': true,
          'allow_backorder': false,
          'option_values': {'Style': 'Default'},
          'prices': [
            {'currency_code': 'eur', 'amount': 900},
            {'currency_code': 'usd', 'amount': 1000},
          ],
        },
      ],
    };

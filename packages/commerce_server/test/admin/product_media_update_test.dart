import 'package:commerce_shared/commerce_shared.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product media replacement requires a proven admin bearer', () async {
    final request = harness.client.put('/admin/products/prod_sweatpants/media')
      ..json({'media': <Object?>[]});

    (await request.send()).assertUnauthorized();
  });

  test('reorders, adds, removes, and promotes media atomically', () async {
    final uploaded = await harness.uploadPng();
    final token = await harness.adminToken();
    final associate = harness.client.post(
      '/admin/products/prod_sweatpants/images/'
      'img_sweatpants_1/variants/batch',
    )
      ..bearer(token)
      ..json({
        'add': ['var_sweatpants_s'],
        'remove': <String>[],
      });
    (await associate.send()).assertOk();
    final request = harness.client.put('/admin/products/prod_sweatpants/media')
      ..bearer(token)
      ..json({
        'media': [
          {
            'id': 'img_sweatpants_2',
            'url': _back,
            'is_thumbnail': true,
          },
          {
            'id': uploaded['id'],
            'url': uploaded['url'],
            'is_thumbnail': false,
          },
        ],
      });

    final response = await request.send();

    response.assertOk();
    final product = response.json! as Map<String, Object?>;
    expect(product['thumbnail'], _back);
    expect(product['images'], [
      {
        'id': 'img_sweatpants_2',
        'url': _back,
        'variant_ids': <String>[],
      },
      {
        'id': isA<String>(),
        'url': uploaded['url'],
        'variant_ids': <String>[],
      },
    ]);

    final storefront = await harness.client
        .get('/store/products/sweatpants?currency=usd')
        .send();
    storefront.assertOk();
    final public = Product.fromJson(storefront.json! as Map<String, Object?>);
    expect(public.thumbnail, _back);
    expect(public.images.map((image) => image.url), [_back, uploaded['url']]);

    final rows = await harness.raw('''
SELECT id, deleted_at FROM product_images
WHERE product_id = 'prod_sweatpants' ORDER BY id
''');
    expect(rows, hasLength(3));
    expect(
      rows
          .singleWhere((row) => row.readIndex<String>(0) == 'img_sweatpants_1')
          .readIndex<DateTime?>(1),
      isNotNull,
    );
    expect(
      await harness.raw('''
SELECT * FROM product_image_variants
WHERE image_id IN ('img_sweatpants_1', 'img_sweatpants_2')
'''),
      isEmpty,
    );
  });

  test('rejects mismatched existing ids without changing media', () async {
    final token = await harness.adminToken();
    final request = harness.client.put('/admin/products/prod_sweatpants/media')
      ..bearer(token)
      ..json({
        'media': [
          {
            'id': 'img_sweatpants_1',
            'url': _back,
            'is_thumbnail': true,
          },
        ],
      });

    (await request.send()).assertUnprocessable();
    final current = harness.client.get('/admin/products/prod_sweatpants')
      ..bearer(token);
    final response = await current.send();
    response.assertOk();
    expect(
      (response.json! as Map<String, Object?>)['images'],
      hasLength(2),
    );
  });
}

const _back = 'https://medusa-public-images.s3.eu-west-1.amazonaws.com/'
    'sweatpants-gray-back.png';

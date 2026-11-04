import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product detail requires a proven admin bearer', () async {
    (await harness.client.get('/admin/products/prod_sweatpants').send())
        .assertUnauthorized();
  });

  test('product detail returns all modeled Medusa sections', () async {
    final token = await harness.adminToken();
    final request = harness.client.get('/admin/products/prod_sweatpants')
      ..bearer(token);
    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json.keys, {
      'categories',
      'collection_title',
      'description',
      'discountable',
      'handle',
      'height',
      'id',
      'images',
      'length',
      'material',
      'options',
      'origin_country',
      'product_type',
      'product_type_id',
      'shipping_profile',
      'status',
      'subtitle',
      'tags',
      'thumbnail',
      'title',
      'variants',
      'weight',
      'width',
    });
    expect(json['title'], 'Relaxed Sweatpants');
    expect(json['product_type'], 'Pants');
    expect(json['product_type_id'], 'ptyp_pants');
    expect(json['categories'], ['Pants']);
    expect(json['tags'], ['Apparel', 'Cotton']);
    expect(json['images'], hasLength(2));
    expect(json['options'], [
      {
        'id': 'opt_size',
        'title': 'Size',
        'values': ['S', 'M'],
      },
    ]);
    final variants = json['variants']! as List<Object?>;
    expect(variants, hasLength(2));
    expect(variants.first, isNot(contains('metadata')));
    expect(json, isNot(contains('deleted_at')));
  });

  test('product detail retains the merchant option order', () async {
    final token = await harness.adminToken();
    final request = harness.client.get('/admin/products/prod_tshirt')
      ..bearer(token);

    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    final options =
        (json['options']! as List<Object?>).cast<Map<String, Object?>>();
    expect(options.map((option) => option['title']), ['Size', 'Color']);
  });

  test('product detail returns not found for an unknown id', () async {
    final token = await harness.adminToken();
    final request = harness.client.get('/admin/products/prod_missing')
      ..bearer(token);

    (await request.send()).assertNotFound();
  });
}

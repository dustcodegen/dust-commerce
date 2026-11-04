import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product list requires a proven admin bearer', () async {
    (await harness.client.get('/admin/products').send()).assertUnauthorized();
  });

  test('product list exposes only table fields and active variant counts',
      () async {
    final token = await harness.adminToken();
    final request = harness.client.get('/admin/products?limit=2&offset=0')
      ..bearer(token);
    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json['count'], 4);
    expect(json['limit'], 2);
    expect(json['offset'], 0);
    final products = json['products']! as List<Object?>;
    expect(products, hasLength(2));
    final first = products.first! as Map<String, Object?>;
    expect(first.keys, {
      'collection_title',
      'id',
      'sales_channels',
      'status',
      'thumbnail',
      'title',
      'variant_count',
    });
    expect(first['variant_count'], greaterThan(0));
    expect(first, isNot(contains('description')));
    expect(first, isNot(contains('metadata')));
  });

  test('product list exposes ordered active sales-channel objects', () async {
    await harness.raw(
      "INSERT INTO product_sales_channels "
      "(id, product_id, sales_channel_id) "
      "VALUES ('prodsc_tshirt_wholesale', 'prod_tshirt', 'sc_wholesale')",
    );
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/products?q=t-shirt&limit=20&offset=0')
              ..bearer(token))
            .send();

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    final products = body['products']! as List<Object?>;
    final product = products.single! as Map<String, Object?>;
    expect(product['sales_channels'], [
      {'id': 'sc_web', 'name': 'Online Store'},
      {'id': 'sc_wholesale', 'name': 'Wholesale'},
    ]);
  });

  test('product list searches title or handle case-insensitively', () async {
    final token = await harness.adminToken();
    final request = harness.client.get('/admin/products?q=SWEAT&limit=20')
      ..bearer(token);
    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json['count'], 2);
    final products = json['products']! as List<Object?>;
    expect(
      products.map((value) => (value! as Map<String, Object?>)['title']),
      containsAll(['Vintage Sweatshirt', 'Relaxed Sweatpants']),
    );
  });

  test('product list filters multiple lifecycle states before paging',
      () async {
    await harness.raw(
      "UPDATE products SET status = 'draft' WHERE id = 'prod_tshirt'",
    );
    await harness.raw(
      "UPDATE products SET status = 'rejected' WHERE id = 'prod_shorts'",
    );
    final token = await harness.adminToken();
    final request = harness.client.get(
      '/admin/products?status=draft,rejected&limit=1&offset=0',
    )..bearer(token);
    final response = await request.send();

    response.assertOk();
    final json = response.json! as Map<String, Object?>;
    expect(json['count'], 2);
    expect(json['products'], hasLength(1));
  });

  test('product list supports Medusa title and timestamp ordering', () async {
    await harness.raw(
      "UPDATE products SET created_at = CASE id "
      "WHEN 'prod_tshirt' THEN TIMESTAMPTZ '2026-01-01T00:00:00.000Z' "
      "WHEN 'prod_sweatshirt' THEN TIMESTAMPTZ '2026-01-02T00:00:00.000Z' "
      "WHEN 'prod_sweatpants' THEN TIMESTAMPTZ '2026-01-03T00:00:00.000Z' "
      "ELSE TIMESTAMPTZ '2026-01-04T00:00:00.000Z' END, "
      "updated_at = CASE id "
      "WHEN 'prod_tshirt' THEN TIMESTAMPTZ '2026-02-04T00:00:00.000Z' "
      "WHEN 'prod_sweatshirt' THEN TIMESTAMPTZ '2026-02-03T00:00:00.000Z' "
      "WHEN 'prod_sweatpants' THEN TIMESTAMPTZ '2026-02-02T00:00:00.000Z' "
      "ELSE TIMESTAMPTZ '2026-02-01T00:00:00.000Z' END",
    );
    final token = await harness.adminToken();

    expect(await _firstTitle(harness, token, 'title'), 'Essential T-Shirt');
    expect(await _firstTitle(harness, token, '-title'), 'Vintage Sweatshirt');
    expect(
        await _firstTitle(harness, token, 'created_at'), 'Essential T-Shirt');
    expect(await _firstTitle(harness, token, '-created_at'), 'Everyday Shorts');
    expect(await _firstTitle(harness, token, 'updated_at'), 'Everyday Shorts');
    expect(
        await _firstTitle(harness, token, '-updated_at'), 'Essential T-Shirt');
  });

  test('product list rejects unknown filters and order keys', () async {
    final token = await harness.adminToken();

    (await (harness.client.get('/admin/products?status=archived')
              ..bearer(token))
            .send())
        .assertBadRequest();
    (await (harness.client.get('/admin/products?order=handle')..bearer(token))
            .send())
        .assertBadRequest();
  });
}

Future<String> _firstTitle(
  AdminHarness harness,
  String token,
  String order,
) async {
  final response = await (harness.client.get('/admin/products?order=$order')
        ..bearer(token))
      .send();
  response.assertOk();
  final json = response.json! as Map<String, Object?>;
  final products = json['products']! as List<Object?>;
  return (products.first! as Map<String, Object?>)['title']! as String;
}

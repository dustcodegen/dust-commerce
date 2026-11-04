import 'dart:convert';

import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;
  late String token;

  setUp(() async {
    harness = await AdminHarness.start(seedStore: true);
    token = await harness.adminToken();
  });
  tearDown(() => harness.stop());

  test('product list filters tag ids before count and paging', () async {
    await harness.raw(
      "INSERT INTO product_tags (id, value) VALUES ('ptag_featured', 'Featured')",
    );
    await harness.raw(
      "INSERT INTO product_tag_products (product_id, tag_id) "
      "VALUES ('prod_shorts', 'ptag_featured')",
    );

    final response = await _get(
      harness,
      token,
      {'tag_id': 'ptag_featured,ptag_missing', 'limit': '1'},
    );

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['count'], 1);
    expect(body['products'], hasLength(1));
    expect(_ids(body), ['prod_shorts']);
  });

  test('product list filters normalized product type ids', () async {
    final response = await _get(
      harness,
      token,
      {'type_id': 'ptyp_shirt,ptyp_shorts', 'order': 'title'},
    );

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['count'], 2);
    expect(_ids(body), ['prod_tshirt', 'prod_shorts']);
  });

  test('product list applies inclusive UTC date ranges', () async {
    await harness.raw(
      "UPDATE products SET created_at = CASE id "
      "WHEN 'prod_tshirt' THEN TIMESTAMPTZ '2026-01-01T00:00:00.000Z' "
      "WHEN 'prod_sweatshirt' THEN TIMESTAMPTZ '2026-01-02T00:00:00.000Z' "
      "WHEN 'prod_sweatpants' THEN TIMESTAMPTZ '2026-01-03T00:00:00.000Z' "
      "ELSE TIMESTAMPTZ '2026-01-04T00:00:00.000Z' END",
    );
    final range = jsonEncode({
      r'$gte': '2026-01-02T00:00:00+00:00',
      r'$lte': '2026-01-03T00:00:00Z',
    });

    final response = await _get(
      harness,
      token,
      {'created_at': range, 'order': 'created_at'},
    );

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(body['count'], 2);
    expect(_ids(body), ['prod_sweatshirt', 'prod_sweatpants']);
  });

  test('product list applies exclusive updated-time bounds', () async {
    await harness.raw(
      "UPDATE products SET updated_at = CASE id "
      "WHEN 'prod_tshirt' THEN TIMESTAMPTZ '2026-02-01T00:00:00.000Z' "
      "WHEN 'prod_sweatshirt' THEN TIMESTAMPTZ '2026-02-02T00:00:00.000Z' "
      "WHEN 'prod_sweatpants' THEN TIMESTAMPTZ '2026-02-03T00:00:00.000Z' "
      "ELSE TIMESTAMPTZ '2026-02-04T00:00:00.000Z' END",
    );
    final range = jsonEncode({
      r'$gt': '2026-02-01T00:00:00Z',
      r'$lt': '2026-02-04T00:00:00Z',
    });

    final response = await _get(
      harness,
      token,
      {'updated_at': range, 'order': 'updated_at'},
    );

    response.assertOk();
    final body = response.json! as Map<String, Object?>;
    expect(_ids(body), ['prod_sweatshirt', 'prod_sweatpants']);
  });

  test('product list rejects malformed ids and date comparisons', () async {
    for (final query in [
      {'tag_id': 'ptag_apparel,,ptag_cotton'},
      {'type_id': 'ptyp_shirt,,ptyp_shorts'},
      {
        'created_at': jsonEncode({r'$gte': '2026-01-01'})
      },
      {
        'updated_at': jsonEncode({r'$after': '2026-01-01T00:00:00Z'})
      },
      {
        'created_at': jsonEncode({
          r'$gte': '2026-01-02T00:00:00Z',
          r'$lte': '2026-01-01T00:00:00Z',
        })
      },
      {'created_at': '{'},
    ]) {
      (await _get(harness, token, query)).assertBadRequest();
    }
  });
}

Future<TestResponse> _get(
  AdminHarness harness,
  String token,
  Map<String, String> query,
) =>
    (harness.client.get(Uri(
      path: '/admin/products',
      queryParameters: query,
    ).toString())
          ..bearer(token))
        .send();

List<String> _ids(Map<String, Object?> body) =>
    (body['products']! as List<Object?>)
        .map((value) => (value! as Map<String, Object?>)['id']! as String)
        .toList();

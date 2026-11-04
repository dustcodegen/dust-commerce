import 'package:test/test.dart';
import 'package:commerce_server/commerce_server.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('product option routes require a proven admin bearer', () async {
    final responses = await Future.wait([
      harness.client.get('/admin/product-options').send(),
      harness.client.get('/admin/product-options/opt_size').send(),
      (harness.client.patch('/admin/product-options/opt_size')..json(_body()))
          .send(),
    ]);

    for (final response in responses) {
      response.assertUnauthorized();
    }
  });

  test('list exposes searchable global rows with bounded metadata', () async {
    final token = await harness.adminToken();
    final response = await (harness.client
            .get('/admin/product-options?q=si&limit=1&offset=0')
          ..bearer(token))
        .send();

    response.assertOk();
    expect(response.json, {
      'count': 1,
      'limit': 1,
      'offset': 0,
      'product_options': [
        {
          'id': 'opt_size',
          'is_exclusive': false,
          'title': 'Size',
          'value_count': 4,
        },
      ],
    });
  });

  test('detail exposes ordered values and allowlisted linked products',
      () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/product-options/opt_size')
              ..bearer(token))
            .send();

    response.assertOk();
    final option = response.json! as Map<String, Object?>;
    expect(option['id'], 'opt_size');
    expect(option['is_exclusive'], false);
    expect(option['title'], 'Size');
    expect(
      (option['values']! as List<Object?>)
          .map((item) => (item! as Map<String, Object?>)['value'])
          .toList(),
      ['S', 'M', 'L', 'XL'],
    );
    final products = option['products']! as List<Object?>;
    expect(products, hasLength(4));
    expect(
      (products.first! as Map<String, Object?>).keys,
      unorderedEquals([
        'id',
        'collection_title',
        'sales_channels',
        'status',
        'thumbnail',
        'title',
        'variant_count',
      ]),
    );
    expect((products.first! as Map<String, Object?>)['sales_channels'], [
      {'id': 'sc_web', 'name': 'Online Store'},
    ]);
  });

  test('unknown option detail returns not found', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/product-options/opt_missing')
              ..bearer(token))
            .send();

    response.assertNotFound();
  });

  test('detail reads an exclusive option linked from a product', () async {
    await queryExecute(
      'INSERT INTO product_options (id, title, is_exclusive) '
      "VALUES ('opt_exclusive', 'Finish', 1)",
      [],
    ).execute(harness.database.executor);
    final token = await harness.adminToken();
    final response =
        await (harness.client.get('/admin/product-options/opt_exclusive')
              ..bearer(token))
            .send();

    response.assertOk();
    expect((response.json! as Map<String, Object?>)['is_exclusive'], true);
  });

  test('global update renames, ranks, and attaches a new value', () async {
    final token = await harness.adminToken();
    final response =
        await (harness.client.patch('/admin/product-options/opt_size')
              ..bearer(token)
              ..json(_body(
                title: 'Clothing size',
                values: ['M', 'S', 'L', 'XL', 'XXL'],
              )))
            .send();

    response.assertOk();
    final option = response.json! as Map<String, Object?>;
    expect(option['title'], 'Clothing size');
    expect(
      (option['values']! as List<Object?>)
          .map((item) => (item! as Map<String, Object?>)['value'])
          .toList(),
      ['M', 'S', 'L', 'XL', 'XXL'],
    );
    final rows = await harness.raw(
      'SELECT count(*) FROM product_product_option_values availability '
      'JOIN product_option_values value '
      'ON value.id = availability.product_option_value_id '
      "WHERE value.option_id = 'opt_size' AND value.value = 'XXL' "
      'AND availability.deleted_at IS NULL',
    );
    expect(rows.single.readIndex<int>(0), 4);
  });

  test('removing a selected value rolls the global update back', () async {
    final token = await harness.adminToken();
    final response = await (harness.client
            .patch('/admin/product-options/opt_size')
          ..bearer(token)
          ..json(_body(title: 'Must not persist', values: ['M', 'L', 'XL'])))
        .send();

    response.assertConflict();
    final rows = await harness.raw(
      "SELECT title FROM product_options WHERE id = 'opt_size'",
    );
    expect(rows.single.readIndex<String>(0), 'Size');
  });

  test('duplicate title or values leave the global option unchanged', () async {
    final token = await harness.adminToken();
    final titleConflict =
        await (harness.client.patch('/admin/product-options/opt_size')
              ..bearer(token)
              ..json(_body(title: 'Color')))
            .send();
    final invalid =
        await (harness.client.patch('/admin/product-options/opt_size')
              ..bearer(token)
              ..json(_body(values: ['S', 'S'])))
            .send();

    titleConflict.assertConflict();
    invalid.assertUnprocessable();
  });
}

Map<String, Object?> _body({
  String title = 'Size',
  List<String> values = const ['S', 'M', 'L', 'XL'],
}) =>
    {'title': title, 'values': values};

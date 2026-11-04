import 'package:test/test.dart';

import 'support.dart';

void main() {
  late AdminHarness harness;

  setUp(() async => harness = await AdminHarness.start(seedStore: true));
  tearDown(() => harness.stop());

  test('variant price mutation requires a proven admin bearer', () async {
    final response = await (harness.client.put(
      '/admin/products/prod_sweatpants/variants/var_sweatpants_s/prices',
    )..json(_prices()))
        .send();

    response.assertUnauthorized();
  });

  test('detail exposes sorted exact regional prices', () async {
    final token = await harness.adminToken();
    final response = await (harness.client.get(
      '/admin/products/prod_sweatpants',
    )..bearer(token))
        .send();

    response.assertOk();
    expect(_variant(response.json!, 'var_sweatpants_s')['prices'], [
      {'amount': 1900, 'currency_code': 'eur'},
      {'amount': 2900, 'currency_code': 'usd'},
    ]);
  });

  test('replacement is atomic and immediately changes storefront prices',
      () async {
    await harness.raw(
      "UPDATE variant_prices SET updated_at = '2000-01-01T00:00:00.000Z' "
      "WHERE variant_id = 'var_sweatpants_s'",
    );
    await harness.raw(
      "INSERT INTO variant_prices (variant_id, currency_code, amount) "
      "VALUES ('var_sweatpants_s', 'jpy', 4100)",
    );
    final token = await harness.adminToken();
    final response = await (harness.client.put(
      '/admin/products/prod_sweatpants/variants/var_sweatpants_s/prices',
    )
          ..bearer(token)
          ..json(_prices(eur: 2101, usd: 3101)))
        .send();

    response.assertOk();
    expect(_variant(response.json!, 'var_sweatpants_s')['prices'], [
      {'amount': 2101, 'currency_code': 'eur'},
      {'amount': 3101, 'currency_code': 'usd'},
    ]);
    final rows = await harness.raw(
      'SELECT currency_code, amount, updated_at FROM variant_prices '
      "WHERE variant_id = 'var_sweatpants_s' ORDER BY currency_code",
    );
    expect(rows.map((row) => row.readIndex<String>(0)), ['eur', 'usd']);
    expect(rows.map((row) => row.readIndex<int>(1)), [2101, 3101]);
    expect(
      rows.every((row) =>
          row.readIndex<DateTime>(2).toUtc() !=
          DateTime.parse('2000-01-01T00:00:00.000Z')),
      isTrue,
    );

    final eur = await harness.client
        .get('/store/products/sweatpants?currency=eur')
        .send();
    final usd = await harness.client
        .get('/store/products/sweatpants?currency=usd')
        .send();
    expect(_storeAmount(eur.json!, 'var_sweatpants_s'), 2101);
    expect(_storeAmount(usd.json!, 'var_sweatpants_s'), 3101);
  });

  test('incomplete price sets roll back without partial writes', () async {
    final token = await harness.adminToken();
    final response = await (harness.client.put(
      '/admin/products/prod_sweatpants/variants/var_sweatpants_s/prices',
    )
          ..bearer(token)
          ..json({
            'prices': [
              {'currency_code': 'eur', 'amount': 2101},
            ],
          }))
        .send();

    response.assertUnprocessable();
    final rows = await harness.raw(
      'SELECT currency_code, amount FROM variant_prices '
      "WHERE variant_id = 'var_sweatpants_s' ORDER BY currency_code",
    );
    expect(rows.map((row) => row.readIndex<int>(1)), [1900, 2900]);
  });
}

Map<String, Object?> _prices({int eur = 2000, int usd = 3000}) => {
      'prices': [
        {'currency_code': 'eur', 'amount': eur},
        {'currency_code': 'usd', 'amount': usd},
      ],
    };

Map<String, Object?> _variant(Object? json, String id) =>
    ((json! as Map<String, Object?>)['variants']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .singleWhere((variant) => variant['id'] == id);

int _storeAmount(Object? json, String id) =>
    (_variant(json, id)['prices']! as List<Object?>)
        .cast<Map<String, Object?>>()
        .single['amount']! as int;

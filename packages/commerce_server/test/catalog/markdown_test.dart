import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_server/testing.dart';
import 'package:test/test.dart';

import 'read_support.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;
  late TestClient client;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_markdown');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await seedCatalogRead(database);
    await queryExecute(
      r'''
INSERT INTO regions
  (id, name, currency_code, tax_rate, countries, metadata)
VALUES
  ('reg_us', 'United States', 'usd', 0, 'us',
   '{"return_window_days":30,"free_returns":true,"shipping_rate":0,"handling_days_min":0,"handling_days_max":1,"transit_days_min":2,"transit_days_max":3}')
''',
      [],
    ).execute(database.executor);
    client = TestClient(buildApp(database));
  });

  tearDown(() async {
    await client.close();
    await database.close();
    await directory.delete(recursive: true);
  });

  test('returns an explicit text/markdown product projection', () async {
    final response =
        await client.get('/store/products/t-shirt/markdown?country=us').send();

    response
      ..assertOk()
      ..assertHeader('content-type', 'text/markdown; charset=utf-8');
    expect(response.body, contains('# T-Shirt'));
    expect(
      response.body,
      contains('| USD 19.99 | In stock | `var_small` |'),
    );
    expect(
      response.body,
      contains('- Shipping: free, ships in 0-1 business days'),
    );
    expect(
      response.body,
      contains('POST `variant_id={variant_id}&quantity={n}&region_id=reg_us`'),
    );
    expect(response.body, isNot(contains('inventory_quantity')));
  });

  test('supports the Medusa .md product URL alias', () async {
    final response = await (client.get('/store/products/t-shirt.md?country=us')
          ..header('accept', 'text/markdown; q=0, application/json'))
        .send();

    response
      ..assertOk()
      ..assertHeader('content-type', 'text/markdown; charset=utf-8');
    expect(response.body, contains('# T-Shirt'));
    expect(response.body, contains('`var_small`'));
  });

  test('supports the Medusa Accept header on the product URL', () async {
    final response = await (client.get('/store/products/t-shirt?country=us')
          ..header('accept', 'text/markdown; q=1.0, application/json'))
        .send();

    response
      ..assertOk()
      ..assertHeader('content-type', 'text/markdown; charset=utf-8');
    expect(response.body, contains('# T-Shirt'));
    expect(response.body, contains('`var_small`'));
  });

  test('keeps the product JSON when Markdown is declined', () async {
    final response = await (client.get('/store/products/t-shirt')
          ..header('accept', 'text/markdown; q=0, application/json'))
        .send();

    response
      ..assertOk()
      ..assertJsonContains({'handle': 't-shirt'});
  });

  test('adds the advertised variant at its quoted regional price', () async {
    await queryExecute(
      "INSERT INTO regions (id, name, currency_code, tax_rate, countries) "
      "VALUES ('reg_eu', 'Europe', 'eur', 0, 'dk')",
      [],
    ).execute(database.executor);
    final markdown =
        await client.get('/store/products/t-shirt.md?country=us').send();
    markdown.assertOk();
    expect(markdown.body, contains('| USD 19.99 | In stock | `var_small` |'));

    final buy = RegExp(r'POST `([^`]+)` \(form-encoded\) to (\S+)')
        .firstMatch(markdown.body)!;
    final fields = Uri.splitQueryString(
      buy[1]!.replaceAll('{variant_id}', 'var_small').replaceAll('{n}', '1'),
    );
    final response =
        await (client.post(Uri.parse(buy[2]!).path)..form(fields)).send();

    response.assertOk();
    final cart = CartView.fromJson(response.json! as Map<String, Object?>).cart;
    expect(cart.region.id, 'reg_us');
    expect(cart.items.single.unitPrice, Money.of(1999, 'usd'));
  });

  test('keeps missing products private', () async {
    (await client.get('/store/products/secret-hoodie/markdown').send())
        .assertNotFound();
  });

  test('rejects malformed country selectors', () async {
    (await client.get('/store/products/t-shirt/markdown?country=USA').send())
        .assertBadRequest();
  });
}

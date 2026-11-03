import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('shipping_provider');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await queryExecute('''
INSERT INTO regions (id, name, currency_code, tax_rate, countries)
VALUES ('reg_one', 'Test', 'usd', 0, 'us')
''', []).execute(database.executor);
    await queryExecute('''
INSERT INTO shipping_options (id, region_id, name, amount, currency_code)
VALUES ('so_one', 'reg_one', 'Standard', 500, 'usd')
''', []).execute(database.executor);
    await queryExecute('''
INSERT INTO fulfillment_providers (id, name)
VALUES ('manual', 'Manual Fulfillment')
''', []).execute(database.executor);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('stores one Medusa provider and private data per shipping option',
      () async {
    final rows = await queryRaw(
      'PRAGMA table_info(shipping_option_fulfillment_provider)',
      [],
    ).fetch(database.connection as Executor);

    expect(
      rows.map((row) => row.readIndex<String>(1)),
      containsAll(<String>[
        'shipping_option_id',
        'fulfillment_provider_id',
        'data',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
    expect(rows.singleWhere((row) => row.readIndex<int>(5) == 1), isNotNull);
  });

  test('owns timestamps and prevents ambiguous provider resolution', () async {
    await queryExecute('''
INSERT INTO shipping_option_fulfillment_provider (
  shipping_option_id, fulfillment_provider_id, data
) VALUES ('so_one', 'manual', '{"service":"standard"}')
''', []).execute(database.executor);
    final rows = await queryRaw('''
SELECT created_at, updated_at FROM shipping_option_fulfillment_provider
WHERE shipping_option_id = 'so_one'
''', []).fetch(database.connection as Executor);

    expect(rows.single.readIndex<DateTime>(0).toUtc().isUtc, isTrue);
    expect(rows.single.readIndex<DateTime>(1).toUtc().isUtc, isTrue);
    await expectDbFailure(() => queryExecute('''
INSERT INTO shipping_option_fulfillment_provider (
  shipping_option_id, fulfillment_provider_id
) VALUES ('so_one', 'manual')
''', []).execute(database.executor));
  });
}

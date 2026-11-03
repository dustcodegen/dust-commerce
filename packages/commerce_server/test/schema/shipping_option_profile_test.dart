import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('shipping_profile');
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
INSERT INTO shipping_profile (id, name, type)
VALUES ('sp_one', 'Test Profile', 'custom')
''', []).execute(database.executor);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('stores one Medusa shipping profile per shipping option', () async {
    final rows = await queryRaw(
      'PRAGMA table_info(shipping_option_shipping_profile)',
      [],
    ).fetch(database.connection as Executor);

    expect(
      rows.map((row) => row.readIndex<String>(1)),
      containsAll(<String>[
        'shipping_option_id',
        'shipping_profile_id',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
    expect(rows.singleWhere((row) => row.readIndex<int>(5) == 1), isNotNull);
  });

  test('owns timestamps and prevents ambiguous profile resolution', () async {
    await queryExecute('''
INSERT INTO shipping_option_shipping_profile (
  shipping_option_id, shipping_profile_id
) VALUES ('so_one', 'sp_one')
''', []).execute(database.executor);
    final rows = await queryRaw('''
SELECT created_at, updated_at FROM shipping_option_shipping_profile
WHERE shipping_option_id = 'so_one'
''', []).fetch(database.connection as Executor);

    expect(rows.single.readIndex<DateTime>(0).toUtc().isUtc, isTrue);
    expect(rows.single.readIndex<DateTime>(1).toUtc().isUtc, isTrue);
    await expectDbFailure(() => queryExecute('''
INSERT INTO shipping_option_shipping_profile (
  shipping_option_id, shipping_profile_id
) VALUES ('so_one', 'sp_one')
''', []).execute(database.executor));
  });
}

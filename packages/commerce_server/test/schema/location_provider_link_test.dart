import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('location_provider');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await queryExecute('''
INSERT INTO stock_locations (id, name) VALUES ('sloc_one', 'Main Warehouse')
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

  test('matches Medusa location-provider link fields and identity', () async {
    final rows = await queryRaw(
      'PRAGMA table_info(stock_location_fulfillment_providers)',
      [],
    ).fetch(database.connection as Executor);

    expect(
      rows.map((row) => row.readIndex<String>(1)),
      containsAll(<String>[
        'stock_location_id',
        'fulfillment_provider_id',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
    expect(rows.where((row) => row.readIndex<int>(5) > 0), hasLength(2));
  });

  test('enforces one provider assignment and owns UTC timestamps', () async {
    await queryExecute('''
INSERT INTO stock_location_fulfillment_providers (
  stock_location_id, fulfillment_provider_id
) VALUES ('sloc_one', 'manual')
''', []).execute(database.executor);
    final rows = await queryRaw('''
SELECT created_at, updated_at FROM stock_location_fulfillment_providers
WHERE stock_location_id = 'sloc_one' AND fulfillment_provider_id = 'manual'
''', []).fetch(database.connection as Executor);

    expect(rows.single.readIndex<DateTime>(0).toUtc().isUtc, isTrue);
    expect(rows.single.readIndex<DateTime>(1).toUtc().isUtc, isTrue);
    await expectDbFailure(() => queryExecute('''
INSERT INTO stock_location_fulfillment_providers (
  stock_location_id, fulfillment_provider_id
) VALUES ('sloc_one', 'manual')
''', []).execute(database.executor));
  });
}

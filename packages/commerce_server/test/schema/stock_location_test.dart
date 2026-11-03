import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('stock_location');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('matches the Medusa stock-location entity fields', () async {
    final rows = await queryRaw('PRAGMA table_info(stock_locations)', [])
        .fetch(database.connection as Executor);

    expect(
      rows.map((row) => row.readIndex<String>(1)),
      containsAll(<String>[
        'id',
        'name',
        'address_id',
        'metadata',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
  });

  test('owns timestamps and keeps an address one-to-one while active',
      () async {
    await queryExecute('''
INSERT INTO stock_location_addresses (id, address_1, country_code)
VALUES ('laddr_one', '35 Warehouse Road', 'us')
''', []).execute(database.executor);
    await queryExecute('''
INSERT INTO stock_locations (id, name, address_id, metadata)
VALUES ('sloc_one', 'Main Warehouse', 'laddr_one', '{}')
''', []).execute(database.executor);
    final rows = await queryRaw('''
SELECT created_at, updated_at FROM stock_locations WHERE id = 'sloc_one'
''', []).fetch(database.connection as Executor);

    expect(DateTime.parse(rows.single.readIndex<String>(0)).isUtc, isTrue);
    expect(DateTime.parse(rows.single.readIndex<String>(1)).isUtc, isTrue);
    expect(
      () => queryExecute('''
INSERT INTO stock_locations (id, name, address_id)
VALUES ('sloc_duplicate', 'Overflow', 'laddr_one')
''', []).execute(database.executor),
      throwsStateError,
    );

    await queryExecute('''
INSERT INTO stock_locations (id, name)
VALUES ('sloc_addressless', 'Digital Operations')
''', []).execute(database.executor);
  });
}

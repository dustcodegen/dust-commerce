import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('location_address');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('matches the Medusa stock-location address fields', () async {
    final rows = await queryRaw(
      'PRAGMA table_info(stock_location_addresses)',
      [],
    ).fetch(database.connection as Executor);

    expect(
      rows.map((row) => row.readIndex<String>(1)),
      containsAll(<String>[
        'id',
        'address_1',
        'address_2',
        'company',
        'city',
        'country_code',
        'phone',
        'postal_code',
        'province',
        'metadata',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
  });

  test('owns UTC timestamps and validates persisted boundaries', () async {
    await queryExecute('''
INSERT INTO stock_location_addresses (
  id, address_1, country_code, metadata
) VALUES ('laddr_one', '35 Warehouse Road', 'us', '{}')
''', []).execute(database.executor);
    final rows = await queryRaw('''
SELECT created_at, updated_at FROM stock_location_addresses
WHERE id = 'laddr_one'
''', []).fetch(database.connection as Executor);

    expect(DateTime.parse(rows.single.readIndex<String>(0)).isUtc, isTrue);
    expect(DateTime.parse(rows.single.readIndex<String>(1)).isUtc, isTrue);
    for (final invalid in <String>[
      '''
INSERT INTO stock_location_addresses (id, address_1, country_code)
VALUES ('laddr_country', 'One', 'US')
''',
      '''
INSERT INTO stock_location_addresses (id, address_1, country_code, metadata)
VALUES ('laddr_json', 'One', 'us', 'not-json')
''',
    ]) {
      expect(
        () => queryExecute(invalid, []).execute(database.executor),
        throwsStateError,
      );
    }
  });
}

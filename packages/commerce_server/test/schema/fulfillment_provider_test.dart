import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fulfillment_provider');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('matches the Medusa fulfillment-provider entity fields', () async {
    final rows = await queryRaw('PRAGMA table_info(fulfillment_providers)', [])
        .fetch(database.connection as Executor);

    expect(
      rows.map((row) => row.readIndex<String>(1)),
      containsAll(<String>[
        'id',
        'name',
        'metadata',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
  });

  test('owns timestamps and validates provider data', () async {
    await queryExecute('''
INSERT INTO fulfillment_providers (id, name, metadata)
VALUES ('manual', 'Manual Fulfillment', '{}')
''', []).execute(database.executor);
    final rows = await queryRaw('''
SELECT created_at, updated_at FROM fulfillment_providers WHERE id = 'manual'
''', []).fetch(database.connection as Executor);

    expect(DateTime.parse(rows.single.readIndex<String>(0)).isUtc, isTrue);
    expect(DateTime.parse(rows.single.readIndex<String>(1)).isUtc, isTrue);
    expect(
      () => queryExecute('''
INSERT INTO fulfillment_providers (id, name, metadata)
VALUES ('invalid', 'Invalid', 'not-json')
''', []).execute(database.executor),
      throwsStateError,
    );
  });
}

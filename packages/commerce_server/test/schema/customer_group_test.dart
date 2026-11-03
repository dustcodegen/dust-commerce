import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_groups');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('group and membership tables keep final production fields', () async {
    final groups = await _columns(database, 'customer_groups');
    final members = await _columns(database, 'customer_group_customers');

    expect(
      groups,
      containsAll([
        'id',
        'name',
        'created_by',
        'metadata',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
    expect(
      members,
      containsAll([
        'id',
        'customer_group_id',
        'customer_id',
        'created_by',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
  });

  test('database owns timestamps and one active membership', () async {
    await _execute(database, r'''
INSERT INTO customers (id, email, has_account)
VALUES ('cus_ada', 'ada@example.com', 1)
''');
    await _execute(database, r'''
INSERT INTO customer_groups (id, name)
VALUES ('cusgrp_vip', 'VIP')
''');
    await _execute(database, r'''
INSERT INTO customer_group_customers
  (id, customer_group_id, customer_id)
VALUES ('cgc_1', 'cusgrp_vip', 'cus_ada')
''');

    final timestamps = await queryRaw(r'''
SELECT created_at, updated_at FROM customer_groups WHERE id = 'cusgrp_vip'
UNION ALL
SELECT created_at, updated_at FROM customer_group_customers WHERE id = 'cgc_1'
''', []).fetch(database.connection as Executor);
    for (final row in timestamps) {
      expect(DateTime.parse(row.readIndex<String>(0)).isUtc, isTrue);
      expect(DateTime.parse(row.readIndex<String>(1)).isUtc, isTrue);
    }

    Future<void> duplicate() => _execute(database, r'''
INSERT INTO customer_group_customers
  (id, customer_group_id, customer_id)
VALUES ('cgc_2', 'cusgrp_vip', 'cus_ada')
''');
    await expectLater(duplicate, throwsStateError);

    await _execute(database, r'''
UPDATE customer_group_customers
SET deleted_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = 'cgc_1'
''');
    await duplicate();
  });
}

Future<List<String>> _columns(CommerceDatabase database, String table) async {
  final rows = await queryRaw('PRAGMA table_info($table)', [])
      .fetch(database.connection as Executor);
  return rows.map((row) => row.readIndex<String>(1)).toList();
}

Future<void> _execute(CommerceDatabase database, String sql) =>
    queryExecute(sql, []).execute(database.executor);

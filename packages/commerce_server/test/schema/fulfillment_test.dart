import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fulfillment_schema');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('stores the Medusa fulfillment record without command-only fields',
      () async {
    final rows = await queryRaw('PRAGMA table_info(fulfillments)', [])
        .fetch(database.connection as Executor);
    final columns = rows.map((row) => row.readIndex<String>(1)).toList();

    expect(
      columns,
      containsAll(<String>[
        'id',
        'order_id',
        'location_id',
        'provider_id',
        'shipping_option_id',
        'requires_shipping',
        'packed_at',
        'shipped_at',
        'delivered_at',
        'canceled_at',
        'canceled_by',
        'marked_shipped_by',
        'created_by',
        'data',
        'metadata',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
    expect(columns, isNot(contains('no_notification')));
  });

  test('owns timestamps and rejects contradictory lifecycle state', () async {
    await _seedOrder(database);
    await queryExecute('''
INSERT INTO fulfillments (
  id, order_id, location_id, provider_id, requires_shipping, data, metadata
) VALUES (
  'ful_one', 'ord_one', 'loc_default', 'manual', 1, '{}', '{}'
)
''', []).execute(database.executor);

    final rows = await queryRaw('''
SELECT created_at, updated_at, requires_shipping
FROM fulfillments WHERE id = 'ful_one'
''', []).fetch(database.connection as Executor);
    final row = rows.single;
    expect(row.readIndex<DateTime>(0).toUtc().isUtc, isTrue);
    expect(row.readIndex<DateTime>(1).toUtc().isUtc, isTrue);
    expect(row.readIndex<int>(2), 1);

    await expectDbFailure(() => queryExecute('''
INSERT INTO fulfillments (
  id, order_id, location_id, provider_id, shipped_at, canceled_at
) VALUES (
  'ful_bad', 'ord_one', 'loc_default', 'manual',
  '2026-09-14T01:00:00.000Z', '2026-09-14T02:00:00.000Z'
)
''', []).execute(database.executor));

    await queryExecute('''
INSERT INTO admin_users (id, email) VALUES ('admin_one', 'admin@example.com')
''', []).execute(database.executor);
    await expectDbFailure(() => queryExecute('''
UPDATE fulfillments SET canceled_by = 'admin_one' WHERE id = 'ful_one'
''', []).execute(database.executor));
  });
}

Future<void> _seedOrder(CommerceDatabase database) async {
  for (final statement in <String>[
    '''
INSERT INTO regions (id, name, currency_code, tax_rate, countries)
VALUES ('reg_one', 'Test', 'usd', 0, 'us')
''',
    '''
INSERT INTO carts (id, region_id, email, completed_at)
VALUES (
  'cart_one', 'reg_one', 'buyer@example.com', '2026-09-14T00:00:00.000Z'
)
''',
    '''
INSERT INTO orders (
  id, display_id, cart_id, region_id, email, currency_code,
  subtotal, shipping_total, discount_total, tax, total, status,
  payment_status, placed_at
) VALUES (
  'ord_one', 1, 'cart_one', 'reg_one', 'buyer@example.com', 'usd',
  1000, 0, 0, 0, 1000, 'completed', 'captured',
  '2026-09-14T00:00:00.000Z'
)
''',
  ]) {
    await queryExecute(statement, []).execute(database.executor);
  }
}

import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('order_archive_schema');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seedOrder(database);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('orders support archived as Medusa lifecycle status', () async {
    await queryExecute(
      "UPDATE orders SET status = 'archived' WHERE id = 'ord_one'",
      [],
    ).execute(database.executor);

    final rows = await queryRaw(
      "SELECT status FROM orders WHERE id = 'ord_one'",
      [],
    ).fetch(database.connection as Executor);
    expect(rows.single.readIndex<String>(0), 'archived');
  });

  test('archiving preserves an existing cancellation audit', () async {
    await queryExecute('''
UPDATE orders
SET status = 'canceled',
    canceled_at = '2026-09-14T04:00:00.000Z',
    canceled_by = 'admin_one'
WHERE id = 'ord_one'
''', []).execute(database.executor);
    await queryExecute(
      "UPDATE orders SET status = 'archived' WHERE id = 'ord_one'",
      [],
    ).execute(database.executor);

    final rows = await queryRaw('''
SELECT status, canceled_at, canceled_by FROM orders WHERE id = 'ord_one'
''', []).fetch(database.connection as Executor);
    expect(rows.single.readIndex<String>(0), 'archived');
    expect(rows.single.readIndex<String>(1), '2026-09-14T04:00:00.000Z');
    expect(rows.single.readIndex<String>(2), 'admin_one');
  });
}

Future<void> _seedOrder(CommerceDatabase database) async {
  for (final statement in <String>[
    "INSERT INTO admin_users (id, email) VALUES ('admin_one', 'a@example.com')",
    '''
INSERT INTO regions (id, name, currency_code, tax_rate, countries)
VALUES ('reg_one', 'Test', 'usd', 0, 'us')
''',
    '''
INSERT INTO carts (id, region_id, email, completed_at)
VALUES ('cart_one', 'reg_one', 'buyer@example.com', '2026-09-14T02:00:00.000Z')
''',
    '''
INSERT INTO orders (
  id, display_id, cart_id, region_id, email, currency_code,
  subtotal, shipping_total, discount_total, tax, total, placed_at
) VALUES (
  'ord_one', 1, 'cart_one', 'reg_one', 'buyer@example.com', 'usd',
  1000, 0, 0, 0, 1000, '2026-09-14T02:00:00.000Z'
)
''',
  ]) {
    await queryExecute(statement, []).execute(database.executor);
  }
}

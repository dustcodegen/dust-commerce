import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('order_cancel_schema');
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

  test('orders store the Medusa cancellation audit', () async {
    final rows = await queryRaw('PRAGMA table_info(orders)', [])
        .fetch(database.connection as Executor);
    final columns = rows.map((row) => row.readIndex<String>(1)).toList();
    expect(columns, containsAll(['canceled_at', 'canceled_by']));

    await queryExecute('''
UPDATE orders
SET status = 'canceled',
    canceled_at = '2026-09-14T04:00:00.000Z',
    canceled_by = 'admin_one'
WHERE id = 'ord_one'
''', []).execute(database.executor);

    final order = await queryRaw('''
SELECT status, canceled_at, canceled_by FROM orders WHERE id = 'ord_one'
''', []).fetch(database.connection as Executor);
    expect(order.single.readIndex<String>(0), 'canceled');
    expect(order.single.readIndex<DateTime>(1).toUtc().isUtc, isTrue);
    expect(order.single.readIndex<String>(2), 'admin_one');
  });

  test('orders reject British spelling and unaudited cancellation', () async {
    await expectDbFailure(() => queryExecute(
          "UPDATE orders SET status = 'cancelled' WHERE id = 'ord_one'",
          [],
        ).execute(database.executor));
    await expectDbFailure(() => queryExecute(
          "UPDATE orders SET status = 'canceled' WHERE id = 'ord_one'",
          [],
        ).execute(database.executor));
  });

  test('payment cancellation and refunds retain separate money facts',
      () async {
    await queryExecute('''
INSERT INTO payment_collections (
  id, order_id, provider, amount, currency_code, status, captured_at
) VALUES (
  'pay_one', 'ord_one', 'manual', 1000, 'usd', 'captured',
  '2026-09-14T03:00:00.000Z'
)
''', []).execute(database.executor);
    await queryExecute('''
UPDATE payment_collections SET status = 'canceled' WHERE id = 'pay_one'
''', []).execute(database.executor);
    await queryExecute('''
INSERT INTO refunds (
  id, payment_collection_id, amount, currency_code, created_by
) VALUES ('ref_one', 'pay_one', 1000, 'usd', 'admin_one')
''', []).execute(database.executor);

    final refund = await queryRaw('''
SELECT amount, currency_code, created_by, created_at
FROM refunds WHERE id = 'ref_one'
''', []).fetch(database.connection as Executor);
    expect(refund.single.readIndex<int>(0), 1000);
    expect(refund.single.readIndex<String>(1), 'usd');
    expect(refund.single.readIndex<String>(2), 'admin_one');
    expect(refund.single.readIndex<DateTime>(3).toUtc().isUtc, isTrue);

    await expectDbFailure(() => queryExecute('''
INSERT INTO refunds (
  id, payment_collection_id, amount, currency_code, created_by
) VALUES ('ref_bad', 'pay_one', 0, 'usd', 'admin_one')
''', []).execute(database.executor));
  });
}

Future<void> _seedOrder(CommerceDatabase database) async {
  for (final statement in <String>[
    '''
INSERT INTO admin_users (id, email)
VALUES ('admin_one', 'admin@example.com')
''',
    '''
INSERT INTO regions (id, name, currency_code, tax_rate, countries)
VALUES ('reg_one', 'Test', 'usd', 0, 'us')
''',
    '''
INSERT INTO carts (id, region_id, email, completed_at)
VALUES (
  'cart_one', 'reg_one', 'buyer@example.com', '2026-09-14T02:00:00.000Z'
)
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

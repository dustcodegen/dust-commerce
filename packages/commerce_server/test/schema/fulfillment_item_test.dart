import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fulfillment_items');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await _seedOrders(database);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('stores Medusa fulfillment-item snapshots', () async {
    final rows = await queryRaw('PRAGMA table_info(fulfillment_items)', [])
        .fetch(database.connection as Executor);

    expect(
      rows.map((row) => row.readIndex<String>(1)),
      containsAll(<String>[
        'id',
        'fulfillment_id',
        'title',
        'quantity',
        'sku',
        'barcode',
        'line_item_id',
        'inventory_item_id',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
  });

  test('guards active quantity and order ownership', () async {
    await _insertItem(database, id: 'fulitem_one', quantity: 2);
    final rows = await queryRaw(r'''
SELECT created_at, quantity FROM fulfillment_items WHERE id = 'fulitem_one'
''', []).fetch(database.connection as Executor);
    expect(rows.single.readIndex<DateTime>(0).toUtc().isUtc, isTrue);
    expect(rows.single.readIndex<int>(1), 2);

    await expectDbFailure(
      () => _insertItem(database, id: 'fulitem_duplicate', quantity: 1),
    );
    await expectDbFailure(() => _insertItem(
          database,
          id: 'fulitem_excess',
          quantity: 2,
          fulfillmentId: 'ful_two',
        ));
    await expectDbFailure(() => _insertItem(
          database,
          id: 'fulitem_foreign',
          quantity: 1,
          fulfillmentId: 'ful_two',
          lineItemId: 'item_two',
        ));
    await expectDbFailure(() => queryExecute(
          "UPDATE fulfillments SET order_id = 'ord_two' WHERE id = 'ful_one'",
          [],
        ).execute(database.executor));

    await queryExecute(
      "UPDATE fulfillments SET canceled_at = "
      "'2026-09-14T03:00:00.000Z' WHERE id = 'ful_one'",
      [],
    ).execute(database.executor);
    await _insertItem(
      database,
      id: 'fulitem_replacement',
      quantity: 3,
      fulfillmentId: 'ful_two',
    );
  });
}

Future<Result<ExecResult, SqlxError>> _insertItem(
  CommerceDatabase database, {
  required String id,
  required int quantity,
  String fulfillmentId = 'ful_one',
  String lineItemId = 'item_one',
}) =>
    queryExecute(r'''
INSERT INTO fulfillment_items (
  id, fulfillment_id, title, quantity, sku, barcode, line_item_id
) VALUES (
  $1, $2, 'Sample tee', $3, 'TEE-S', '0123456789', $4
)
''', [id, fulfillmentId, quantity, lineItemId]).execute(database.executor);

Future<void> _seedOrders(CommerceDatabase database) async {
  for (final statement in <String>[
    '''
INSERT INTO regions (id, name, currency_code, tax_rate, countries)
VALUES ('reg_one', 'Test', 'usd', 0, 'us')
''',
    '''
INSERT INTO carts (id, region_id, email, completed_at) VALUES
  ('cart_one', 'reg_one', 'one@example.com', '2026-09-14T00:00:00.000Z'),
  ('cart_two', 'reg_one', 'two@example.com', '2026-09-14T00:00:00.000Z')
''',
    '''
INSERT INTO orders (
  id, display_id, cart_id, region_id, email, currency_code, subtotal,
  shipping_total, discount_total, tax, total, status, payment_status, placed_at
) VALUES
  ('ord_one', 1, 'cart_one', 'reg_one', 'one@example.com', 'usd',
   3000, 0, 0, 0, 3000, 'completed', 'captured', '2026-09-14T00:00:00.000Z'),
  ('ord_two', 2, 'cart_two', 'reg_one', 'two@example.com', 'usd',
   1000, 0, 0, 0, 1000, 'completed', 'captured', '2026-09-14T00:00:00.000Z')
''',
    '''
INSERT INTO order_items (
  id, order_id, variant_id, product_id, product_handle, title,
  unit_amount, currency_code, quantity
) VALUES
  ('item_one', 'ord_one', 'var_one', 'prod_one', 'sample', 'Sample tee',
   1000, 'usd', 3),
  ('item_two', 'ord_two', 'var_two', 'prod_two', 'other', 'Other tee',
   1000, 'usd', 1)
''',
    '''
INSERT INTO fulfillments (id, order_id, location_id, provider_id)
VALUES
  ('ful_one', 'ord_one', 'loc_default', 'manual'),
  ('ful_two', 'ord_one', 'loc_default', 'manual')
''',
  ]) {
    await queryExecute(statement, []).execute(database.executor);
  }
}

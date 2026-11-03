import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('fulfillment_label');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('stores Medusa shipment labels with database-owned timestamps',
      () async {
    await _seedFulfillment(database);
    await queryExecute(r'''
INSERT INTO fulfillment_labels (
  id, fulfillment_id, tracking_number, tracking_url, label_url
) VALUES (
  'ful_label_one', 'ful_one', 'TRACK-123',
  'https://carrier.example/TRACK-123', '#'
)
''', []).execute(database.executor);

    final rows = await queryRaw(r'''
SELECT tracking_number, tracking_url, label_url, created_at, updated_at
FROM fulfillment_labels WHERE id = 'ful_label_one'
''', []).fetch(database.connection as Executor);
    final row = rows.single;
    expect(row.readIndex<String>(0), 'TRACK-123');
    expect(row.readIndex<String>(1), 'https://carrier.example/TRACK-123');
    expect(row.readIndex<String>(2), '#');
    expect(row.readIndex<DateTime>(3).toUtc().isUtc, isTrue);
    expect(row.readIndex<DateTime>(4), row.readIndex<DateTime>(3));
  });

  test('removes labels with their fulfillment', () async {
    await _seedFulfillment(database);
    await queryExecute(r'''
INSERT INTO fulfillment_labels (
  id, fulfillment_id, tracking_number, tracking_url, label_url
) VALUES ('ful_label_one', 'ful_one', '', '', '')
''', []).execute(database.executor);

    await queryExecute(
      "DELETE FROM fulfillments WHERE id = 'ful_one'",
      [],
    ).execute(database.executor);

    final count = await queryScalar<int>(
      'SELECT count(*) FROM fulfillment_labels',
      [],
    ).fetchOne(database.connection as Executor);
    expect(count, const Ok<int, SqlxError>(0));
  });

  test('rejects stored-script label links', () async {
    await _seedFulfillment(database);

    await expectDbFailure(() => queryExecute(r'''
INSERT INTO fulfillment_labels (
  id, fulfillment_id, tracking_number, tracking_url, label_url
) VALUES (
  'ful_label_bad', 'ful_one', 'TRACK-123', 'javascript:alert(1)', '#'
)
''', []).execute(database.executor));
  });
}

Future<void> _seedFulfillment(CommerceDatabase database) async {
  for (final statement in <String>[
    r'''
INSERT INTO regions (id, name, currency_code, tax_rate, countries)
VALUES ('reg_one', 'Test', 'usd', 0, 'us')
''',
    r'''
INSERT INTO carts (id, region_id, email, completed_at)
VALUES (
  'cart_one', 'reg_one', 'buyer@example.com', '2026-09-14T00:00:00.000Z'
)
''',
    r'''
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
    r'''
INSERT INTO fulfillments (id, order_id, location_id, provider_id)
VALUES ('ful_one', 'ord_one', 'loc_default', 'manual')
''',
  ]) {
    await queryExecute(statement, []).execute(database.executor);
  }
}

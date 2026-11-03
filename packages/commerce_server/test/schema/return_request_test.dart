import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_returns');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('return requests preserve Medusa item and lifecycle boundaries',
      () async {
    final requests = await queryRaw('PRAGMA table_info(return_requests)', [])
        .fetch(database.connection as Executor);
    final requestColumns =
        requests.map((row) => row.readIndex<String>(1)).toList();
    final items = await queryRaw('PRAGMA table_info(return_items)', [])
        .fetch(database.connection as Executor);
    final itemColumns = items.map((row) => row.readIndex<String>(1)).toList();

    expect(
      requestColumns,
      containsAll(<String>[
        'id',
        'display_id',
        'order_id',
        'customer_id',
        'status',
        'requested_at',
        'received_at',
        'canceled_at',
      ]),
    );
    expect(
      itemColumns,
      containsAll(<String>[
        'return_id',
        'order_item_id',
        'quantity',
        'received_quantity',
        'damaged_quantity',
        'reason_id',
      ]),
    );
  });
}

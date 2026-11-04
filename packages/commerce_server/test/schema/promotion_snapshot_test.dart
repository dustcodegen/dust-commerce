import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  test('applied promotions freeze their customer-facing policy', () async {
    final directory = await Directory.systemTemp.createTemp('promotion_schema');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });

    final rows = await queryRaw('PRAGMA table_info(cart_promotions)', [])
        .fetch(database.connection as Executor);
    final columns = rows.map((row) => row.readIndex<String>(1));

    expect(
      columns,
      containsAll(
        ['promotion_id', 'code', 'type', 'value', 'currency_code', 'amount'],
      ),
    );
  });
}

import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  test('products reference normalized product types', () async {
    final directory = await Directory.systemTemp.createTemp('product_type');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });

    final foreignKeys = await queryRaw(
      'PRAGMA foreign_key_list(products)',
      const [],
    ).fetch(database.connection as Executor);

    expect(
      foreignKeys.any(
        (row) =>
            row.read<String>('table') == 'product_types' &&
            row.read<String>('from') == 'type_id' &&
            row.read<String>('to') == 'id',
      ),
      isTrue,
    );
  });
}

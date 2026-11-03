import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  test('updated_at is maintained by SQLite on mutable rows', () async {
    final directory = await Directory.systemTemp.createTemp('commerce_touch');
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    addTearDown(() async {
      await database.close();
      await directory.delete(recursive: true);
    });

    await queryExecute(
      "INSERT INTO regions (id, name, currency_code, tax_rate, countries, "
      "created_at, updated_at) VALUES ('reg_1', 'Old', 'usd', 0, 'us', "
      "'2000-01-01T00:00:00.000Z', '2000-01-01T00:00:00.000Z')",
      [],
    ).execute(database.executor);
    await queryExecute("UPDATE regions SET name = 'New' WHERE id = 'reg_1'", [])
        .execute(database.executor);

    final rows = await queryRaw(
      "SELECT created_at, updated_at FROM regions WHERE id = 'reg_1'",
      [],
    ).fetch(database.connection as Executor);
    expect(rows.single.readIndex<String>(0), '2000-01-01T00:00:00.000Z');
    expect(rows.single.readIndex<String>(1), isNot('2000-01-01T00:00:00.000Z'));
  });
}

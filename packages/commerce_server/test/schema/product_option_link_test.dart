import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('product_option_link');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    await queryExecute(
      r"INSERT INTO products (id, title, handle) VALUES ('prod_1', 'T', 't')",
      [],
    ).execute(database.executor);
    await queryExecute(
      'INSERT INTO product_options (id, title) VALUES '
      r"('opt_size', 'Size'), ('opt_color', 'Color')",
      [],
    ).execute(database.executor);
    await queryExecute(
      'INSERT INTO product_option_values (id, option_id, value, rank) VALUES '
      r"('val_s', 'opt_size', 'S', 0), "
      r"('val_black', 'opt_color', 'Black', 0)",
      [],
    ).execute(database.executor);
    await queryExecute(
      'INSERT INTO product_product_options '
      r"(id, product_id, product_option_id) VALUES ('link_1', 'prod_1', 'opt_size')",
      [],
    ).execute(database.executor);
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('a product option cannot expose a value from another option', () async {
    Future<Result<ExecResult, SqlxError>> mismatch() => queryExecute(
          'INSERT INTO product_product_option_values '
          '(id, product_product_option_id, product_option_value_id) '
          r"VALUES ('availability_1', 'link_1', 'val_black')",
          [],
        ).execute(database.executor);

    await expectDbFailure(mismatch);
  });
}

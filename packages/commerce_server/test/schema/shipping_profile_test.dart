import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import '../support/expect_result.dart';

void main() {
  late CommerceDatabase database;
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('shipping_profile');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('matches Medusa shipping-profile and product-link fields', () async {
    final profiles = await queryRaw('PRAGMA table_info(shipping_profile)', [])
        .fetch(database.connection as Executor);
    final links = await queryRaw(
      'PRAGMA table_info(product_shipping_profile)',
      [],
    ).fetch(database.connection as Executor);

    expect(
      profiles.map((row) => row.readIndex<String>(1)),
      containsAll([
        'id',
        'name',
        'type',
        'metadata',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
    expect(
      links.map((row) => row.readIndex<String>(1)),
      containsAll([
        'id',
        'product_id',
        'shipping_profile_id',
        'created_at',
        'updated_at',
        'deleted_at',
      ]),
    );
  });

  test('allows only one active shipping profile per product', () async {
    await queryExecute(
      "INSERT INTO shipping_profile (id, name, type) "
      "VALUES ('sp_digital', 'Digital', 'digital')",
      [],
    ).execute(database.executor);
    await queryExecute('''
INSERT INTO products (id, title, handle)
VALUES ('prod_one', 'One', 'one')
''', []).execute(database.executor);
    final assigned = await queryRaw(
      "SELECT shipping_profile_id FROM product_shipping_profile "
      "WHERE product_id = 'prod_one' AND deleted_at IS NULL",
      [],
    ).fetch(database.connection as Executor);
    expect(assigned.single.readIndex<String>(0), 'sp_default');

    await expectDbFailure(() => queryExecute('''
INSERT INTO product_shipping_profile (id, product_id, shipping_profile_id)
VALUES ('prodsp_two', 'prod_one', 'sp_digital')
''', []).execute(database.executor));
  });
}

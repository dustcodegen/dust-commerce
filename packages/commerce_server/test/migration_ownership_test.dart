import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

import 'support/sqlx_database.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_sqlx_owner');
  });

  tearDown(() => directory.delete(recursive: true));

  test('connects without replaying migrations after SQLx owns history',
      () async {
    final path = '${directory.path}/commerce.db';
    final setup = await openTestDatabase(path, options: commerceOptions);
    await recordSqlxHistoryForTest(setup, commerceSqlxMigrationVersions);
    await setup.close();

    final database = CommerceDatabase.connect(
      isolatedTestDatabaseUrl(commerceTestDatabaseUrl(), path),
      options: commerceOptions,
    );
    addTearDown(database.close);

    await requireCommerceSqlxMigrations(database);
    final products = await queryScalar<int>('SELECT COUNT(*) FROM products', [])
        .fetchOne(database.connection as Executor);
    expect(products, const Ok<int, SqlxError>(0));
  });

  test('applies Dust migrations when SQLx history is absent', () async {
    final database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
    addTearDown(database.close);

    await requireCommerceSqlxMigrations(database);
    final products = await queryScalar<int>('SELECT COUNT(*) FROM products', [])
        .fetchOne(database.connection as Executor);
    expect(products, const Ok<int, SqlxError>(0));
  });

  test('production options do not create a missing database', () async {
    final url = isolatedTestDatabaseUrl(
      commerceTestDatabaseUrl(),
      '${directory.path}/missing.db',
    );
    final database = CommerceDatabase.connect(url, options: commerceSqlxOptions);
    addTearDown(database.close);

    final result = await database.unsafe.fetch('SELECT 1', const []);
    expect(result.isErr, isTrue);
  });

  test('rejects incomplete SQLx migration history', () async {
    final path = '${directory.path}/commerce.db';
    final setup = await openTestDatabase(path, options: commerceOptions);
    await recordSqlxHistoryForTest(
      setup,
      commerceSqlxMigrationVersions.take(
        commerceSqlxMigrationVersions.length - 1,
      ),
    );
    await setup.close();
    final database = CommerceDatabase.connect(
      isolatedTestDatabaseUrl(commerceTestDatabaseUrl(), path),
      options: commerceOptions,
    );
    addTearDown(database.close);

    await expectLater(
      requireCommerceSqlxMigrations(database),
      throwsA(isA<StateError>()),
    );
  });
}

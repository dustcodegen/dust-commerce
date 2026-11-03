import 'dart:io';

import 'package:dust_db_postgres/dust_db_postgres.dart';

import 'database.dart';

/// Opens a migrated database isolated by the legacy temporary path.
Future<CommerceDatabase> openTestDatabase(
  String path, {
  PgConnectOptions? options,
}) async {
  final url = isolatedTestDatabaseUrl(commerceTestDatabaseUrl(), path);
  await ensureTestDatabase(url);
  final database = CommerceDatabase.connect(url, options: options);
  await migrateCommerceDatabase(database);
  return database;
}

/// Uses PostgreSQL databases instead of sharing one mutable test database.
String isolatedTestDatabaseUrl(String baseUrl, String path) {
  final base = Uri.parse(baseUrl);
  final identity = path.hashCode & 0x7fffffff;
  final name = 'dust_test_${pid}_$identity';
  return base.replace(path: '/$name').toString();
}

/// Creates an isolated test database before migrations run.
Future<void> ensureTestDatabase(String url) async {
  final uri = Uri.parse(url);
  final userInfo = uri.userInfo.split(':');
  final environment = <String, String>{
    ...Platform.environment,
    if (userInfo.length > 1) 'PGPASSWORD': userInfo[1],
    if (uri.queryParameters['sslmode'] case final sslMode?)
      'PGSSLMODE': sslMode,
  };
  final result = await Process.run(
    'createdb',
    <String>[
      '--host=${uri.host}',
      '--port=${uri.hasPort ? uri.port : 5432}',
      '--username=${userInfo.first}',
      '--maintenance-db=postgres',
      '--no-password',
      uri.pathSegments.single,
    ],
    environment: environment,
  );
  if (result.exitCode != 0 &&
      !result.stderr.toString().contains('already exists')) {
    throw StateError(
      'Could not create isolated Postgres test database '
      '${uri.pathSegments.single}: ${result.stderr}',
    );
  }
}

import 'dart:io';

import 'package:commerce_server/commerce_server.dart';

/// Records production-shaped SQLx history around a schema prepared for tests.
Future<void> recordSqlxHistoryForTest(
  CommerceDatabase database,
  Iterable<int> versions,
) async {
  await queryExecute(r'''
CREATE TABLE _sqlx_migrations (
  version BIGINT PRIMARY KEY,
  description TEXT NOT NULL,
  installed_on TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  success BOOLEAN NOT NULL,
  checksum BYTEA NOT NULL,
  execution_time BIGINT NOT NULL
)
''', []).execute(database.connection);
  for (final version in versions) {
    await queryExecute(
      'INSERT INTO _sqlx_migrations '
      '(version, description, success, checksum, execution_time) '
      "VALUES ($version, 'test', TRUE, decode('00', 'hex'), 0)",
      const [],
    ).execute(database.connection);
  }
}

/// Removes one disposable database created by an isolated test.
Future<void> dropTestDatabase(String url) async {
  final uri = Uri.parse(url);
  final userInfo = uri.userInfo.split(':');
  final environment = <String, String>{
    ...Platform.environment,
    if (userInfo.length > 1) 'PGPASSWORD': userInfo[1],
    if (uri.queryParameters['sslmode'] case final sslMode?)
      'PGSSLMODE': sslMode,
  };
  final result = await Process.run(
    'dropdb',
    <String>[
      '--host=${uri.host}',
      '--port=${uri.hasPort ? uri.port : 5432}',
      '--username=${userInfo.first}',
      '--no-password',
      '--if-exists',
      uri.pathSegments.single,
    ],
    environment: environment,
  );
  if (result.exitCode != 0) {
    throw StateError(
      'Could not drop isolated Postgres test database '
      '${uri.pathSegments.single}: ${result.stderr}',
    );
  }
}

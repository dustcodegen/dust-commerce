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

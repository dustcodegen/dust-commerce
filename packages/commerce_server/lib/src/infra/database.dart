import 'dart:async';
import 'dart:io';

import 'package:dust_dart/db.dart';
import 'package:dust_db_postgres/dust_db_postgres.dart';

export 'raw_query.dart';

part 'database.g.dart';

/// The application's PostgreSQL database and embedded migration manifest.
@SqlxDatabase(type: SqlxDatabaseType.postgres, migrations: './migrations')
abstract class CommerceDatabase implements DatabaseClient {
  /// Creates a PostgreSQL pool from [url].
  factory CommerceDatabase.connect(
    String url, {
    PgConnectOptions? options,
  }) = _$CommerceDatabase.connect;

  /// The pool-backed connection used by generated DAOs.
  @override
  Connection get connection;

  /// Legacy test entry point; PostgreSQL ignores the old SQLite file name.
  @Deprecated('Use connect with COMMERCE_DATABASE_URL in new code.')
  static CommerceDatabase open(
    String _, {
    PgConnectOptions? options,
  }) {
    final database =
        CommerceDatabase.connect(_testDatabaseUrl(), options: options);
    unawaited(migrateCommerceDatabase(database));
    return database;
  }

  /// Legacy SQLx test entry point retained while those tests migrate to Dust.
  @Deprecated('Use connect in new code.')
  static CommerceDatabase connectSqlx(
    String _, {
    PgConnectOptions? options,
  }) {
    final database =
        CommerceDatabase.connect(_testDatabaseUrl(), options: options);
    unawaited(migrateCommerceDatabase(database));
    return database;
  }
}

String _testDatabaseUrl() =>
    Platform.environment['COMMERCE_TEST_DATABASE_URL'] ??
    Platform.environment['DUST_DATABASE_URL'] ??
    'postgres://dust:dust@127.0.0.1:5432/dust_commerce?sslmode=disable';

/// Returns the configured database URL for isolated test connections.
String commerceTestDatabaseUrl() => _testDatabaseUrl();

/// Historical SQLx migration versions kept for old ownership tests.
const commerceSqlxMigrationVersions = <int>[
  20260905120626,
  20260905120627,
  20260905120628,
  20260905120629,
  20260905120630,
  20260905120631,
  20260905120632,
  20260905120633,
  20260905120634,
  20260905120635,
  20260905120636,
  20260905120637,
  20260905120638,
  20260905120639,
  20260905120640,
  20260905120641,
  20260905120642,
  20260905120643,
  20260905120644,
  20260905120645,
  20260905120646,
  20260905120647,
  20260905120648,
  20260905120649,
  20260905120650,
  20260905120651,
  20260905120652,
  20260905120653,
  20260905120654,
  20260905120655,
  20260906120000,
  20260906120001,
  20260906120002,
  20260906150001,
  20260906150002,
  20260906150003,
  20260907120000,
  20260907120001,
  20260907180000,
  20260913140000,
  20260913150000,
  20260913150001,
  20260913150002,
  20260913150003,
  20260913150004,
  20260913150005,
  20260914120000,
  20260914120001,
  20260914120002,
  20260914130000,
  20260914130001,
  20260914130002,
  20260914130003,
  20260914130004,
  20260914130005,
  20260914130006,
  20260914130007,
  20260914130008,
  20260914130009,
  20260914130010,
  20260914170000,
  20260914170001,
  20260915100000,
  20260915110000,
  20261104120000,
];

/// Legacy alias retained for migration-ownership tests.
const PgConnectOptions commerceSqlxOptions = commerceOptions;

/// Legacy migration gate now delegates to Dust's embedded PostgreSQL migrator.
Future<void> requireCommerceSqlxMigrations(CommerceDatabase database) async {
  await migrateCommerceDatabase(database);
}

/// Applies all committed migrations before the server accepts traffic.
///
/// Existing deployments may already have SQLx's `_sqlx_migrations` table. In
/// that case the validated SQLx history remains authoritative and Dust does
/// not replay the same DDL into an already-populated PostgreSQL schema.
Future<void> migrateCommerceDatabase(CommerceDatabase database) async {
  // dust:allow-unsafe-sql — fixed migration-history inspection has no input.
  final tableResult = await database.unsafe.fetch(
    "SELECT EXISTS (SELECT 1 FROM information_schema.tables "
    "WHERE table_schema = 'public' AND table_name = '_sqlx_migrations') "
    'AS present',
    const [],
  );
  final tableRows = switch (tableResult) {
    Ok(:final value) => value,
    Err(:final error) => throw StateError(
        'Could not inspect PostgreSQL migration history: $error',
      ),
  };
  final sqlxHistoryExists = tableRows.single.readBool('present');
  if (sqlxHistoryExists) {
    // dust:allow-unsafe-sql — fixed migration-history inspection has no input.
    final historyResult = await database.unsafe.fetch(
      'SELECT version, success FROM _sqlx_migrations ORDER BY version',
      const [],
    );
    final historyRows = switch (historyResult) {
      Ok(:final value) => value,
      Err(:final error) => throw StateError(
          'Could not read PostgreSQL migration history: $error',
        ),
    };
    final versions = [
      for (final row in historyRows)
        if (row.readBool('success')) row.read<int>('version'),
    ];
    if (versions.length != commerceSqlxMigrationVersions.length ||
        versions.any(
            (version) => !commerceSqlxMigrationVersions.contains(version))) {
      throw StateError(
        'PostgreSQL migration history is incomplete or contains a failed '
        'migration; run `sqlx migrate run` before starting dust-commerce.',
      );
    }
    return;
  }

  final result = await database.migrate();
  switch (result) {
    case Ok():
      return;
    case Err(:final error):
      throw StateError('PostgreSQL migrations failed: $error');
  }
}

/// Explicit production pool settings. TLS remains URL-controlled so local
/// development can use `sslmode=disable` without weakening production URLs.
const commerceOptions = PgConnectOptions(
  connectTimeout: Duration(seconds: 5),
  queryTimeout: Duration(seconds: 30),
  applicationName: 'dust-commerce',
  maxConnections: 10,
);

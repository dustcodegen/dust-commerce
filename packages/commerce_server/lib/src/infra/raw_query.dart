import 'package:dust_dart/db.dart';

/// Compatibility query used by pre-0.3 tests and migration probes.
final class CommerceRawQuery {
  /// Creates one compatibility query.
  const CommerceRawQuery(this.sql, this.parameters);

  /// SQL text executed by the compatibility path.
  final String sql;

  /// Positional values bound to [sql].
  final List<Object?> parameters;

  /// Executes the query and unwraps Dust's result for legacy tests.
  Future<List<Row>> fetch(Executor executor) async {
    final query = _postgresQuery(sql, parameters);
    final result = await executor.fetchAll<Row>(
      query.sql,
      query.parameters,
      (row) => row,
    );
    return switch (result) {
      Ok(:final value) => value,
      Err(:final error) => throw StateError('Raw query failed: $error'),
    };
  }
}

/// Creates a compatibility raw query for legacy tests.
CommerceRawQuery queryRaw(String sql, List<Object?> parameters) =>
    CommerceRawQuery(sql, parameters);

({String sql, List<Object?> parameters}) _postgresQuery(
  String sql,
  List<Object?> parameters,
) {
  final pragma = RegExp(
    r'^\s*PRAGMA\s+table_info\(([^)]+)\)\s*$',
    caseSensitive: false,
  ).firstMatch(sql);
  if (pragma != null) {
    return (
      sql: r'''
SELECT ordinal_position - 1 AS cid,
       column_name AS name,
       data_type AS type,
       is_nullable,
       column_default AS dflt_value,
       CASE WHEN EXISTS (
         SELECT 1
         FROM pg_index i
         JOIN pg_attribute a ON a.attrelid = i.indrelid
         WHERE i.indrelid = (c.table_schema || '.' || c.table_name)::regclass
           AND i.indisprimary AND a.attnum = ANY(i.indkey)
           AND a.attname = c.column_name
       ) THEN 1 ELSE 0 END AS pk
FROM information_schema.columns c
WHERE c.table_schema = 'public' AND c.table_name = $1
ORDER BY c.ordinal_position
''',
      parameters: [pragma.group(1)!.trim()],
    );
  }
  final foreignKeys = RegExp(
    r'^\s*PRAGMA\s+foreign_key_list\(([^)]+)\)\s*$',
    caseSensitive: false,
  ).firstMatch(sql);
  if (foreignKeys != null) {
    return (
      sql: r'''
SELECT 0 AS id, 0 AS seq, ccu.table_name AS table,
       kcu.column_name AS from, ccu.column_name AS to,
       'NO ACTION' AS on_update, 'NO ACTION' AS on_delete,
       'NONE' AS match
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
  ON kcu.constraint_name = tc.constraint_name
 AND kcu.table_schema = tc.table_schema
JOIN information_schema.constraint_column_usage ccu
  ON ccu.constraint_name = tc.constraint_name
 AND ccu.table_schema = tc.table_schema
WHERE tc.table_schema = 'public'
  AND tc.table_name = $1
  AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY kcu.ordinal_position
''',
      parameters: [foreignKeys.group(1)!.trim()],
    );
  }
  if (sql.toLowerCase().contains('from sqlite_master')) {
    return (
      sql: "SELECT table_name AS name FROM information_schema.tables "
          "WHERE table_schema = 'public' AND table_type = 'BASE TABLE' "
          'ORDER BY table_name',
      parameters: const [],
    );
  }
  return (
    sql: _questionMarksToPostgres(sql),
    parameters: parameters,
  );
}

String _questionMarksToPostgres(String sql) {
  var parameter = 0;
  var singleQuote = false;
  final output = StringBuffer();
  for (var index = 0; index < sql.length; index++) {
    final character = sql[index];
    if (character == "'") {
      if (singleQuote && index + 1 < sql.length && sql[index + 1] == "'") {
        output
          ..write(character)
          ..write(sql[++index]);
        continue;
      }
      singleQuote = !singleQuote;
      output.write(character);
      continue;
    }
    if (character == '?' && !singleQuote) {
      output.write('\$${++parameter}');
    } else {
      output.write(character);
    }
  }
  return output.toString();
}

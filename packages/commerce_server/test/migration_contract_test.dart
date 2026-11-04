import 'dart:io';

import 'package:test/test.dart';

void main() {
  final migrations = Directory('migrations').existsSync()
      ? Directory('migrations')
      : Directory('packages/commerce_server/migrations');

  test('each timestamped migration owns one final table and one reverse', () {
    final files = migrations
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.sql'))
        .toList()
      ..sort((left, right) => left.path.compareTo(right.path));
    final ups = files.where((file) => file.path.endsWith('.up.sql')).toList();
    final downs =
        files.where((file) => file.path.endsWith('.down.sql')).toList();

    expect(ups, hasLength(64));
    expect(downs, hasLength(ups.length));
    final versions =
        ups.map((file) => file.uri.pathSegments.last.split('_').first).toList();
    expect(versions.toSet(), hasLength(versions.length));

    for (final up in ups) {
      final name = up.uri.pathSegments.last;
      final sql = up.readAsStringSync();
      final down = File(up.path.replaceFirst('.up.sql', '.down.sql'));

      expect(name, matches(RegExp(r'^\d{14}_[a-z0-9_]+\.up\.sql$')),
          reason: name);
      expect(
          RegExp(r'\bCREATE\s+TABLE\b', caseSensitive: false).allMatches(sql),
          hasLength(1),
          reason: name);
      expect(sql,
          isNot(matches(RegExp(r'\bALTER\s+TABLE\b', caseSensitive: false))),
          reason: name);
      expect(
          sql,
          isNot(
              matches(RegExp(r'\bGENERATED\s+ALWAYS\b', caseSensitive: false))),
          reason: name);
      expect(sql.trimLeft(), startsWith('--'), reason: name);
      expect(down.existsSync(), isTrue, reason: name);
      expect(down.readAsStringSync().trimLeft(), startsWith('--'),
          reason: name);

      if (sql.contains('updated_at')) {
        expect(
          sql,
          matches(RegExp(r'\bCREATE\s+TRIGGER\b', caseSensitive: false)),
          reason: '$name must maintain updated_at inside its table migration',
        );
      }
    }
  });
}

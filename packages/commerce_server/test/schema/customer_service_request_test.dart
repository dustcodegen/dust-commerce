import 'dart:io';

import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late CommerceDatabase database;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('commerce_support');
    database = await openTestDatabase(
      '${directory.path}/commerce.db',
      options: commerceOptions,
    );
  });

  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test('support table keeps the final auditable request fields', () async {
    final rows = await queryRaw(
      'PRAGMA table_info(customer_service_requests)',
      [],
    ).fetch(database.connection as Executor);

    expect(
      rows.map((row) => row.readIndex<String>(1)),
      containsAll(<String>[
        'id',
        'customer_id',
        'name',
        'email',
        'subject',
        'message',
        'order_reference',
        'status',
        'resolved_at',
        'created_at',
        'updated_at',
      ]),
    );
  });

  test('database owns lifecycle timestamps and resolution consistency',
      () async {
    await _execute(database, r'''
INSERT INTO customer_service_requests
  (id, name, email, subject, message)
VALUES
  ('csreq_01', 'Ada', 'ada@example.com', 'Order', 'Where is it?')
''');

    final initial = await _request(database, 'csreq_01');
    expect(initial.read<String>('status'), 'open');
    expect(initial.read<DateTime>('created_at').toUtc().isUtc, isTrue);
    expect(initial.read<DateTime>('updated_at').toUtc().isUtc, isTrue);
    expect(initial.readNullable<String>('resolved_at'), isNull);

    Future<void> resolveWithoutTime() => _execute(database, r'''
UPDATE customer_service_requests SET status = 'resolved'
WHERE id = 'csreq_01'
''');
    await expectLater(resolveWithoutTime, throwsStateError);

    await _execute(database, r'''
UPDATE customer_service_requests
SET status = 'resolved',
    resolved_at = strftime('%Y-%m-%dT%H:%M:%fZ', 'now')
WHERE id = 'csreq_01'
''');
    final resolved = await _request(database, 'csreq_01');
    expect(resolved.read<String>('status'), 'resolved');
    expect(
      resolved.read<DateTime>('resolved_at').toUtc().isUtc,
      isTrue,
    );
  });
}

Future<Row> _request(CommerceDatabase database, String id) async {
  final rows = await queryRaw(
    'SELECT status, resolved_at, created_at, updated_at '
    r'FROM customer_service_requests WHERE id = $1',
    [id],
  ).fetch(database.connection as Executor);
  return rows.single;
}

Future<void> _execute(CommerceDatabase database, String sql) async {
  final result = await queryExecute(sql, []).execute(database.executor);
  if (result.isErr) throw StateError('$result');
}

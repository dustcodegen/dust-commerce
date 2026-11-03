import 'package:commerce_server/commerce_server.dart';
import 'package:test/test.dart';

/// Asserts the Result boundary used by PostgreSQL executors.
Future<void> expectDbFailure<T>(
  Future<Result<T, SqlxError>> Function() action,
) async {
  final result = await action();
  expect(result.isErr, isTrue, reason: 'expected a database error: $result');
}

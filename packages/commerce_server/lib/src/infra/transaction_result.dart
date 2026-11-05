import 'package:dust_dart/db.dart';

/// Runs a domain result inside a SQLx transaction without exposing a nested
/// `Result` at the service boundary.
///
/// Dust rolls a transaction back when its callback returns `Err`. The domain
/// error is retained beside that rollback marker, then restored after the
/// driver returns. Storage failures are mapped by [storageError].
Future<Result<T, E>> transactionResult<T, E extends Object>(
  DatabaseClient database,
  Future<Result<T, E>> Function(Transaction tx) body, {
  required E Function(SqlxError error) storageError,
}) async {
  E? domainError;
  final persisted = await database.transaction<T>((tx) async {
    final result = await body(tx);
    if (result case Ok(:final value)) {
      return Ok<T, SqlxError>(value);
    }
    domainError = (result as Err<T, E>).error;
    return Err<T, SqlxError>(
      SqlxError.decode('Transaction rejected by the domain boundary'),
    );
  });
  if (domainError case final error?) return Err<T, E>(error);
  return persisted.mapErr(storageError);
}

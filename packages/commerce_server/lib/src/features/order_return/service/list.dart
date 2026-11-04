import 'package:commerce_server/src/features/order_return/model.dart';
import 'package:commerce_server/src/features/order_return/repository/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded page of active customer return reasons.
Future<Result<ReturnReasonListResponse, SqlxError>> listReturnReasons(
  OrderReturnListRepository returns, {
  required int limit,
  required int offset,
}) async {
  final rows = await returns.reasons(limit, offset);
  if (rows case Err(:final error)) return Err(error);
  final count = await returns.countReasons();
  if (count case Err(:final error)) return Err(error);
  return Ok(ReturnReasonListResponse(
    returnReasons: (rows as Ok<List<ReturnReasonResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  ));
}

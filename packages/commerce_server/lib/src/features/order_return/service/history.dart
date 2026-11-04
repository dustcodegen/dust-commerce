import 'package:commerce_server/src/features/order_return/history_response.dart';
import 'package:commerce_server/src/features/order_return/model.dart';
import 'package:commerce_server/src/features/order_return/repository/repository.dart';
import 'package:dust_dart/db.dart';

/// Lists one bounded return-history page after proving order ownership.
Future<Result<Option<OrderReturnHistoryResponse>, SqlxError>>
    listOrderReturnHistory(
  OrderReturnReadRepository reads,
  OrderReturnListRepository lists, {
  required String orderId,
  required String customerId,
  required int limit,
  required int offset,
}) async {
  final owned = await reads.order(orderId, customerId);
  if (owned case Err(:final error)) return Err(error);
  if ((owned as Ok<OrderReturnCandidate?, SqlxError>).value == null) {
    return const Ok(None());
  }

  final rows = await lists.forOrder(orderId, customerId, limit, offset);
  if (rows case Err(:final error)) return Err(error);
  final count = await lists.countForOrder(orderId, customerId);
  if (count case Err(:final error)) return Err(error);
  return Ok(Some(OrderReturnHistoryResponse(
    returns: (rows as Ok<List<OrderReturnResponse>, SqlxError>).value,
    count: (count as Ok<int, SqlxError>).value,
    limit: limit,
    offset: offset,
  )));
}

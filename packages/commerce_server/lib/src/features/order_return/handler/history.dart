import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/order_return/deps.dart';
import 'package:commerce_server/src/features/order_return/history_response.dart';
import 'package:commerce_server/src/features/order_return/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /store/orders/:id/returns` — list only the owner's return history.
Future<Result<OrderReturnHistoryResponse, Rejection>>
    listOrderReturnHistoryHandler(Request request) async {
  final orderId = pathParametersOf(request)['id'];
  if (orderId == null) return Err(Rejection.notFound('Order'));
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final state = await orderReturnDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<OrderReturnDeps, Rejection>).value;
  final paging = pagingOf(request);
  final result = await listOrderReturnHistory(
    deps.reads,
    deps.lists,
    orderId: orderId,
    customerId: actor.customer.id,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(value: Some(:final value)) => Ok(value),
    Ok(value: None()) => Err(Rejection.notFound('Order')),
    Err() => const Err(Rejection.internal()),
  };
}

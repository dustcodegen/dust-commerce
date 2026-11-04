import 'package:commerce_server/src/features/order_return/deps.dart';
import 'package:commerce_server/src/features/order_return/model.dart';
import 'package:commerce_server/src/features/order_return/service/service.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:dust_server/server.dart';

/// `GET /store/return-reasons` — public active reason discovery.
Future<Result<ReturnReasonListResponse, Rejection>> listReturnReasonsHandler(
  Request request,
) async {
  final state = await orderReturnDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<OrderReturnDeps, Rejection>).value;
  final paging = pagingOf(request);
  final result = await listReturnReasons(
    deps.lists,
    limit: paging.limit,
    offset: paging.offset,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

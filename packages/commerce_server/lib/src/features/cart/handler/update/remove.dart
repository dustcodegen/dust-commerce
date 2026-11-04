import 'package:commerce_server/src/features/cart/deps.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/read.dart';
import 'package:commerce_server/src/features/cart/model/model.dart';
import 'package:commerce_server/src/features/cart/service/service.dart';
import 'package:dust_server/server.dart';

/// `DELETE /carts/{id}/line-items/{lineId}` — remove one scoped line.
Future<Result<CartViewResponse, Rejection>> removeLineHandler(
  Request request,
) async {
  final access = await request.extract(const Extension<CartAccess>());
  final lineId = pathParametersOf(request)['lineId'];
  if (lineId == null || lineId.isEmpty) {
    return const Err(Rejection.badRequest('A line id is required'));
  }

  final state = await cartDeps(request);
  if (state case Err(:final error)) return Err(error);
  final deps = (state as Ok<CartDeps, Rejection>).value;
  final result = await removeLine(
    deps.database,
    cartId: access.cart.id,
    lineId: lineId,
  );

  return switch (result) {
    Ok(value: true) => await cartViewOf(deps.reads, access.cart.id),
    Ok(value: false) => Err(Rejection.notFound('Cart line "$lineId"')),
    Err() => const Err(Rejection.internal()),
  };
}

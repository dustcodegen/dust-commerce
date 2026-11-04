import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:commerce_server/src/features/checkout/repository/repository.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:dust_dart/db.dart';

/// One complete order by id, or [None] when there is no matching order.
Future<Result<Option<OrderResponse>, SqlxError>> loadOrder(
  CheckoutReadRepository reads,
  String orderId,
) async {
  final found = await reads.findOrder(orderId);
  return switch (found) {
    Ok(:final value) => Ok(optionOf<OrderResponse>(value)),
    Err(:final error) => Err(error),
  };
}

/// One complete order owned by [customerId], or [None] when none matches.
Future<Result<Option<OrderResponse>, SqlxError>> loadCustomerOrder(
  CheckoutCustomerReadRepository reads,
  String orderId,
  String customerId,
) async {
  final found = await reads.findCustomerOrder(orderId, customerId);
  return switch (found) {
    Ok(:final value) => Ok(optionOf<OrderResponse>(value)),
    Err(:final error) => Err(error),
  };
}

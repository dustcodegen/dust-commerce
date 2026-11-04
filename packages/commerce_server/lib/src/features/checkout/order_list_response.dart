import 'package:commerce_server/src/features/checkout/model.dart';
import 'package:dust_dart/serde.dart';

part 'order_list_response.g.dart';

/// Explicit order-history envelope.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderListResponse with _$OrderListResponse {
  /// Builds a counted response from complete orders.
  OrderListResponse.of(this.orders) : count = orders.length;

  /// Number of orders returned.
  final int count;

  /// Explicit order response allowlists, newest first.
  final List<OrderResponse> orders;
}

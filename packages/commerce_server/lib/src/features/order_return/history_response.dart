import 'package:commerce_server/src/features/order_return/model.dart';
import 'package:dust_dart/serde.dart';

part 'history_response.g.dart';

/// One customer-owned page of direct SQLx return responses.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderReturnHistoryResponse with _$OrderReturnHistoryResponse {
  /// Creates a bounded Store return-history response.
  const OrderReturnHistoryResponse({
    required this.returns,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total active returns owned through this order.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of owned rows skipped before this page.
  final int offset;

  /// Customer-safe direct SQLx projections, newest first.
  final List<OrderReturnResponse> returns;
}

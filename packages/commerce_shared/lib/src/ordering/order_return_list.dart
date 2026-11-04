import 'package:commerce_shared/src/ordering/order_return.dart';
import 'package:dust_dart/serde.dart';

part 'order_return_list.g.dart';

/// One bounded page of returns owned through a customer order.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderReturnListView with _$OrderReturnListView {
  /// Creates a customer-safe return-history page.
  const OrderReturnListView({
    required this.returns,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes the generated Store response.
  factory OrderReturnListView.fromJson(Map<String, Object?> json) =>
      _$OrderReturnListViewFromJson(json);

  /// Total active returns owned through the order.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of owned rows skipped before this page.
  final int offset;

  /// Explicit customer-visible return allowlists, newest first.
  final List<OrderReturnView> returns;
}

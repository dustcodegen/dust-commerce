import 'package:commerce_shared/src/money.dart';
import 'package:commerce_shared/src/ordering/line_item.dart';
import 'package:dust_dart/serde.dart';

part 'order_line_item.g.dart';

/// Medusa-compatible lifecycle quantities for one frozen order line.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderLineItemDetail with _$OrderLineItemDetail {
  /// Creates trusted quantities returned by the order service.
  const OrderLineItemDetail({
    required this.deliveredQuantity,
    required this.returnRequestedQuantity,
    required this.returnReceivedQuantity,
    required this.returnDismissedQuantity,
  });

  /// Creates detail from the generated Store response.
  factory OrderLineItemDetail.fromJson(Map<String, Object?> json) =>
      _$OrderLineItemDetailFromJson(json);

  /// Units delivered to the customer and eligible for return accounting.
  final int deliveredQuantity;

  /// Units received but rejected from the accepted return.
  final int returnDismissedQuantity;

  /// Units physically received through active returns.
  final int returnReceivedQuantity;

  /// Units reserved by active return requests.
  final int returnRequestedQuantity;

  /// Units that can enter a new return request.
  int get returnableQuantity =>
      deliveredQuantity -
      returnRequestedQuantity -
      returnReceivedQuantity -
      returnDismissedQuantity;
}

/// Frozen order item kept separate from mutable cart-line state.
@Derive([ToString(), Eq(), CopyWith(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderLineItem with _$OrderLineItem {
  /// Creates one trusted order-line response.
  const OrderLineItem({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.productHandle,
    required this.title,
    required this.unitPrice,
    required this.quantity,
    required this.detail,
    this.variantTitle,
    this.thumbnail,
  });

  /// Freezes one cart line before any delivery or return activity exists.
  factory OrderLineItem.fromCartLine(LineItem line) => OrderLineItem(
        id: line.id,
        variantId: line.variantId,
        productId: line.productId,
        productHandle: line.productHandle,
        title: line.title,
        variantTitle: line.variantTitle,
        thumbnail: line.thumbnail,
        unitPrice: line.unitPrice,
        quantity: line.quantity,
        detail: const OrderLineItemDetail(
          deliveredQuantity: 0,
          returnRequestedQuantity: 0,
          returnReceivedQuantity: 0,
          returnDismissedQuantity: 0,
        ),
      );

  /// Creates an order item from the generated Store response.
  factory OrderLineItem.fromJson(Map<String, Object?> json) =>
      _$OrderLineItemFromJson(json);

  /// Medusa-shaped delivery and return quantities.
  final OrderLineItemDetail detail;

  /// Stable frozen order-item identifier.
  final String id;

  /// Product identifier retained for historical navigation.
  final String productId;

  /// URL-safe product route captured at checkout.
  final String productHandle;

  /// Units purchased on this order line.
  final int quantity;

  /// Product title captured at checkout.
  final String title;

  /// Product image captured at checkout.
  final String? thumbnail;

  /// Frozen price for one unit.
  final Money unitPrice;

  /// Variant identifier retained for historical context.
  final String variantId;

  /// Variant title captured at checkout.
  final String? variantTitle;

  /// Frozen price of the entire line.
  Money get subtotal => unitPrice * quantity;
}

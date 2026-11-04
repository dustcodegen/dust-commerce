import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'order_item_response.g.dart';

/// Explicit public lifecycle quantities for one frozen order item.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderLineItemDetailResponse with _$OrderLineItemDetailResponse {
  /// Creates the final response from aggregate database values.
  const OrderLineItemDetailResponse({
    required this.deliveredQuantity,
    required this.returnRequestedQuantity,
    required this.returnReceivedQuantity,
    required this.returnDismissedQuantity,
  });

  /// Decodes the allowlisted SQL JSON object.
  factory OrderLineItemDetailResponse.fromJson(Map<String, Object?> json) =>
      _$OrderLineItemDetailResponseFromJson(json);

  /// Units delivered to the customer.
  final int deliveredQuantity;

  /// Returned units dismissed from acceptance.
  final int returnDismissedQuantity;

  /// Returned units accepted as received.
  final int returnReceivedQuantity;

  /// Units currently reserved by active return requests.
  final int returnRequestedQuantity;

  /// Returns this lifecycle after the simplified order completes delivery.
  OrderLineItemDetailResponse delivered(int quantity) =>
      OrderLineItemDetailResponse(
        deliveredQuantity: quantity,
        returnRequestedQuantity: returnRequestedQuantity,
        returnReceivedQuantity: returnReceivedQuantity,
        returnDismissedQuantity: returnDismissedQuantity,
      );
}

/// Explicit Store order-item response independent from cart-line responses.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderLineItemResponse with _$OrderLineItemResponse {
  /// Creates one final customer-safe order-item response.
  const OrderLineItemResponse({
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

  /// Decodes one allowlisted item from the SQL JSON aggregate.
  factory OrderLineItemResponse.fromJson(Map<String, Object?> json) =>
      _$OrderLineItemResponseFromJson(json);

  /// Public delivery and return quantities.
  final OrderLineItemDetailResponse detail;

  /// Stable order-item identifier.
  final String id;

  /// Historical product identifier.
  final String productId;

  /// Historical product route.
  final String productHandle;

  /// Purchased units.
  final int quantity;

  /// Historical product title.
  final String title;

  /// Historical product image.
  final String? thumbnail;

  /// Frozen unit price.
  final Money unitPrice;

  /// Historical variant identifier.
  final String variantId;

  /// Historical variant title.
  final String? variantTitle;

  /// Returns this response after the simplified order completes delivery.
  OrderLineItemResponse delivered() => OrderLineItemResponse(
        id: id,
        variantId: variantId,
        productId: productId,
        productHandle: productHandle,
        title: title,
        variantTitle: variantTitle,
        thumbnail: thumbnail,
        unitPrice: unitPrice,
        quantity: quantity,
        detail: detail.delivered(quantity),
      );
}

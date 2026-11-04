import 'package:dust_dart/serde.dart';

part 'order_return.g.dart';

/// Customer-visible lifecycle of a return request.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum OrderReturnStatus {
  /// Merchant has opened the request for processing.
  open,

  /// Customer submitted the request and awaits merchant review.
  requested,

  /// Every requested unit has been received.
  received,

  /// Some requested units have been received.
  partiallyReceived,

  /// Request was canceled before receipt.
  canceled,
}

/// One frozen order item and quantity included in a return request.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderReturnItemInput with _$OrderReturnItemInput {
  /// Creates one requested item using the immutable order-item identifier.
  const OrderReturnItemInput({
    required this.itemId,
    required this.quantity,
    this.reasonIdValue,
    this.noteValue,
  });

  /// Decodes one return item from the request body.
  factory OrderReturnItemInput.fromJson(Map<String, Object?> json) =>
      _$OrderReturnItemInputFromJson(json);

  /// Immutable order-item identifier, named `id` by Medusa's Store contract.
  @SerDe(rename: 'id')
  @Validate(length: Length(min: 1, max: 255), message: 'Choose an order item')
  final String itemId;

  /// Optional item-specific context.
  Option<String> get note => _returnOption(noteValue);

  /// Nullable wire backing for [note].
  @SerDe(rename: 'note')
  @Validate(length: Length(max: 1000), message: 'Use at most 1000 characters')
  final String? noteValue;

  /// Requested units, validated again against the frozen order server-side.
  @Validate(range: Range(min: 1), message: 'Return at least one item')
  final int quantity;

  /// Merchant-controlled reason selection.
  Option<String> get reasonId => _returnOption(reasonIdValue);

  /// Nullable wire backing for [reasonId].
  @SerDe(rename: 'reason_id')
  @Validate(length: Length(max: 255), message: 'Invalid return reason')
  final String? reasonIdValue;
}

/// Authenticated request to return items from one owned order.
@Derive([ToString(), Eq(), Validate(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderReturnRequestBody with _$OrderReturnRequestBody {
  /// Creates a return request without implying automatic refund or receipt.
  const OrderReturnRequestBody({
    required this.orderId,
    required this.items,
    this.noteValue,
  });

  /// Decodes the Store request body.
  factory OrderReturnRequestBody.fromJson(Map<String, Object?> json) =>
      _$OrderReturnRequestBodyFromJson(json);

  /// Frozen order items and requested quantities.
  @Validate(
    length: Length(min: 1, max: 100),
    message: 'Choose between 1 and 100 order items',
  )
  @Validate<List<OrderReturnItemInput>>(
    custom: _validateReturnItems,
    message: 'Every return item must be valid',
  )
  final List<OrderReturnItemInput> items;

  /// Optional context applying to the complete request.
  Option<String> get note => _returnOption(noteValue);

  /// Nullable wire backing for [note].
  @SerDe(rename: 'note')
  @Validate(length: Length(max: 2000), message: 'Use at most 2000 characters')
  final String? noteValue;

  /// Opaque order identifier checked against the authenticated customer.
  @Validate(length: Length(min: 1, max: 255), message: 'Choose an order')
  final String orderId;
}

/// Minimal public acknowledgement of a persisted return request.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class OrderReturnView with _$OrderReturnView {
  /// Creates one explicit Store response allowlist.
  const OrderReturnView({
    required this.id,
    required this.displayId,
    required this.orderId,
    required this.status,
    required this.itemQuantity,
    required this.requestedAt,
  });

  /// Decodes the generated Store response.
  factory OrderReturnView.fromJson(Map<String, Object?> json) =>
      _$OrderReturnViewFromJson(json);

  /// Short customer-facing request number.
  final int displayId;

  /// Stable opaque return identifier.
  final String id;

  /// Total number of units requested across all items.
  final int itemQuantity;

  /// Owned order associated with this return.
  final String orderId;

  /// Database-generated request instant.
  final DateTime requestedAt;

  /// Current request lifecycle.
  final OrderReturnStatus status;
}

Option<T> _returnOption<T>(T? value) => switch (value) {
      final T value => Some(value),
      null => const None(),
    };

ValidationError? _validateReturnItems(List<OrderReturnItemInput> items) =>
    items.every((item) => item.validate().isValid)
        ? null
        : const ValidationError(
            field: 'items',
            message: 'Every return item must be valid',
          );

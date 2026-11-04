import 'package:dust_dart/serde.dart';

part 'admin_receive_return.g.dart';

/// Intact and damaged units processed for one return item in this operation.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminReceiveReturnItem with _$AdminReceiveReturnItem {
  /// Creates one receipt quantity command.
  const AdminReceiveReturnItem({
    required this.id,
    required this.quantity,
    required this.damagedQuantity,
  });

  /// Decodes one generated Admin receipt command.
  factory AdminReceiveReturnItem.fromJson(Map<String, Object?> json) =>
      _$AdminReceiveReturnItemFromJson(json);

  /// Damaged units received now and excluded from future restocking.
  final int damagedQuantity;

  /// Stable return-item identifier owned by the selected return.
  final String id;

  /// Intact units received in this operation.
  final int quantity;
}

/// Atomic confirmation of physical units received for one return.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminReceiveReturn with _$AdminReceiveReturn {
  /// Creates a receipt operation without transport-specific values.
  const AdminReceiveReturn({
    required this.items,
    required this.noNotification,
  });

  /// Decodes the generated Admin request body.
  factory AdminReceiveReturn.fromJson(Map<String, Object?> json) =>
      _$AdminReceiveReturnFromJson(json);

  /// Per-item intact and damaged quantities received now.
  final List<AdminReceiveReturnItem> items;

  /// Whether customer notification should be suppressed.
  final bool noNotification;
}

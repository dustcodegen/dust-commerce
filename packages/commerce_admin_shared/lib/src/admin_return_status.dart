import 'package:dust_dart/serde.dart';

part 'admin_return_status.g.dart';

/// Merchant-visible lifecycle of a customer return.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum AdminReturnStatus {
  /// The customer submitted the return for merchant processing.
  requested,

  /// Every requested unit was received by the merchant.
  received,

  /// At least one requested unit was received, but some remain outstanding.
  partiallyReceived,

  /// The request was canceled before receipt completed.
  canceled,
}

/// Converts persisted and JSON status names without leaking raw strings.
final class AdminReturnStatusCodec
    implements SerDeCodec<AdminReturnStatus, String> {
  /// Creates the stateless return-status codec.
  const AdminReturnStatusCodec();

  @override
  AdminReturnStatus deserialize(String value) => switch (value) {
        'requested' => AdminReturnStatus.requested,
        'received' => AdminReturnStatus.received,
        'partially_received' => AdminReturnStatus.partiallyReceived,
        'canceled' => AdminReturnStatus.canceled,
        _ => throw ArgumentError.value(value, 'value', 'Unknown return status'),
      };

  @override
  String serialize(AdminReturnStatus value) => switch (value) {
        AdminReturnStatus.requested => 'requested',
        AdminReturnStatus.received => 'received',
        AdminReturnStatus.partiallyReceived => 'partially_received',
        AdminReturnStatus.canceled => 'canceled',
      };
}

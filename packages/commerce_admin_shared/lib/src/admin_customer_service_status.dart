import 'package:dust_dart/serde.dart';

part 'admin_customer_service_status.g.dart';

/// Merchant-visible lifecycle for one customer-service request.
@Derive([Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
enum AdminCustomerServiceStatus {
  /// Waiting for merchant triage.
  open,

  /// A merchant is actively handling the request.
  inProgress,

  /// The request no longer needs action.
  resolved,
}

/// Converts persisted and JSON status names without raw strings in the UI.
final class AdminCustomerServiceStatusCodec
    implements SerDeCodec<AdminCustomerServiceStatus, String> {
  /// Creates the stateless status codec.
  const AdminCustomerServiceStatusCodec();

  @override
  AdminCustomerServiceStatus deserialize(String value) => switch (value) {
        'open' => AdminCustomerServiceStatus.open,
        'in_progress' => AdminCustomerServiceStatus.inProgress,
        'resolved' => AdminCustomerServiceStatus.resolved,
        _ => throw ArgumentError.value(value, 'value', 'Unknown status'),
      };

  @override
  String serialize(AdminCustomerServiceStatus value) => switch (value) {
        AdminCustomerServiceStatus.open => 'open',
        AdminCustomerServiceStatus.inProgress => 'in_progress',
        AdminCustomerServiceStatus.resolved => 'resolved',
      };
}

import 'package:commerce_admin_shared/src/admin_customer_service_status.dart';
import 'package:commerce_admin_shared/src/admin_option.dart';
import 'package:dust_dart/serde.dart';

part 'admin_customer_service.g.dart';

/// Explicit Admin response for one customer-service request.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerServiceRequest with _$AdminCustomerServiceRequest {
  /// Creates one merchant-visible request allowlist.
  const AdminCustomerServiceRequest({
    required this.id,
    required this.customerIdValue,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.orderReferenceValue,
    required this.status,
    required this.resolvedAtValue,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Decodes one generated Admin response.
  factory AdminCustomerServiceRequest.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerServiceRequestFromJson(json);

  /// Database-generated creation instant.
  final DateTime createdAt;

  /// Proven Store account when the shopper submitted while signed in.
  Option<String> get customerId => adminOptionOf(customerIdValue);

  /// Nullable wire backing for [customerId].
  @SerDe(rename: 'customer_id')
  final String? customerIdValue;

  /// Customer reply address.
  final String email;

  /// Stable opaque request identifier.
  final String id;

  /// Complete customer-authored support detail.
  final String message;

  /// Customer name copied at submission time.
  final String name;

  /// Order reference when the shopper supplied one.
  Option<String> get orderReference => adminOptionOf(orderReferenceValue);

  /// Nullable wire backing for [orderReference].
  @SerDe(rename: 'order_reference')
  final String? orderReferenceValue;

  /// Resolution audit instant.
  Option<DateTime> get resolvedAt => adminOptionOf(resolvedAtValue);

  /// Nullable wire backing for [resolvedAt].
  @SerDe(rename: 'resolved_at')
  final DateTime? resolvedAtValue;

  /// Current triage lifecycle.
  @SerDe(using: AdminCustomerServiceStatusCodec())
  final AdminCustomerServiceStatus status;

  /// Customer-authored routing summary.
  final String subject;

  /// Database-generated last mutation instant.
  final DateTime updatedAt;
}

/// Customer-service rows plus bounded-list metadata.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerServiceList with _$AdminCustomerServiceList {
  /// Creates one merchant inbox page.
  const AdminCustomerServiceList({
    required this.requests,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Decodes one generated Admin page.
  factory AdminCustomerServiceList.fromJson(Map<String, Object?> json) =>
      _$AdminCustomerServiceListFromJson(json);

  /// Total matching requests.
  final int count;

  /// Maximum rows requested for this page.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit merchant-only request allowlists.
  final List<AdminCustomerServiceRequest> requests;
}

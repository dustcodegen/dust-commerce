import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_dart/serde.dart';

part 'model.g.dart';

/// Merchant support request populated directly from an explicit SQL projection.
@Derive([FromRow(), Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerServiceResponse with _$AdminCustomerServiceResponse {
  /// Creates one explicit Admin response allowlist.
  const AdminCustomerServiceResponse({
    required this.id,
    required this.customerId,
    required this.name,
    required this.email,
    required this.subject,
    required this.message,
    required this.orderReference,
    required this.status,
    required this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Database-generated creation instant.
  @Sqlx(rename: 'created_at', tryFrom: _AdminCustomerServiceDateTime())
  final DateTime createdAt;

  /// Proven Store account, absent for guest submissions.
  @Sqlx(rename: 'customer_id')
  final String? customerId;

  /// Customer reply address.
  final String email;

  /// Stable opaque request identifier.
  final String id;

  /// Complete customer-authored support detail.
  final String message;

  /// Customer name copied at submission time.
  final String name;

  /// Optional customer-supplied order reference.
  @Sqlx(rename: 'order_reference')
  final String? orderReference;

  /// Database-generated resolution audit instant.
  @Sqlx(
    rename: 'resolved_at',
    defaultValue: null,
    tryFrom: _AdminCustomerServiceDateTime(),
  )
  final DateTime? resolvedAt;

  /// Current typed triage lifecycle.
  @SerDe(using: AdminCustomerServiceStatusCodec())
  @Sqlx(tryFrom: _AdminCustomerServiceStatus())
  final AdminCustomerServiceStatus status;

  /// Customer-authored routing summary.
  final String subject;

  /// Database-generated last mutation instant.
  @Sqlx(rename: 'updated_at', tryFrom: _AdminCustomerServiceDateTime())
  final DateTime updatedAt;
}

/// Customer-service rows plus bounded-list metadata.
@Derive([Serialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class AdminCustomerServiceListResponse
    with _$AdminCustomerServiceListResponse {
  /// Creates one merchant support page.
  const AdminCustomerServiceListResponse({
    required this.requests,
    required this.count,
    required this.limit,
    required this.offset,
  });

  /// Total matching requests.
  final int count;

  /// Maximum requested page size.
  final int limit;

  /// Number of matching rows skipped.
  final int offset;

  /// Explicit direct-SQLx merchant response rows.
  final List<AdminCustomerServiceResponse> requests;
}

final class _AdminCustomerServiceDateTime
    implements SqlxTryFrom<DateTime, DateTime> {
  const _AdminCustomerServiceDateTime();

  @override
  DateTime decode(DateTime value) => value.toUtc();
}

final class _AdminCustomerServiceStatus
    implements SqlxTryFrom<AdminCustomerServiceStatus, String> {
  const _AdminCustomerServiceStatus();

  @override
  AdminCustomerServiceStatus decode(String value) =>
      const AdminCustomerServiceStatusCodec().deserialize(value);
}

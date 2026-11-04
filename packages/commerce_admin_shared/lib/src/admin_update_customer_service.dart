import 'package:commerce_admin_shared/src/admin_customer_service_status.dart';
import 'package:dust_dart/serde.dart';

part 'admin_update_customer_service.g.dart';

/// Merchant input for changing one customer-service lifecycle.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
final class AdminUpdateCustomerService with _$AdminUpdateCustomerService {
  /// Creates one complete status replacement.
  const AdminUpdateCustomerService({required this.status});

  /// Decodes one generated Admin update request.
  factory AdminUpdateCustomerService.fromJson(Map<String, Object?> json) =>
      _$AdminUpdateCustomerServiceFromJson(json);

  /// New lifecycle value; timestamps remain database-owned.
  @SerDe(using: AdminCustomerServiceStatusCodec())
  final AdminCustomerServiceStatus status;
}

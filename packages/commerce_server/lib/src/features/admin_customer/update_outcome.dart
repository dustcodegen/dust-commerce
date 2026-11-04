import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer/update_failure.dart';

/// Transaction value keeping update refusal out of nested `Result` types.
sealed class AdminUpdateCustomerOutcome {
  const AdminUpdateCustomerOutcome();
}

/// Customer profile returned after a committed replacement.
final class AdminCustomerUpdated extends AdminUpdateCustomerOutcome {
  /// Creates a successful transaction value.
  const AdminCustomerUpdated(this.customer);

  /// Complete refreshed customer allowlist.
  final AdminCustomerDetailResponse customer;
}

/// Expected replacement refusal whose transaction can close normally.
final class AdminCustomerUpdateDenied extends AdminUpdateCustomerOutcome {
  /// Creates a refused transaction value.
  const AdminCustomerUpdateDenied(this.failure);

  /// Stable business reason for refusal.
  final AdminUpdateCustomerFailure failure;
}

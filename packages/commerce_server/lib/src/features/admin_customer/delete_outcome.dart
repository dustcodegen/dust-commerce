import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:commerce_server/src/features/admin_customer/delete_failure.dart';

/// Transaction value before SQLx and business failures are flattened.
sealed class AdminCustomerDeleteOutcome {
  const AdminCustomerDeleteOutcome();
}

/// Customer graph and account boundary were removed.
final class AdminCustomerDeletedOutcome extends AdminCustomerDeleteOutcome {
  /// Creates the successful transaction value.
  const AdminCustomerDeletedOutcome(this.deleted);

  /// Explicit Admin API acknowledgement.
  final AdminCustomerDeleted deleted;
}

/// Transaction made no changes for a safe business reason.
final class AdminCustomerDeleteDenied extends AdminCustomerDeleteOutcome {
  /// Creates the denied transaction value.
  const AdminCustomerDeleteDenied(this.failure);

  /// Exact business failure.
  final AdminDeleteCustomerFailure failure;
}

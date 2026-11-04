import 'package:commerce_server/src/features/admin_customer_address/delete_failure.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_response.dart';

/// Transaction result before SQLx errors become feature errors.
sealed class AdminCustomerAddressDeleteOutcome {
  const AdminCustomerAddressDeleteOutcome();
}

/// Address acknowledgement returned after the transaction commits.
final class AdminCustomerAddressDeleted
    extends AdminCustomerAddressDeleteOutcome {
  /// Creates a successful transaction outcome.
  const AdminCustomerAddressDeleted(this.response);

  /// Explicit delete-with-parent response.
  final AdminCustomerAddressDeleteResponse response;
}

/// Business refusal that leaves every address active.
final class AdminCustomerAddressDeleteDenied
    extends AdminCustomerAddressDeleteOutcome {
  /// Creates a denied transaction outcome.
  const AdminCustomerAddressDeleteDenied(this.failure);

  /// Stable reason deletion was refused.
  final AdminDeleteCustomerAddressFailure failure;
}

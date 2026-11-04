import 'package:commerce_server/src/features/admin_customer/detail_model.dart';
import 'package:commerce_server/src/features/admin_customer_address/create_failure.dart';

/// Transaction result before SQLx errors are flattened into feature errors.
sealed class AdminCustomerAddressCreateOutcome {
  const AdminCustomerAddressCreateOutcome();
}

/// Complete customer returned after its address is committed.
final class AdminCustomerAddressCreated
    extends AdminCustomerAddressCreateOutcome {
  /// Creates a successful transaction outcome.
  const AdminCustomerAddressCreated(this.customer);

  /// Refreshed explicit customer projection.
  final AdminCustomerDetailResponse customer;
}

/// Business refusal that caused the transaction to finish without a write.
final class AdminCustomerAddressCreateDenied
    extends AdminCustomerAddressCreateOutcome {
  /// Creates a denied transaction outcome.
  const AdminCustomerAddressCreateDenied(this.failure);

  /// Stable reason creation was refused.
  final AdminCreateCustomerAddressFailure failure;
}

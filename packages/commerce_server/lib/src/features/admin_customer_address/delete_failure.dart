import 'package:dust_dart/db.dart';

/// Stable business reasons customer-address deletion can be refused.
enum AdminDeleteCustomerAddressFailure {
  /// The active address does not belong to the active parent customer.
  notFound,
}

/// One flat error channel for customer-address deletion.
sealed class AdminDeleteCustomerAddressError {
  const AdminDeleteCustomerAddressError();
}

/// Expected business refusal safe for transport mapping.
final class AdminDeleteCustomerAddressRejected
    extends AdminDeleteCustomerAddressError {
  /// Creates a refusal with its stable [failure].
  const AdminDeleteCustomerAddressRejected(this.failure);

  /// Business rule that refused deletion.
  final AdminDeleteCustomerAddressFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminDeleteCustomerAddressStorage
    extends AdminDeleteCustomerAddressError {
  /// Wraps the original SQLx [cause].
  const AdminDeleteCustomerAddressStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}

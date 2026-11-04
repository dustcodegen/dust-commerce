import 'package:dust_dart/db.dart';

/// Stable business reasons address creation can be refused.
enum AdminCreateCustomerAddressFailure {
  /// The parent customer is absent or inactive.
  customerNotFound,
}

/// One flat error channel for customer-address creation.
sealed class AdminCreateCustomerAddressError {
  const AdminCreateCustomerAddressError();
}

/// Expected business refusal safe for transport mapping.
final class AdminCreateCustomerAddressRejected
    extends AdminCreateCustomerAddressError {
  /// Creates a refusal with its stable [failure].
  const AdminCreateCustomerAddressRejected(this.failure);

  /// Business rule that refused creation.
  final AdminCreateCustomerAddressFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminCreateCustomerAddressStorage
    extends AdminCreateCustomerAddressError {
  /// Wraps the original SQLx [cause].
  const AdminCreateCustomerAddressStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}

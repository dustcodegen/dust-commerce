import 'package:dust_dart/db.dart';

/// Stable business reasons customer-group creation can be refused.
enum AdminCustomerGroupCreateFailure {
  /// An active customer group already owns the requested name.
  nameConflict,
}

/// One flat error channel for customer-group creation.
sealed class AdminCustomerGroupCreateError {
  const AdminCustomerGroupCreateError();
}

/// Expected business refusal safe for transport mapping.
final class AdminCustomerGroupCreateRejected
    extends AdminCustomerGroupCreateError {
  /// Creates a refusal with its stable [failure].
  const AdminCustomerGroupCreateRejected(this.failure);

  /// Business rule that refused creation.
  final AdminCustomerGroupCreateFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminCustomerGroupCreateStorage
    extends AdminCustomerGroupCreateError {
  /// Wraps the original SQLx [cause].
  const AdminCustomerGroupCreateStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}

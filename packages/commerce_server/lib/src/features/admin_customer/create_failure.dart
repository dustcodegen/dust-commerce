import 'package:dust_dart/db.dart';

/// Stable business reasons customer creation can be refused.
enum AdminCreateCustomerFailure {
  /// An active guest profile already owns the normalized email.
  emailConflict,
}

/// One flat error channel for customer creation.
sealed class AdminCreateCustomerError {
  const AdminCreateCustomerError();
}

/// Expected business refusal safe for transport mapping.
final class AdminCreateCustomerRejected extends AdminCreateCustomerError {
  /// Creates a refusal with its stable [failure].
  const AdminCreateCustomerRejected(this.failure);

  /// Business rule that refused creation.
  final AdminCreateCustomerFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminCreateCustomerStorage extends AdminCreateCustomerError {
  /// Wraps the original SQLx [cause].
  const AdminCreateCustomerStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}

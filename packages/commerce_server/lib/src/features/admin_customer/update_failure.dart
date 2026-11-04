import 'package:dust_dart/db.dart';

/// Stable reasons customer replacement can be refused.
enum AdminUpdateCustomerFailure {
  /// No active customer owns the route id.
  notFound,

  /// A guest update omitted its required email.
  emailRequired,

  /// A registered account's owned email cannot be changed here.
  registeredEmail,

  /// Another active profile already owns the requested guest email.
  emailConflict,
}

/// One flat error channel for customer replacement.
sealed class AdminUpdateCustomerError {
  const AdminUpdateCustomerError();
}

/// Expected business refusal safe for transport mapping.
final class AdminUpdateCustomerRejected extends AdminUpdateCustomerError {
  /// Creates a refusal with its stable [failure].
  const AdminUpdateCustomerRejected(this.failure);

  /// Business rule that refused replacement.
  final AdminUpdateCustomerFailure failure;
}

/// SQLx failure retained while transport returns a safe response.
final class AdminUpdateCustomerStorage extends AdminUpdateCustomerError {
  /// Wraps the original SQLx [cause].
  const AdminUpdateCustomerStorage(this.cause);

  /// Original database failure.
  final SqlxError cause;
}

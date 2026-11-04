import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/db.dart';

/// Business reason customer deletion could not complete.
enum AdminDeleteCustomerFailure {
  /// No active customer owns the requested identifier.
  notFound,

  /// A registered profile has no single active authentication identity.
  inconsistentIdentity,
}

/// One flat customer-deletion error boundary.
sealed class AdminDeleteCustomerError {
  const AdminDeleteCustomerError();
}

/// Safe business rejection from customer deletion.
final class AdminDeleteCustomerRejected extends AdminDeleteCustomerError {
  /// Creates the rejection.
  const AdminDeleteCustomerRejected(this.failure);

  /// Exact business failure.
  final AdminDeleteCustomerFailure failure;
}

/// SQLx failure retained for internal diagnostics only.
final class AdminDeleteCustomerStorage extends AdminDeleteCustomerError {
  /// Creates the storage failure.
  const AdminDeleteCustomerStorage(this.cause);

  /// Original database error.
  final SqlxError cause;
}

/// Successful explicit customer-deletion value.
typedef AdminDeleteCustomerResult
    = Result<AdminCustomerDeleted, AdminDeleteCustomerError>;

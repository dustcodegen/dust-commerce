import 'package:dust_dart/db.dart';

/// Why a customer account was not created.
enum RegisterFailure {
  /// An active account already owns this email address.
  alreadyExists,
}

/// Error crossing the account-registration service boundary.
sealed class RegisterAccountError {
  /// Creates one registration error.
  const RegisterAccountError();
}

/// A business rejection that is safe to expose to the handler.
final class RegisterAccountRejected extends RegisterAccountError {
  /// Creates one business rejection.
  const RegisterAccountRejected(this.failure);

  /// The stable business reason.
  final RegisterFailure failure;
}

/// A storage failure retained for logging without exposing SQL details.
final class RegisterAccountStorage extends RegisterAccountError {
  /// Creates one storage failure.
  const RegisterAccountStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

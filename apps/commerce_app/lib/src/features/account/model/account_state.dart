import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'account_state.g.dart';

/// Customer-session lifecycle visible to storefront screens.
enum AccountStatus {
  /// Secure storage has not been inspected yet.
  initial,

  /// A session request is in flight.
  loading,

  /// No usable customer session exists.
  signedOut,

  /// The server accepted the stored session.
  signedIn,

  /// Valid credentials are waiting for the emailed capability.
  verificationRequired,

  /// The most recent operation failed safely.
  failed,
}

/// The account operation currently visible to the customer.
enum AccountOperation {
  /// Restoring and verifying a persisted session.
  restore,

  /// Exchanging credentials for a session.
  signIn,

  /// Creating a customer identity and session.
  register,

  /// Revoking the active session.
  signOut,

  /// Replacing editable customer profile fields.
  updateProfile,

  /// Verifying and rotating the customer password.
  changePassword,
}

/// Public account UI state; bearer credentials never enter this object.
@Derive([ToString(), Eq(), CopyWith()])
class AccountState with _$AccountState {
  /// Creates account state.
  const AccountState({
    this.status = AccountStatus.initial,
    this.customer,
    this.operation,
    this.message,
    this.verificationEmail = const None(),
  });

  /// Customer proven by the current server session.
  final Customer? customer;

  /// Display-safe account failure.
  final String? message;

  /// Operation in flight or most recently failed.
  final AccountOperation? operation;

  /// Current session lifecycle state.
  final AccountStatus status;

  /// Normalized recipient shown only after a credential-proven request.
  final Option<String> verificationEmail;

  /// Whether a server-proven customer is available.
  bool get isAuthenticated => customer != null;

  /// Whether an account request is in flight.
  bool get isBusy => status == AccountStatus.loading;
}

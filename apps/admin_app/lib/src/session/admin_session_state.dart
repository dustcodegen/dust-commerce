import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/serde.dart';

part 'admin_session_state.g.dart';

/// Lifecycle of the isolated merchant session.
enum AdminSessionStatus {
  /// Secure storage has not been checked.
  initial,

  /// An authentication request is active.
  loading,

  /// No verified administrator is available.
  signedOut,

  /// The server verified the stored bearer.
  signedIn,

  /// The last operation failed without exposing internals.
  failed,
}

/// Admin authentication state; bearer credentials never enter UI state.
@Derive([ToString(), Eq()])
final class AdminSessionState with _$AdminSessionState {
  /// Creates an admin session state.
  const AdminSessionState({
    this.status = AdminSessionStatus.initial,
    this.user = const None(),
    this.failure = const None(),
  });

  /// Display-safe failure text.
  final Option<String> failure;

  /// Current session lifecycle.
  final AdminSessionStatus status;

  /// Server-proven administrator.
  final Option<AdminUser> user;

  /// Whether a request is active.
  bool get isBusy => status == AdminSessionStatus.loading;
}

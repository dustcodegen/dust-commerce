import 'package:dust_dart/serde.dart';

part 'email_verification_state.g.dart';

/// Lifecycle of one email capability confirmation.
enum EmailVerificationStatus {
  /// No capability has been submitted.
  initial,

  /// The confirmation request is in flight.
  verifying,

  /// The capability was consumed.
  success,

  /// The capability was missing, invalid, expired, or already consumed.
  failed,
}

/// Public verification state without the secret capability.
@Derive([ToString(), Eq(), CopyWith()])
final class EmailVerificationState with _$EmailVerificationState {
  /// Creates a verification state.
  const EmailVerificationState({
    this.status = EmailVerificationStatus.initial,
  });

  /// Current confirmation lifecycle.
  final EmailVerificationStatus status;
}

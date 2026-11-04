/// One single-use customer email-verification message.
final class EmailVerificationMail {
  /// Creates a verification message.
  const EmailVerificationMail({
    required this.recipient,
    required this.token,
    required this.expiresAt,
  });

  /// UTC deadline after which the capability is rejected.
  final DateTime expiresAt;

  /// Normalized customer email receiving the capability.
  final String recipient;

  /// Raw capability used only to build the verification link.
  final String token;
}

/// Delivers email-verification capabilities outside the account service.
abstract interface class EmailVerificationMailer {
  /// Whether delivery is configured for this server process.
  bool get isAvailable;

  /// Sends one verification message.
  Future<void> send(EmailVerificationMail mail);
}

/// Safe default for deployments that have not enabled email verification.
final class UnavailableEmailVerificationMailer
    implements EmailVerificationMailer {
  /// Creates the disabled adapter.
  const UnavailableEmailVerificationMailer();

  @override
  bool get isAvailable => false;

  @override
  Future<void> send(EmailVerificationMail mail) =>
      throw const EmailVerificationMailUnavailable();
}

/// Signals that account verification cannot deliver email.
final class EmailVerificationMailUnavailable implements Exception {
  /// Creates the configuration failure signal.
  const EmailVerificationMailUnavailable();
}

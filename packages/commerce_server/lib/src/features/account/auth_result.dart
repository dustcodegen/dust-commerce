import 'package:commerce_server/src/features/account/mail.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';

/// Successful registration plus an optional outbound verification message.
final class RegisteredAccount {
  /// Creates a registration result.
  const RegisteredAccount({required this.customer, required this.verification});

  /// Explicit public customer allowlist returned by the handler.
  final CustomerResponse customer;

  /// Message emitted only when verification was explicitly enabled.
  final Option<EmailVerificationMail> verification;
}

/// Internal credential decision; no password or token hash can serialize.
sealed class SignInResult {
  const SignInResult();
}

/// The supplied credential pair was not valid.
final class InvalidCredentials extends SignInResult {
  /// Creates the indistinguishable invalid-credential result.
  const InvalidCredentials();
}

/// A verified identity received a new bearer session.
final class SessionIssued extends SignInResult {
  /// Creates the successful sign-in result.
  const SessionIssued(this.token);

  /// Opaque session returned exactly once.
  final IssuedToken token;
}

/// Valid credentials need one emailed capability before session issuance.
final class VerificationRequired extends SignInResult {
  /// Creates a pending-verification result.
  const VerificationRequired(this.mail);

  /// Fresh capability message for this verified credential pair.
  final EmailVerificationMail mail;
}

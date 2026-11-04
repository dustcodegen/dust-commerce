import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/account/mail.dart';
import 'package:commerce_server/src/features/account/repository/repository.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_server/server.dart';

/// Everything the account handlers need.
final class AccountDeps {
  /// Creates the dependency bundle and starts the dummy Argon2 hash.
  AccountDeps({
    required this.database,
    required this.reads,
    required this.lists,
    required this.writes,
    required this.updates,
    required this.deletes,
    required this.clock,
    this.emailVerificationMailer = const UnavailableEmailVerificationMailer(),
    this.requireEmailVerification = false,
    PasswordWorkLimiter? passwordWork,
  }) : passwordWork = passwordWork ?? PasswordWorkLimiter() {
    dummyPasswordHash = Passwords.hash(
      'not a real customer password',
      limiter: this.passwordWork,
    );
  }

  /// Clock and identifier source shared with the application.
  final Clock clock;

  /// Database used to make registration atomic.
  final CommerceDatabase database;

  /// Outbound adapter used only when email verification is enabled.
  final EmailVerificationMailer emailVerificationMailer;

  /// Account token revocation queries.
  final AccountDeleteRepository deletes;

  /// Customer address-book listing queries.
  final AccountListRepository lists;

  /// Precomputed dummy hash used to equalize unknown-account sign-in work.
  late final Future<String> dummyPasswordHash;

  /// Admission control shared by registration and sign-in.
  final PasswordWorkLimiter passwordWork;

  /// Account lookup queries.
  final AccountReadRepository reads;

  /// Whether newly registered identities must consume an emailed capability.
  final bool requireEmailVerification;

  /// Customer profile and address mutation queries.
  final AccountUpdateRepository updates;

  /// Account creation and token issuance queries.
  final AccountCreateRepository writes;
}

/// The attached account dependencies, or a configuration 500.
Future<Result<AccountDeps, Rejection>> accountDeps(Request request) =>
    stateOf<AccountDeps>(request);

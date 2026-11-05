part of '../create.dart';

/// Error crossing the Admin bootstrap boundary.
sealed class AdminBootstrapError {
  /// Creates one bootstrap error.
  const AdminBootstrapError();
}

/// A business rejection that is safe to report to the bootstrap command.
final class AdminBootstrapRejected extends AdminBootstrapError {
  /// Creates one business rejection.
  const AdminBootstrapRejected(this.failure);

  /// The stable business reason.
  final AdminBootstrapFailure failure;
}

/// A storage failure retained for diagnostics without exposing SQL details.
final class AdminBootstrapStorage extends AdminBootstrapError {
  /// Creates one storage failure.
  const AdminBootstrapStorage(this.cause);

  /// The original SQLx failure.
  final SqlxError cause;
}

/// Creates an admin profile and provider identity in one transaction.
Future<Result<AdminUserResponse, AdminBootstrapError>> bootstrapAdmin(
  CommerceDatabase database,
  AdminCredentials credentials, {
  required String Function() nextId,
  required PasswordWorkLimiter passwordWork,
  String? firstName,
  String? lastName,
}) async {
  final email = credentials.email.trim().toLowerCase();
  final passwordHash = await Passwords.hash(
    credentials.password,
    limiter: passwordWork,
  );
  final userId = nextId();
  final authIdentityId = nextId();
  final providerIdentityId = nextId();

  return transactionResult<AdminUserResponse, AdminBootstrapError>(
    database,
    (tx) async {
      final writes = AdminCreateRepository(tx);
      final inserted = await writes.insertAdmin(
        userId,
        email,
        firstName,
        lastName,
      );
      if (inserted case Err(:final error)) {
        return Err(AdminBootstrapStorage(error));
      }
      final user = optionOf(
        (inserted as Ok<AdminUserResponse?, SqlxError>).value,
      );
      if (user case None()) {
        return const Err(AdminBootstrapRejected(
          AdminBootstrapFailure.alreadyExists,
        ));
      }

      final identity = await writes.insertAuthIdentity(
        authIdentityId,
        jsonEncode({'admin_user_id': userId}),
      );
      if (identity case Err(:final error)) {
        return Err(AdminBootstrapStorage(error));
      }
      final provider = await writes.insertProviderIdentity(
        providerIdentityId,
        email,
        authIdentityId,
        jsonEncode({'password': passwordHash}),
      );
      if (provider case Err(:final error)) {
        return Err(AdminBootstrapStorage(error));
      }

      return Ok((user as Some<AdminUserResponse>).value);
    },
    storageError: AdminBootstrapStorage.new,
  );
}

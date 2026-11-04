import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_server/src/features/account/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Why an authenticated password rotation was refused.
enum ChangePasswordFailure {
  /// The supplied current password did not verify or changed concurrently.
  invalidCurrentPassword,

  /// The replacement was identical to the verified current password.
  unchanged,
}

/// Consumes one live verification capability exactly once.
Future<Result<bool, SqlxError>> confirmCustomerEmail(
  AccountUpdateRepository updates,
  String token, {
  required DateTime now,
}) async {
  final result = await updates.confirmEmail(
    await Tokens.fingerprint(token),
    now.toUtc().toIso8601String(),
  );
  return switch (result) {
    Ok(:final value) => Ok(value.rowsAffected == 1),
    Err(:final error) => Err(error),
  };
}

/// Verifies and rotates a credential, then atomically revokes every session.
Future<Result<Result<PasswordChanged, ChangePasswordFailure>, SqlxError>>
    changeCustomerPassword(
  CommerceDatabase database,
  AccountReadRepository reads,
  String customerId,
  ChangePasswordBody input, {
  required PasswordWorkLimiter passwordWork,
}) async {
  final found = await reads.credentialForCustomer(customerId);
  if (found case Err(:final error)) return Err(error);
  final credential = optionOf(
    (found as Ok<PasswordCredential?, SqlxError>).value,
  );
  if (credential case None()) {
    return const Ok(Err(ChangePasswordFailure.invalidCurrentPassword));
  }
  final current = (credential as Some<PasswordCredential>).value;
  final valid = await Passwords.verify(
    input.oldPassword,
    current.passwordHash,
    limiter: passwordWork,
  );
  if (!valid) {
    return const Ok(Err(ChangePasswordFailure.invalidCurrentPassword));
  }
  if (input.newPassword == input.oldPassword) {
    return const Ok(Err(ChangePasswordFailure.unchanged));
  }
  final newHash = await Passwords.hash(
    input.newPassword,
    limiter: passwordWork,
  );

  return database.transaction((tx) async {
    final updated = await AccountUpdateRepository(tx).updatePassword(
      current.authIdentityId,
      current.passwordHash,
      newHash,
    );
    if (updated case Err(:final error)) return Err(error);
    if ((updated as Ok<ExecResult, SqlxError>).value.rowsAffected != 1) {
      return const Ok(Err(ChangePasswordFailure.invalidCurrentPassword));
    }
    final revoked = await AccountDeleteRepository(tx).revokeIdentityTokens(
      current.authIdentityId,
    );
    if (revoked case Err(:final error)) return Err(error);
    return const Ok(Ok(PasswordChanged(success: true)));
  });
}

/// Replaces the editable profile fields of one authenticated customer.
Future<Result<Option<CustomerResponse>, SqlxError>> updateCustomerProfile(
  AccountUpdateRepository updates,
  String customerId,
  UpdateCustomerProfileBody input,
) async {
  final result = await updates.updateProfile(
    customerId,
    input.firstName,
    input.lastName,
    input.phone,
  );
  return switch (result) {
    Ok(:final value) => Ok(optionOf(value)),
    Err(:final error) => Err(error),
  };
}

/// Replaces one address only when it belongs to the authenticated customer.
Future<Result<Option<CustomerAddressResponse>, SqlxError>>
    updateCustomerAddress(
  AccountUpdateRepository updates,
  String id,
  String customerId,
  CustomerAddressInput input,
) async {
  final result = await updates.updateAddress(
    id,
    customerId,
    input.firstName,
    input.lastName,
    input.company,
    input.phone,
    input.line1,
    input.line2,
    input.city,
    input.province,
    input.postalCode,
    input.countryCode,
    input.isDefaultShipping ? 1 : 0,
    input.isDefaultBilling ? 1 : 0,
  );
  return switch (result) {
    Ok(:final value) => Ok(optionOf(value)),
    Err(:final error) => Err(error),
  };
}

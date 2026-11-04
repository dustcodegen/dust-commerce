import 'dart:convert';

import 'package:commerce_server/src/features/account/auth_result.dart';
import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/account/mail.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_server/src/features/account/repository/repository.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:commerce_server/src/infra/option.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';

/// Why a customer account was not created.
enum RegisterFailure {
  /// An active account already owns this email address.
  alreadyExists,
}

/// Creates a customer, auth identity, and email provider atomically.
Future<Result<Result<RegisteredAccount, RegisterFailure>, SqlxError>>
    registerAccount(
  CommerceDatabase database,
  RegisterAccountBody input, {
  required String Function() nextId,
  required DateTime now,
  required PasswordWorkLimiter passwordWork,
  required bool requireEmailVerification,
  Duration verificationLifetime = const Duration(days: 1),
}) async {
  final email = input.email.trim().toLowerCase();
  final passwordHash = await Passwords.hash(
    input.password,
    limiter: passwordWork,
  );
  final customerId = nextId();
  final authIdentityId = nextId();
  final providerIdentityId = nextId();
  final verificationToken =
      requireEmailVerification ? Some(Tokens.issue()) : const None<String>();
  final verificationExpiresAt = now.toUtc().add(verificationLifetime);
  return database.transaction((tx) async {
    final writes = AccountCreateRepository(tx);
    final customer = await writes.insertCustomer(
      customerId,
      email,
      input.firstName,
      input.lastName,
      input.phone,
    );
    if (customer case Err(:final error)) return Err(error);
    if ((customer as Ok<ExecResult, SqlxError>).value.rowsAffected == 0) {
      return const Ok(Err(RegisterFailure.alreadyExists));
    }

    final identity = await writes.insertAuthIdentity(
      authIdentityId,
      jsonEncode({'customer_id': customerId}),
    );
    if (identity case Err(:final error)) return Err(error);

    final provider = await writes.insertProviderIdentity(
      providerIdentityId,
      email,
      authIdentityId,
      jsonEncode({'password': passwordHash}),
    );
    if (provider case Err(:final error)) return Err(error);

    if (verificationToken case Some(value: final token)) {
      final verification = await writes.insertEmailVerification(
        authIdentityId,
        await Tokens.fingerprint(token),
        verificationExpiresAt.toIso8601String(),
      );
      if (verification case Err(:final error)) return Err(error);
    }

    return Ok(Ok(
      RegisteredAccount(
        customer: CustomerResponse(
          id: customerId,
          email: email,
          firstName: input.firstName,
          lastName: input.lastName,
          phone: input.phone,
        ),
        verification: verificationToken.map(
          (token) => EmailVerificationMail(
            recipient: email,
            token: token,
            expiresAt: verificationExpiresAt,
          ),
        ),
      ),
    ));
  });
}

/// Exchanges valid credentials for a short-lived opaque token.
Future<Result<SignInResult, SqlxError>> signIn(
  AccountReadRepository reads,
  AccountCreateRepository writes,
  AccountUpdateRepository updates,
  Credentials input, {
  required DateTime now,
  required Future<String> dummyPasswordHash,
  required PasswordWorkLimiter passwordWork,
  Duration lifetime = const Duration(days: 7),
  Duration verificationLifetime = const Duration(days: 1),
}) async {
  final found = await reads.accountByEmail(input.email.trim().toLowerCase());
  if (found case Err(:final error)) return Err(error);

  final account = optionOf(
    (found as Ok<PasswordCredential?, SqlxError>).value,
  );
  final expected = switch (account) {
    Some(value: final credential) => credential.passwordHash,
    None() => await dummyPasswordHash,
  };
  final valid = await Passwords.verify(
    input.password,
    expected,
    limiter: passwordWork,
  );
  if (account case None()) return const Ok(InvalidCredentials());
  if (!valid) return const Ok(InvalidCredentials());
  final credential = (account as Some<PasswordCredential>).value;

  if (credential.requiresEmailVerification) {
    final token = Tokens.issue();
    final expiresAt = now.toUtc().add(verificationLifetime);
    final replaced = await updates.replaceEmailVerification(
      credential.authIdentityId,
      await Tokens.fingerprint(token),
      expiresAt.toIso8601String(),
    );
    if (replaced case Err(:final error)) return Err(error);
    return Ok(VerificationRequired(EmailVerificationMail(
      recipient: input.email.trim().toLowerCase(),
      token: token,
      expiresAt: expiresAt,
    )));
  }

  final token = Tokens.issue();
  final expiresAt = now.toUtc().add(lifetime);
  final stored = await writes.insertToken(
    await Tokens.fingerprint(token),
    credential.authIdentityId,
    expiresAt.toIso8601String(),
  );
  if (stored case Err(:final error)) return Err(error);

  return Ok(SessionIssued(IssuedToken(token: token, expiresAt: expiresAt)));
}

/// Creates one reusable address for the authenticated customer.
Future<Result<CustomerAddressResponse, SqlxError>> createCustomerAddress(
  AccountCreateRepository writes,
  String customerId,
  CustomerAddressInput input, {
  required String Function() nextId,
}) =>
    writes.insertAddress(
      nextId(),
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

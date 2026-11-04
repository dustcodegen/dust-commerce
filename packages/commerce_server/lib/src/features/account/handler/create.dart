import 'package:commerce_server/src/features/account/auth_result.dart';
import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/account/deps.dart';
import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/account/mail.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_server/src/features/account/registration_response.dart';
import 'package:commerce_server/src/features/account/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<RegisterAccountBody> _registerBody =
    ValidatedExtractable(
  JsonExtractable<RegisterAccountBody>(RegisterAccountBody.fromJson),
);
const ValidatedExtractable<Credentials> _credentialsBody = ValidatedExtractable(
  JsonExtractable<Credentials>(Credentials.fromJson),
);
const ValidatedExtractable<CustomerAddressInput> _addressBody =
    ValidatedExtractable(
  JsonExtractable<CustomerAddressInput>(CustomerAddressInput.fromJson),
);

/// `POST /store/customers` — create a customer account.
Future<Result<CustomerRegistrationResponse, Rejection>> registerAccountHandler(
  Request request,
) async {
  final decoded = await _registerBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final depsResult = await accountDeps(request);
  if (depsResult case Err(:final error)) return Err(error);
  final deps = (depsResult as Ok<AccountDeps, Rejection>).value;
  if (deps.requireEmailVerification &&
      !deps.emailVerificationMailer.isAvailable) {
    return const Err(
      Rejection.status(503, 'Email verification is unavailable'),
    );
  }

  late final Result<Result<RegisteredAccount, RegisterFailure>, SqlxError>
      result;
  try {
    result = await registerAccount(
      deps.database,
      (decoded as Ok<RegisterAccountBody, Rejection>).value,
      nextId: deps.clock.nextId,
      now: deps.clock.now(),
      passwordWork: deps.passwordWork,
      requireEmailVerification: deps.requireEmailVerification,
    );
  } on PasswordCapacityException {
    return const Err(
      Rejection.status(429, 'Authentication is busy; retry shortly'),
    );
  }
  return switch (result) {
    Ok(value: Ok(value: final registration)) =>
      await _completeRegistration(deps, registration),
    Ok(value: Err(error: RegisterFailure.alreadyExists)) =>
      const Err(Rejection.conflict('A customer account already exists')),
    Err() => const Err(Rejection.internal()),
  };
}

Future<Result<CustomerRegistrationResponse, Rejection>> _completeRegistration(
  AccountDeps deps,
  RegisteredAccount registration,
) async {
  try {
    await registration.verification.match(
      some: deps.emailVerificationMailer.send,
      none: () async {},
    );
    return Ok(CustomerRegistrationResponse(
      customer: registration.customer,
      verificationRequired: registration.verification.isSome,
    ));
  } on Object {
    return const Err(Rejection.status(503, 'Verification email was not sent'));
  }
}

/// `POST /auth/customer/emailpass` — exchange credentials for a token.
Future<Result<IssuedToken, Rejection>> signInHandler(Request request) async {
  final decoded = await _credentialsBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final depsResult = await accountDeps(request);
  if (depsResult case Err(:final error)) return Err(error);
  final deps = (depsResult as Ok<AccountDeps, Rejection>).value;

  late final Result<SignInResult, SqlxError> result;
  try {
    result = await signIn(
      deps.reads,
      deps.writes,
      deps.updates,
      (decoded as Ok<Credentials, Rejection>).value,
      now: deps.clock.now(),
      dummyPasswordHash: deps.dummyPasswordHash,
      passwordWork: deps.passwordWork,
    );
  } on PasswordCapacityException {
    return const Err(
      Rejection.status(429, 'Authentication is busy; retry shortly'),
    );
  }
  return switch (result) {
    Ok(value: SessionIssued(:final token)) => Ok(token),
    Ok(value: VerificationRequired(:final mail)) =>
      await _sendVerification(deps, mail),
    Ok(value: InvalidCredentials()) =>
      const Err(Rejection.unauthorized('Invalid email or password')),
    Err() => const Err(Rejection.internal()),
  };
}

Future<Result<IssuedToken, Rejection>> _sendVerification(
  AccountDeps deps,
  EmailVerificationMail mail,
) async {
  if (!deps.emailVerificationMailer.isAvailable) {
    return const Err(
        Rejection.status(503, 'Email verification is unavailable'));
  }
  try {
    await deps.emailVerificationMailer.send(mail);
    return const Err(Rejection.forbidden('Email verification required'));
  } on Object {
    return const Err(Rejection.status(503, 'Verification email was not sent'));
  }
}

/// `POST /auth/customer/emailpass/verification/confirm` — consume a capability.
/// `POST /store/customers/me/addresses` — create an owned address.
Future<Result<CustomerAddressResponse, Rejection>> createAddressHandler(
  Request request,
) async {
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final decoded = await _addressBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final depsResult = await accountDeps(request);
  if (depsResult case Err(:final error)) return Err(error);
  final deps = (depsResult as Ok<AccountDeps, Rejection>).value;

  final result = await createCustomerAddress(
    deps.writes,
    actor.customer.id,
    (decoded as Ok<CustomerAddressInput, Rejection>).value,
    nextId: deps.clock.nextId,
  );
  return switch (result) {
    Ok(:final value) => Ok(value),
    Err() => const Err(Rejection.internal()),
  };
}

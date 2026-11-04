import 'package:commerce_server/src/features/account/crypto.dart';
import 'package:commerce_server/src/features/account/deps.dart';
import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/account/model.dart';
import 'package:commerce_server/src/features/account/service/service.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_server/server.dart';

const ValidatedExtractable<UpdateCustomerProfileBody> _profileBody =
    ValidatedExtractable(
  JsonExtractable<UpdateCustomerProfileBody>(
    UpdateCustomerProfileBody.fromJson,
  ),
);
const ValidatedExtractable<CustomerAddressInput> _addressBody =
    ValidatedExtractable(
  JsonExtractable<CustomerAddressInput>(CustomerAddressInput.fromJson),
);
const ValidatedExtractable<ChangePasswordBody> _passwordBody =
    ValidatedExtractable(
  JsonExtractable<ChangePasswordBody>(ChangePasswordBody.fromJson),
);
const ValidatedExtractable<VerifyEmailBody> _verificationBody =
    ValidatedExtractable(
  JsonExtractable<VerifyEmailBody>(VerifyEmailBody.fromJson),
);

/// `POST /auth/customer/emailpass/verification/confirm` — consume a capability.
Future<Result<EmailVerified, Rejection>> confirmEmailHandler(
  Request request,
) async {
  final decoded = await _verificationBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final depsResult = await accountDeps(request);
  if (depsResult case Err(:final error)) return Err(error);
  final deps = (depsResult as Ok<AccountDeps, Rejection>).value;
  final result = await confirmCustomerEmail(
    deps.updates,
    (decoded as Ok<VerifyEmailBody, Rejection>).value.token,
    now: deps.clock.now(),
  );
  return switch (result) {
    Ok(value: true) => const Ok(EmailVerified(success: true)),
    Ok(value: false) => const Err(Rejection.notFound('Verification not found')),
    Err() => const Err(Rejection.internal()),
  };
}

/// `PATCH /store/customers/me/password` — rotate the emailpass credential.
Future<Result<PasswordChanged, Rejection>> updatePasswordHandler(
  Request request,
) async {
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final decoded = await _passwordBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final deps = await request.state<AccountDeps>();

  late final Result<Result<PasswordChanged, ChangePasswordFailure>, SqlxError>
      result;
  try {
    result = await changeCustomerPassword(
      deps.database,
      deps.reads,
      actor.customer.id,
      (decoded as Ok<ChangePasswordBody, Rejection>).value,
      passwordWork: deps.passwordWork,
    );
  } on PasswordCapacityException {
    return const Err(
      Rejection.status(429, 'Authentication is busy; retry shortly'),
    );
  }
  return switch (result) {
    Ok(value: Ok(value: final changed)) => Ok(changed),
    Ok(value: Err(error: ChangePasswordFailure.invalidCurrentPassword)) =>
      const Err(Rejection.unprocessable({
        'old_password': ['Current password is incorrect'],
      })),
    Ok(value: Err(error: ChangePasswordFailure.unchanged)) =>
      const Err(Rejection.unprocessable({
        'new_password': ['Use a different password'],
      })),
    Err() => const Err(Rejection.internal()),
  };
}

/// `PATCH /store/customers/me` — replace editable public profile fields.
Future<Result<CustomerResponse, Rejection>> updateCustomerHandler(
  Request request,
) async {
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final decoded = await _profileBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final deps = await request.state<AccountDeps>();
  final result = await updateCustomerProfile(
    deps.updates,
    actor.customer.id,
    (decoded as Ok<UpdateCustomerProfileBody, Rejection>).value,
  );
  return switch (result) {
    Ok(value: Some(value: final customer)) => Ok(customer),
    Ok(value: None()) => const Err(Rejection.notFound('Customer')),
    Err() => const Err(Rejection.internal()),
  };
}

/// `PATCH /store/customers/me/addresses/{addressId}` — update an owned row.
Future<Result<CustomerAddressResponse, Rejection>> updateAddressHandler(
  Request request,
) async {
  final addressId = pathParametersOf(request)['addressId'];
  if (addressId == null || addressId.isEmpty) {
    return const Err(Rejection.badRequest('An address id is required'));
  }
  final actor = await request.extract(
    const Extension<AuthenticatedCustomer>(),
  );
  final decoded = await _addressBody.extract(request);
  if (decoded case Err(:final error)) return Err(error);
  final deps = await request.state<AccountDeps>();
  final result = await updateCustomerAddress(
    deps.updates,
    addressId,
    actor.customer.id,
    (decoded as Ok<CustomerAddressInput, Rejection>).value,
  );
  return switch (result) {
    Ok(value: Some(value: final address)) => Ok(address),
    Ok(value: None()) => const Err(Rejection.notFound('Address')),
    Err() => const Err(Rejection.internal()),
  };
}

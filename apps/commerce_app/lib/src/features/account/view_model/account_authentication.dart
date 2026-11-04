part of 'account_view_model.dart';

mixin _AccountAuthentication on $AccountViewModel {
  /// Exchanges [email] and [password] for a secure customer session.
  Future<bool> signIn({required String email, required String password}) async {
    if (state.isBusy) return false;
    emit(const AccountState(
      status: AccountStatus.loading,
      operation: AccountOperation.signIn,
    ));
    try {
      final token = await args.api.signIn(
        Credentials(email: email.trim(), password: password),
      );
      await args.sessions.write(token);
      final customer = await args.api.currentCustomer();
      emit(AccountState(
        status: AccountStatus.signedIn,
        customer: customer,
      ));
      return true;
    } on DioException catch (error) {
      if (error.response?.statusCode == 403) {
        emit(AccountState(
          status: AccountStatus.verificationRequired,
          operation: AccountOperation.signIn,
          verificationEmail: Some(email.trim()),
        ));
        return false;
      }
      _failAuthentication(AccountOperation.signIn, error);
      return false;
    } on Object catch (error) {
      _failAuthentication(AccountOperation.signIn, error);
      return false;
    }
  }

  /// Creates an account and signs in only when verification is disabled.
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    if (state.isBusy) return false;
    emit(const AccountState(
      status: AccountStatus.loading,
      operation: AccountOperation.register,
    ));
    try {
      final normalizedPhone = phone?.trim();
      final registration = await args.api.registerAccount(
        RegisterAccountBody(
          email: email.trim(),
          password: password,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          phone: normalizedPhone == null || normalizedPhone.isEmpty
              ? null
              : normalizedPhone,
        ),
      );
      if (registration.verificationRequired) {
        emit(AccountState(
          status: AccountStatus.verificationRequired,
          operation: AccountOperation.register,
          verificationEmail: Some(registration.customer.email),
        ));
        return true;
      }
      final token = await args.api.signIn(
        Credentials(email: email.trim(), password: password),
      );
      await args.sessions.write(token);
      emit(AccountState(
        status: AccountStatus.signedIn,
        customer: registration.customer,
      ));
      return true;
    } on Object catch (error) {
      _failAuthentication(AccountOperation.register, error);
      return false;
    }
  }

  void _failAuthentication(AccountOperation operation, Object error) =>
      emit(AccountState(
        status: AccountStatus.failed,
        operation: operation,
        message: _accountMessageOf(error, operation),
      ));
}

part of 'account_view_model.dart';

/// Password mutation kept apart from session lifecycle mechanics.
mixin _AccountPasswordMutation on $AccountViewModel {
  /// Rotates the password, then clears the now-revoked local session.
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final customer = state.customer;
    if (state.isBusy || customer == null) return false;
    emit(AccountState(
      status: AccountStatus.loading,
      customer: customer,
      operation: AccountOperation.changePassword,
    ));
    var changed = false;
    try {
      final response = await args.api.changePassword(
        ChangePasswordBody(
          oldPassword: oldPassword,
          newPassword: newPassword,
        ),
      );
      if (!response.success) throw StateError('Password was not changed');
      changed = true;
      await args.sessions.clear();
      emit(const AccountState(status: AccountStatus.signedOut));
      return true;
    } on DioException catch (error) {
      if (changed) return _finishChangedPassword();
      if (error.response?.statusCode == 401) {
        await args.sessions.clear();
        emit(const AccountState(status: AccountStatus.signedOut));
        return false;
      }
      _failPassword(error, customer);
      return false;
    } on Object catch (error) {
      if (changed) return _finishChangedPassword();
      _failPassword(error, customer);
      return false;
    }
  }

  bool _finishChangedPassword() {
    emit(const AccountState(status: AccountStatus.signedOut));
    return true;
  }

  void _failPassword(Object error, Customer customer) => emit(AccountState(
        status: AccountStatus.failed,
        customer: customer,
        operation: AccountOperation.changePassword,
        message: _accountMessageOf(error, AccountOperation.changePassword),
      ));
}

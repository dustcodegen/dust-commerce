part of 'account_view_model.dart';

/// Profile mutation behavior kept separate from session lifecycle mechanics.
mixin _AccountProfileMutation on $AccountViewModel {
  /// Replaces the authenticated customer's editable public profile.
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final customer = state.customer;
    if (state.isBusy || customer == null) return false;
    emit(AccountState(
      status: AccountStatus.loading,
      customer: customer,
      operation: AccountOperation.updateProfile,
    ));
    try {
      final updated = await args.api.updateCustomerProfile(
        UpdateCustomerProfileBody(
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          phone: phone?.trim(),
        ),
      );
      emit(AccountState(status: AccountStatus.signedIn, customer: updated));
      return true;
    } on Object catch (error) {
      emit(AccountState(
        status: AccountStatus.failed,
        customer: customer,
        operation: AccountOperation.updateProfile,
        message: _accountMessageOf(error, AccountOperation.updateProfile),
      ));
      return false;
    }
  }
}

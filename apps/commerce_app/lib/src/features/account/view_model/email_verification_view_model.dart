import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/account/model/email_verification_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/state.dart';

part 'email_verification_view_model.g.dart';

/// Dependencies for email capability confirmation.
final class EmailVerificationViewModelArgs extends ViewModelArgs {
  /// Creates verification dependencies.
  const EmailVerificationViewModelArgs({required this.api, super.observer});

  /// Generated storefront client.
  final CommerceApi api;
}

/// Confirms one email capability without retaining it in public state.
@ViewModel(
  state: EmailVerificationState,
  args: EmailVerificationViewModelArgs,
)
final class EmailVerificationViewModel extends $EmailVerificationViewModel {
  /// Creates the verification state machine.
  EmailVerificationViewModel(super.args);

  /// Consumes [token] once through the public verification endpoint.
  Future<bool> verify(String token) async {
    if (state.status == EmailVerificationStatus.verifying) return false;
    final capability = token.trim();
    if (capability.isEmpty) {
      emit(const EmailVerificationState(
        status: EmailVerificationStatus.failed,
      ));
      return false;
    }
    emit(const EmailVerificationState(
      status: EmailVerificationStatus.verifying,
    ));
    try {
      final result = await args.api.confirmEmail(
        VerifyEmailBody(token: capability),
      );
      final status = result.success
          ? EmailVerificationStatus.success
          : EmailVerificationStatus.failed;
      emit(EmailVerificationState(status: status));
      return result.success;
    } on Object {
      emit(const EmailVerificationState(
        status: EmailVerificationStatus.failed,
      ));
      return false;
    }
  }
}

import 'package:admin_app/src/promotion/admin_promotion_api.dart';
import 'package:admin_app/src/promotion/admin_promotion_create_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_promotion_create_view_model.g.dart';

/// Dependencies for the focused promotion creation form.
final class AdminPromotionCreateViewModelArgs extends ViewModelArgs {
  /// Creates promotion-command dependencies.
  const AdminPromotionCreateViewModelArgs({required this.api, super.observer});

  /// Generated Admin API client.
  final AdminPromotionApi api;
}

/// Commits one promotion and keeps transport details out of the form.
@ViewModel(
  state: AdminPromotionCreateState,
  args: AdminPromotionCreateViewModelArgs,
)
final class AdminPromotionCreateViewModel
    extends $AdminPromotionCreateViewModel {
  /// Creates the promotion command state machine.
  AdminPromotionCreateViewModel(super.args);

  /// Clears stale failure text before opening the form again.
  void clearFailure() => emit(const AdminPromotionCreateState());

  /// Creates one promotion and returns the server-owned row on success.
  Future<Option<AdminPromotion>> create(AdminCreatePromotion input) async {
    emit(const AdminPromotionCreateState(
      status: AdminPromotionCreateStatus.submitting,
    ));
    try {
      final response = await args.api.createPromotion(input);
      emit(const AdminPromotionCreateState());
      return Some(response.promotion);
    } on DioException catch (error) {
      emit(state.copyWith(
        status: AdminPromotionCreateStatus.failed,
        failure: Some(_failure(error)),
      ));
      return const None();
    } on Object {
      emit(state.copyWith(
        status: AdminPromotionCreateStatus.failed,
        failure: const Some('Unable to create this promotion. Try again.'),
      ));
      return const None();
    }
  }

  String _failure(DioException error) => switch (error.response?.statusCode) {
        401 => 'Your admin session has expired.',
        409 => 'Another promotion already uses this code.',
        422 => 'Check the promotion values and try again.',
        _ => 'Unable to create this promotion. Try again.',
      };
}

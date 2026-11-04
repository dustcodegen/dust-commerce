import 'package:admin_app/src/promotion/admin_promotion_api.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_state.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_promotion_detail_view_model.g.dart';

/// Dependencies for one authenticated promotion detail route.
final class AdminPromotionDetailViewModelArgs extends ViewModelArgs {
  /// Creates detail dependencies.
  const AdminPromotionDetailViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated admin-only API client.
  final AdminPromotionApi api;
}

/// Loads one explicit promotion by stable identifier.
@ViewModel(
  state: AdminPromotionDetailState,
  args: AdminPromotionDetailViewModelArgs,
)
final class AdminPromotionDetailViewModel
    extends $AdminPromotionDetailViewModel {
  /// Creates the detail state machine.
  AdminPromotionDetailViewModel(super.args);

  int _revision = 0;

  /// Loads one active promotion.
  Future<void> load(String id) async {
    final revision = ++_revision;
    emit(const AdminPromotionDetailState(
      status: AdminPromotionDetailStatus.loading,
    ));
    try {
      final detail = await args.api.promotion(id);
      if (revision != _revision) return;
      emit(AdminPromotionDetailState(
        status: AdminPromotionDetailStatus.ready,
        promotion: Some(detail.promotion),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 404
          ? 'This promotion no longer exists.'
          : error.response?.statusCode == 401
              ? 'Your admin session has expired.'
              : 'Unable to load this promotion. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load this promotion. Try again.');
    }
  }

  void _fail(String message) => emit(AdminPromotionDetailState(
        status: AdminPromotionDetailStatus.failed,
        failure: Some(message),
      ));
}

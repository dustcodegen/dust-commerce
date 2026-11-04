import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product_option/admin_product_option_detail_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_product_option_detail_view_model.g.dart';

/// Dependencies for one authenticated product-option detail.
final class AdminProductOptionDetailViewModelArgs extends ViewModelArgs {
  /// Creates product-option detail dependencies.
  const AdminProductOptionDetailViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated admin-only API client.
  final AdminApi api;
}

/// Loads and edits one option without exposing Dio responses to widgets.
@ViewModel(
  state: AdminProductOptionDetailState,
  args: AdminProductOptionDetailViewModelArgs,
)
final class AdminProductOptionDetailViewModel
    extends $AdminProductOptionDetailViewModel {
  /// Creates the product-option detail state machine.
  AdminProductOptionDetailViewModel(super.args);

  int _revision = 0;

  /// Loads the complete allowlisted detail for [id].
  Future<void> load(String id) async {
    final revision = ++_revision;
    emit(const AdminProductOptionDetailState(
      status: AdminProductOptionDetailStatus.loading,
    ));
    try {
      final option = await args.api.productOption(id);
      if (revision != _revision) return;
      emit(AdminProductOptionDetailState(
        status: AdminProductOptionDetailStatus.ready,
        productOption: Some(option),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 404
          ? 'This product option no longer exists.'
          : error.response?.statusCode == 401
              ? 'Your admin session has expired.'
              : 'Unable to load this product option. Try again.');
    } catch (_) {
      if (revision != _revision) return;
      _fail('Unable to load this product option. Try again.');
    }
  }

  /// Replaces the option fields and publishes the refreshed response.
  Future<bool> update(String id, AdminUpdateProductOption input) async {
    final current = state.productOption;
    emit(AdminProductOptionDetailState(
      status: AdminProductOptionDetailStatus.saving,
      productOption: current,
    ));
    try {
      final option = await args.api.updateProductOption(id, input);
      emit(AdminProductOptionDetailState(
        status: AdminProductOptionDetailStatus.ready,
        productOption: Some(option),
      ));
      return true;
    } on DioException catch (error) {
      _updateFailed(
          current,
          switch (error.response?.statusCode) {
            409 => _conflictMessage(error.response?.data),
            422 => 'Use unique, non-empty option values.',
            404 => 'This product option no longer exists.',
            401 => 'Your admin session has expired.',
            _ => 'Unable to save this product option. Try again.',
          });
      return false;
    } catch (_) {
      _updateFailed(current, 'Unable to save this product option. Try again.');
      return false;
    }
  }

  /// Clears editor-scoped failure without discarding loaded data.
  void clearFailure() => emit(AdminProductOptionDetailState(
        status: state.status,
        productOption: state.productOption,
      ));

  void _updateFailed(
    Option<AdminProductOptionDetail> option,
    String message,
  ) =>
      emit(AdminProductOptionDetailState(
        status: AdminProductOptionDetailStatus.ready,
        productOption: option,
        failure: Some(message),
      ));

  void _fail(String message) => emit(AdminProductOptionDetailState(
        status: AdminProductOptionDetailStatus.failed,
        failure: Some(message),
      ));
}

String _conflictMessage(Object? body) => switch (body) {
      {'error': 'Another option already uses this title'} =>
        'Another option already uses this title.',
      _ => 'A product variant still uses one of these values.',
    };

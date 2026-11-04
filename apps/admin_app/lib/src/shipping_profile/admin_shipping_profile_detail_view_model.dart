import 'package:admin_app/src/shipping_profile/admin_shipping_profile_api.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_state.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_shipping_profile_detail_view_model.g.dart';

/// Dependencies for one authenticated shipping-profile detail route.
final class AdminShippingProfileDetailViewModelArgs extends ViewModelArgs {
  /// Creates detail dependencies.
  const AdminShippingProfileDetailViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated admin-only API client.
  final AdminShippingProfileApi api;
}

/// Loads one explicit fulfillment profile by stable identifier.
@ViewModel(
  state: AdminShippingProfileDetailState,
  args: AdminShippingProfileDetailViewModelArgs,
)
final class AdminShippingProfileDetailViewModel
    extends $AdminShippingProfileDetailViewModel {
  /// Creates the detail state machine.
  AdminShippingProfileDetailViewModel(super.args);

  int _revision = 0;

  /// Loads one active profile.
  Future<void> load(String id) async {
    final revision = ++_revision;
    emit(const AdminShippingProfileDetailState(
      status: AdminShippingProfileDetailStatus.loading,
    ));
    try {
      final profile = await args.api.find(id);
      if (revision != _revision) return;
      emit(AdminShippingProfileDetailState(
        status: AdminShippingProfileDetailStatus.ready,
        shippingProfile: Some(profile),
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 404
          ? 'This shipping profile no longer exists.'
          : error.response?.statusCode == 401
              ? 'Your admin session has expired.'
              : 'Unable to load this shipping profile. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load this shipping profile. Try again.');
    }
  }

  void _fail(String message) => emit(AdminShippingProfileDetailState(
        status: AdminShippingProfileDetailStatus.failed,
        failure: Some(message),
      ));
}

import 'package:admin_app/src/order/admin_fulfillment_context_state.dart';
import 'package:admin_app/src/order/admin_order_detail_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_fulfillment_context_view_model.g.dart';

/// Dependencies for fulfillment choice discovery.
final class AdminFulfillmentContextViewModelArgs extends ViewModelArgs {
  /// Creates choice dependencies.
  const AdminFulfillmentContextViewModelArgs(
      {required this.api, super.observer});

  /// Generated client using Dio-level authorization.
  final AdminOrderDetailApi api;
}

/// Owns location and method selection independently from order detail.
@ViewModel(
  state: AdminFulfillmentContextState,
  args: AdminFulfillmentContextViewModelArgs,
)
final class AdminFulfillmentContextViewModel
    extends $AdminFulfillmentContextViewModel {
  /// Creates the fulfillment choice state machine.
  AdminFulfillmentContextViewModel(super.args);

  int _revision = 0;
  String _regionId = '';

  /// Loads active locations and methods for one order region.
  Future<void> load(
    String regionId, {
    Option<String> preferredLocationId = const None(),
  }) async {
    final revision = ++_revision;
    _regionId = regionId;
    emit(const AdminFulfillmentContextState(
      status: AdminFulfillmentContextStatus.loading,
    ));
    try {
      final page = await args.api.stockLocations('', 100, 0);
      if (revision != _revision) return;
      final selected =
          _selectedLocation(page.stockLocations, preferredLocationId);
      if (selected case None()) {
        emit(AdminFulfillmentContextState(
          status: AdminFulfillmentContextStatus.ready,
          stockLocations: page.stockLocations,
        ));
        return;
      }
      await _loadOptions(
        revision,
        page.stockLocations,
        (selected as Some<String>).value,
      );
    } on DioException catch (error) {
      if (revision == _revision) _fail(error);
    } on Object {
      if (revision == _revision) _failUnknown();
    }
  }

  /// Selects a known location and reloads its compatible methods.
  Future<void> selectLocation(String locationId) async {
    if (!state.stockLocations.any((location) => location.id == locationId)) {
      return;
    }
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminFulfillmentContextStatus.loading,
      selectedLocationId: Some(locationId),
      failure: const None(),
    ));
    try {
      await _loadOptions(revision, state.stockLocations, locationId);
    } on DioException catch (error) {
      if (revision == _revision) _fail(error);
    } on Object {
      if (revision == _revision) _failUnknown();
    }
  }

  Future<void> _loadOptions(
    int revision,
    List<AdminStockLocation> locations,
    String locationId,
  ) async {
    final page = await args.api.fulfillmentShippingOptions(
      locationId,
      _regionId,
      '',
      100,
      0,
    );
    if (revision != _revision) return;
    emit(AdminFulfillmentContextState(
      status: AdminFulfillmentContextStatus.ready,
      stockLocations: locations,
      shippingOptions: page.shippingOptions,
      selectedLocationId: Some(locationId),
    ));
  }

  void _fail(DioException error) => emit(state.copyWith(
        status: AdminFulfillmentContextStatus.failed,
        failure: Some(error.response?.statusCode == 401
            ? 'Your admin session has expired.'
            : 'Unable to load fulfillment choices. Try again.'),
      ));

  void _failUnknown() => emit(state.copyWith(
        status: AdminFulfillmentContextStatus.failed,
        failure: const Some('Unable to load fulfillment choices. Try again.'),
      ));
}

Option<String> _selectedLocation(
  List<AdminStockLocation> locations,
  Option<String> preferred,
) {
  if (preferred case Some(:final value)) {
    if (locations.any((location) => location.id == value)) return Some(value);
  }
  return locations.isEmpty ? const None() : Some(locations.first.id);
}

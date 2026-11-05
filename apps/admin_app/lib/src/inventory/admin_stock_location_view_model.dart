import 'package:admin_app/src/inventory/admin_stock_location_api.dart';
import 'package:admin_app/src/inventory/admin_stock_location_state.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_stock_location_view_model.g.dart';

/// Dependencies for the Inventory/Locations table.
final class AdminStockLocationViewModelArgs extends ViewModelArgs {
  /// Creates location-list dependencies.
  const AdminStockLocationViewModelArgs({required this.api, super.observer});

  /// Dedicated Admin API contract.
  final AdminStockLocationApi api;
}

/// Loads protected stock locations for the merchant shell.
@ViewModel(
  state: AdminStockLocationState,
  args: AdminStockLocationViewModelArgs,
)
final class AdminStockLocationViewModel extends $AdminStockLocationViewModel {
  /// Creates the location state machine.
  AdminStockLocationViewModel(super.args);

  int _revision = 0;

  /// Searches from the first page.
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Loads one bounded page from the protected location endpoint.
  Future<void> load({String? query, int? offset}) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminStockLocationStatus.loading,
      query: nextQuery,
      offset: nextOffset,
      failure: const None(),
    ));
    try {
      final page = await args.api.list(nextQuery, state.limit, nextOffset);
      if (revision != _revision) return;
      emit(AdminStockLocationState(
        status: AdminStockLocationStatus.ready,
        stockLocations: page.stockLocations,
        count: page.count,
        limit: page.limit,
        offset: page.offset,
        query: nextQuery,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load stock locations. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load stock locations. Try again.');
    }
  }

  /// Loads the preceding page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _fail(String message) => emit(state.copyWith(
        status: AdminStockLocationStatus.failed,
        failure: Some(message),
      ));
}

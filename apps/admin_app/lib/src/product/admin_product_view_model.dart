import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product/admin_product_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_product_view_model.g.dart';
part 'admin_product_export.dart';
part 'admin_product_filters.dart';
part 'admin_product_import.dart';

/// Dependencies for the authenticated merchant catalogue.
final class AdminProductViewModelArgs extends ViewModelArgs {
  /// Creates catalogue dependencies.
  const AdminProductViewModelArgs({required this.api, super.observer});

  /// Generated admin-only API client.
  final AdminApi api;
}

/// Loads and pages the merchant catalogue without widget-owned responses.
@ViewModel(state: AdminProductState, args: AdminProductViewModelArgs)
final class AdminProductViewModel extends $AdminProductViewModel {
  /// Creates the catalogue state machine.
  AdminProductViewModel(super.args);

  int _revision = 0;

  /// Retires one product and refreshes the current server-owned page.
  Future<bool> delete(String id) async {
    final revision = ++_revision;
    final current = state;
    emit(current.copyWith(
      status: AdminProductStatus.loading,
      failure: const None(),
    ));
    try {
      await args.api.deleteProduct(id);
      if (revision != _revision) return true;
      final previousPage = current.products.length == 1 && current.offset > 0;
      await load(
        query: current.query,
        offset: previousPage ? current.offset - current.limit : current.offset,
      );
      return true;
    } on DioException catch (error) {
      if (revision != _revision) return false;
      _deleteFailed(
        current,
        error.response?.statusCode == 404
            ? 'This product no longer exists.'
            : error.response?.statusCode == 401
                ? 'Your admin session has expired.'
                : 'Unable to delete this product. Try again.',
      );
      return false;
    } on Object {
      if (revision != _revision) return false;
      _deleteFailed(current, 'Unable to delete this product. Try again.');
      return false;
    }
  }

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Loads the real type and tag choices used by Medusa's filter menu.
  Future<void> loadFilterOptions() async {
    if (state.filterOptionsStatus == AdminFilterOptionsStatus.loading ||
        state.filterOptionsStatus == AdminFilterOptionsStatus.ready) {
      return;
    }
    emit(state.copyWith(
      filterOptionsStatus: AdminFilterOptionsStatus.loading,
      filterOptionsFailure: const None(),
    ));
    try {
      final responses = await Future.wait<Object>([
        args.api.listProductTypes('', 1000, 0),
        args.api.listProductTags('', 1000, 0),
      ]);
      final types = responses[0] as AdminProductTypeList;
      final tags = responses[1] as AdminProductTagList;
      emit(state.copyWith(
        filterOptionsStatus: AdminFilterOptionsStatus.ready,
        filterOptionsFailure: const None(),
        productTypes: List.unmodifiable(types.productTypes),
        productTags: List.unmodifiable(tags.productTags),
      ));
    } on DioException catch (error) {
      _filterOptionsFailed(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load filter choices. Try again.');
    } on Object {
      _filterOptionsFailed('Unable to load filter choices. Try again.');
    }
  }

  /// Loads one bounded catalogue page.
  Future<void> load({
    String? query,
    int? offset,
    List<AdminProductLifecycle>? statuses,
    List<String>? tagIds,
    List<String>? typeIds,
    AdminDateFilter? createdAt,
    AdminDateFilter? updatedAt,
    AdminProductOrder? order,
  }) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextStatuses = statuses ?? state.statuses;
    final nextTagIds = tagIds ?? state.tagIds;
    final nextTypeIds = typeIds ?? state.typeIds;
    final nextCreatedAt = createdAt ?? state.createdAt;
    final nextUpdatedAt = updatedAt ?? state.updatedAt;
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminProductStatus.loading,
      products: state.products,
      offset: nextOffset,
      query: nextQuery,
      statuses: nextStatuses,
      tagIds: nextTagIds,
      typeIds: nextTypeIds,
      createdAt: nextCreatedAt,
      updatedAt: nextUpdatedAt,
      order: nextOrder,
    ));
    try {
      final result = await args.api.listProducts(
        nextQuery,
        nextStatuses.map((status) => status.name).join(','),
        nextTagIds.join(','),
        nextTypeIds.join(','),
        nextCreatedAt.isEmpty ? '' : nextCreatedAt.parameter,
        nextUpdatedAt.isEmpty ? '' : nextUpdatedAt.parameter,
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(state.copyWith(
        status: AdminProductStatus.ready,
        products: result.products,
        count: result.count,
        limit: result.limit,
        offset: result.offset,
        query: nextQuery,
        statuses: nextStatuses,
        tagIds: nextTagIds,
        typeIds: nextTypeIds,
        createdAt: nextCreatedAt,
        updatedAt: nextUpdatedAt,
        order: nextOrder,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load products. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load products. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  void _deleteFailed(AdminProductState current, String message) =>
      emit(current.copyWith(
        status: AdminProductStatus.ready,
        failure: Some(message),
      ));

  void _filterOptionsFailed(String message) => emit(state.copyWith(
        filterOptionsStatus: AdminFilterOptionsStatus.failed,
        filterOptionsFailure: Some(message),
      ));

  void _fail(String message) => emit(state.copyWith(
        status: AdminProductStatus.failed,
        failure: Some(message),
      ));
}

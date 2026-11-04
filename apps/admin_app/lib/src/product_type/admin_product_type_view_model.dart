import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product_type/admin_product_type_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_product_type_view_model.g.dart';

/// Typed result of a product-type deletion attempt.
enum AdminProductTypeDeleteOutcome {
  /// The product type was retired.
  deleted,

  /// The authenticated admin session has expired.
  expired,

  /// The operation failed for another display-safe reason.
  failed,
}

/// Dependencies for the product-types settings table.
final class AdminProductTypeViewModelArgs extends ViewModelArgs {
  /// Creates product-type dependencies.
  const AdminProductTypeViewModelArgs({required this.api, super.observer});

  /// Generated admin-only API client.
  final AdminApi api;
}

/// Loads, searches, and mutates reusable product classifications.
@ViewModel(state: AdminProductTypeState, args: AdminProductTypeViewModelArgs)
final class AdminProductTypeViewModel extends $AdminProductTypeViewModel {
  /// Creates the product-type state machine.
  AdminProductTypeViewModel(super.args);

  int _revision = 0;

  /// Clears display feedback before opening a new mutation surface.
  void clearFailure() => emit(AdminProductTypeState(
        status: state.status == AdminProductTypeStatus.failed
            ? AdminProductTypeStatus.ready
            : state.status,
        productTypes: state.productTypes,
        count: state.count,
        limit: state.limit,
        offset: state.offset,
        query: state.query,
      ));

  /// Loads the first page for [query].
  Future<void> search(String query) => load(query: query, offset: 0);

  /// Creates one product type and refreshes the first list page.
  Future<Option<AdminProductType>> create(AdminCreateProductType input) async {
    try {
      final productType = await args.api.createProductType(input);
      await load(offset: 0);
      return Some(productType);
    } on DioException catch (error) {
      _fail(_writeFailure(error, 'create'));
      return const None();
    } catch (_) {
      _fail('Unable to create this product type. Try again.');
      return const None();
    }
  }

  /// Renames one product type and refreshes the current list.
  Future<Option<AdminProductType>> update(
    String id,
    AdminUpdateProductType input,
  ) async {
    try {
      final productType = await args.api.updateProductType(id, input);
      await load();
      return Some(productType);
    } on DioException catch (error) {
      _fail(_writeFailure(error, 'update'));
      return const None();
    } catch (_) {
      _fail('Unable to update this product type. Try again.');
      return const None();
    }
  }

  /// Deletes one product type and refreshes the current list.
  Future<AdminProductTypeDeleteOutcome> delete(String id) async {
    try {
      await args.api.deleteProductType(id);
      await load(offset: 0);
      return AdminProductTypeDeleteOutcome.deleted;
    } on DioException catch (error) {
      return error.response?.statusCode == 401
          ? AdminProductTypeDeleteOutcome.expired
          : AdminProductTypeDeleteOutcome.failed;
    } catch (_) {
      return AdminProductTypeDeleteOutcome.failed;
    }
  }

  /// Loads one bounded product-type page.
  Future<void> load({String? query, int? offset}) async {
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final revision = ++_revision;
    emit(AdminProductTypeState(
      status: AdminProductTypeStatus.loading,
      productTypes: state.productTypes,
      count: state.count,
      limit: state.limit,
      offset: nextOffset,
      query: nextQuery,
    ));
    try {
      final result = await args.api.listProductTypes(
        nextQuery,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(AdminProductTypeState(
        status: AdminProductTypeStatus.ready,
        productTypes: result.productTypes,
        count: result.count,
        limit: result.limit,
        offset: result.offset,
        query: nextQuery,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load product types. Try again.');
    } catch (_) {
      if (revision != _revision) return;
      _fail('Unable to load product types. Try again.');
    }
  }

  /// Loads the preceding server page.
  Future<void> previous() =>
      load(offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following server page.
  Future<void> next() => load(offset: state.offset + state.limit);

  String _writeFailure(DioException error, String operation) =>
      switch (error.response?.statusCode) {
        409 => 'Another product type already uses this value.',
        422 => 'Enter a product type.',
        401 => 'Your admin session has expired.',
        404 => 'This product type no longer exists.',
        _ => 'Unable to $operation this product type. Try again.',
      };

  void _fail(String message) => emit(AdminProductTypeState(
        status: AdminProductTypeStatus.failed,
        productTypes: state.productTypes,
        count: state.count,
        limit: state.limit,
        offset: state.offset,
        query: state.query,
        failure: Some(message),
      ));
}

import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_product_type_detail_view_model.g.dart';

/// Dependencies for one authenticated product-type detail route.
final class AdminProductTypeDetailViewModelArgs extends ViewModelArgs {
  /// Creates detail dependencies.
  const AdminProductTypeDetailViewModelArgs({
    required this.api,
    super.observer,
  });

  /// Generated admin-only API client.
  final AdminApi api;
}

/// Loads one type and its linked products through separate allowlisted APIs.
@ViewModel(
  state: AdminProductTypeDetailState,
  args: AdminProductTypeDetailViewModelArgs,
)
final class AdminProductTypeDetailViewModel
    extends $AdminProductTypeDetailViewModel {
  /// Creates the product-type detail state machine.
  AdminProductTypeDetailViewModel(super.args);

  String _id = '';
  int _revision = 0;

  /// Loads [id] and one bounded page of products assigned to it.
  Future<void> load(
    String id, {
    String? query,
    int? offset,
    AdminProductOrder? order,
  }) async {
    _id = id;
    final nextQuery = (query ?? state.query).trim();
    final nextOffset = (offset ?? state.offset).clamp(0, 1 << 31);
    final nextOrder = order ?? state.order;
    final revision = ++_revision;
    emit(state.copyWith(
      status: AdminProductTypeDetailStatus.loading,
      offset: nextOffset,
      query: nextQuery,
      order: nextOrder,
      failure: const None(),
    ));
    try {
      final productType = await args.api.productType(id);
      final result = await args.api.listProducts(
        nextQuery,
        '',
        '',
        id,
        '',
        '',
        nextOrder.parameter,
        state.limit,
        nextOffset,
      );
      if (revision != _revision) return;
      emit(AdminProductTypeDetailState(
        status: AdminProductTypeDetailStatus.ready,
        productType: Some(productType),
        products: result.products,
        count: result.count,
        limit: result.limit,
        offset: result.offset,
        query: nextQuery,
        order: nextOrder,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 404
          ? 'This product type no longer exists.'
          : error.response?.statusCode == 401
              ? 'Your admin session has expired.'
              : 'Unable to load this product type. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load this product type. Try again.');
    }
  }

  /// Loads the first linked-product page for [query].
  Future<void> search(String query) => load(_id, query: query, offset: 0);

  /// Applies one Medusa-supported linked-product ordering.
  Future<void> orderBy(AdminProductOrder order) =>
      load(_id, order: order, offset: 0);

  /// Loads the preceding linked-product page.
  Future<void> previous() =>
      load(_id, offset: (state.offset - state.limit).clamp(0, 1 << 31));

  /// Loads the following linked-product page.
  Future<void> next() => load(_id, offset: state.offset + state.limit);

  void _fail(String message) => emit(AdminProductTypeDetailState(
        status: AdminProductTypeDetailStatus.failed,
        failure: Some(message),
      ));
}

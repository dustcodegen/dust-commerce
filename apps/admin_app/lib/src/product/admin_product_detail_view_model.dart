import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/product/admin_product_detail_state.dart';
import 'package:admin_app/src/product/admin_product_sales_channel_api.dart';
import 'package:admin_app/src/product/admin_product_shipping_profile_api.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'admin_product_detail_view_model.g.dart';
part 'admin_product_detail_media_view_model.dart';
part 'admin_product_detail_organization_view_model.dart';
part 'admin_product_detail_pricing_view_model.dart';
part 'admin_product_detail_sales_channel_view_model.dart';
part 'admin_product_detail_shipping_profile_view_model.dart';
part 'admin_product_detail_stock_view_model.dart';
part 'admin_product_detail_variant_view_model.dart';

/// Dependencies for one authenticated merchant product detail.
final class AdminProductDetailViewModelArgs extends ViewModelArgs {
  /// Creates product detail dependencies.
  const AdminProductDetailViewModelArgs({
    required this.api,
    required this.salesChannels,
    required this.shippingProfiles,
    super.observer,
  });

  /// Generated admin-only API client.
  final AdminApi api;

  /// Product-specific and global channel reads sharing Dio authorization.
  final AdminProductSalesChannelApi salesChannels;

  /// Product fulfillment reads and writes sharing Dio authorization.
  final AdminProductShippingProfileApi shippingProfiles;
}

/// Loads one product without exposing Dio responses to widgets.
@ViewModel(
  state: AdminProductDetailState,
  args: AdminProductDetailViewModelArgs,
)
final class AdminProductDetailViewModel extends $AdminProductDetailViewModel {
  /// Creates the product detail state machine.
  AdminProductDetailViewModel(super.args);

  int _revision = 0;

  /// Loads the complete allowlisted detail for [id].
  Future<void> load(String id) async {
    final revision = ++_revision;
    emit(const AdminProductDetailState(
      status: AdminProductDetailStatus.loading,
    ));
    try {
      final product = await args.api.product(id);
      final channels = await _loadSalesChannels(id);
      if (revision != _revision) return;
      emit(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: Some(product),
        salesChannels: channels.$1,
        totalSalesChannels: channels.$2,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _fail(error.response?.statusCode == 404
          ? 'This product no longer exists.'
          : error.response?.statusCode == 401
              ? 'Your admin session has expired.'
              : 'Unable to load this product. Try again.');
    } on Object {
      if (revision != _revision) return;
      _fail('Unable to load this product. Try again.');
    }
  }

  /// Replaces supported general fields and publishes the refreshed response.
  Future<bool> update(String id, AdminUpdateProduct input) async {
    final current = state.product;
    emit(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
      salesChannels: state.salesChannels,
      totalSalesChannels: state.totalSalesChannels,
    ));
    try {
      final product = await args.api.updateProduct(id, input);
      emit(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: Some(product),
        salesChannels: state.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));
      return true;
    } on DioException catch (error) {
      final message = switch (error.response?.statusCode) {
        409 => 'This handle is already in use.',
        422 => 'Check the product details and try again.',
        404 => 'This product no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to save this product. Try again.',
      };
      emit(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: current,
        failure: Some(message),
        salesChannels: state.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));
      return false;
    } on Object {
      emit(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: current,
        failure: const Some('Unable to save this product. Try again.'),
        salesChannels: state.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));
      return false;
    }
  }

  /// Clears a drawer-scoped failure without discarding loaded product data.
  void clearFailure() => emit(AdminProductDetailState(
        status: state.status,
        product: state.product,
        salesChannels: state.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));

  void _emitMedia(AdminProductDetailState value) => emit(value.copyWith(
        salesChannels: state.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));

  void _emitSalesChannels(AdminProductDetailState value) => emit(value);

  void _emitShippingProfile(AdminProductDetailState value) => emit(value);

  void _emitVariant(AdminProductDetailState value) => emit(value.copyWith(
        salesChannels: state.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));

  void _updateFailed(Option<AdminProductDetail> product, String message) =>
      emit(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: product,
        failure: Some(message),
        salesChannels: state.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));

  void _fail(String message) => emit(AdminProductDetailState(
        status: AdminProductDetailStatus.failed,
        failure: Some(message),
      ));

  Future<(List<AdminSalesChannel>, Option<int>)> _loadSalesChannels(
    String id,
  ) async {
    try {
      final results = await Future.wait([
        args.salesChannels.productSalesChannels(id),
        args.salesChannels.allSalesChannels('', 1000, 0),
      ]);
      return (results.first.salesChannels, Some(results.last.count));
    } on Object {
      return (const <AdminSalesChannel>[], const None<int>());
    }
  }
}

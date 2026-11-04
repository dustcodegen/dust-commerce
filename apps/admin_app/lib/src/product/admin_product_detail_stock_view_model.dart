part of 'admin_product_detail_view_model.dart';

/// Product-stock operations kept separate from product editing and loading.
extension AdminProductDetailStockActions on AdminProductDetailViewModel {
  /// Replaces selected aggregate stock rows and publishes refreshed detail.
  Future<bool> updateProductStock(
    String productId,
    AdminUpdateProductStock input,
  ) async {
    final current = state.product;
    _emitVariant(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
    ));
    try {
      final product = await args.api.updateProductStock(productId, input);
      _emitVariant(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: Some(product),
      ));
      return true;
    } on DioException catch (error) {
      _updateFailed(
        current,
        switch (error.response?.statusCode) {
          422 => 'Choose at least one variant and enter valid stock.',
          404 => 'A selected product variant no longer exists.',
          401 => 'Your admin session has expired.',
          _ => 'Unable to save product stock. Try again.',
        },
      );
      return false;
    } on Object {
      _updateFailed(current, 'Unable to save product stock. Try again.');
      return false;
    }
  }
}

part of 'admin_product_detail_view_model.dart';

/// Variant operations kept separate from the product detail loader.
extension AdminProductDetailVariantActions on AdminProductDetailViewModel {
  /// Replaces one variant and publishes the refreshed product response.
  Future<bool> updateVariant(
    String productId,
    String variantId,
    AdminUpdateProductVariant input,
  ) async {
    final current = state.product;
    _emitVariant(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
    ));
    try {
      final product = await args.api.updateProductVariant(
        productId,
        variantId,
        input,
      );
      _emitVariant(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: Some(product),
      ));
      return true;
    } on DioException catch (error) {
      _updateFailed(
        current,
        switch (error.response?.statusCode) {
          409 => 'This SKU is already in use.',
          422 => 'Choose one unique value for every product option.',
          404 => 'This product variant no longer exists.',
          401 => 'Your admin session has expired.',
          _ => 'Unable to save this variant. Try again.',
        },
      );
      return false;
    } on Object {
      _updateFailed(current, 'Unable to save this variant. Try again.');
      return false;
    }
  }
}

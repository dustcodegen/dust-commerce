part of 'admin_product_detail_view_model.dart';

/// Organization operations kept separate from general product replacement.
extension AdminProductDetailOrganizationActions on AdminProductDetailViewModel {
  /// Replaces or clears one product type and publishes refreshed detail.
  Future<bool> updateOrganization(
    String productId,
    AdminUpdateProductOrganization input,
  ) async {
    final current = state.product;
    _emitVariant(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
    ));
    try {
      final product =
          await args.api.updateProductOrganization(productId, input);
      _emitVariant(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: Some(product),
      ));
      return true;
    } on DioException catch (error) {
      _updateFailed(
        current,
        switch (error.response?.statusCode) {
          422 => 'Choose an active product type.',
          404 => 'This product no longer exists.',
          401 => 'Your admin session has expired.',
          _ => 'Unable to save product organization. Try again.',
        },
      );
      return false;
    } on Object {
      _updateFailed(
        current,
        'Unable to save product organization. Try again.',
      );
      return false;
    }
  }
}

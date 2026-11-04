part of 'admin_product_detail_view_model.dart';

/// Variant-price operations kept separate from product loading and editing.
extension AdminProductDetailPricingActions on AdminProductDetailViewModel {
  /// Reads active currencies from the server-owned selling-region context.
  Future<Option<List<String>>> pricingCurrencies() async {
    try {
      final context = await args.api.productCreateContext();
      return Some(context.currencyCodes);
    } on DioException catch (error) {
      _updateFailed(
        state.product,
        error.response?.statusCode == 401
            ? 'Your admin session has expired.'
            : 'Unable to load active currencies. Try again.',
      );
      return const None();
    } on Object {
      _updateFailed(
        state.product,
        'Unable to load active currencies. Try again.',
      );
      return const None();
    }
  }

  /// Replaces one variant's complete active-currency price graph.
  Future<bool> updateVariantPrices(
    String productId,
    String variantId,
    AdminUpdateVariantPrices input,
  ) async {
    final current = state.product;
    _emitVariant(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
    ));
    try {
      final product = await args.api.updateProductVariantPrices(
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
          422 => 'Set one price for every active currency.',
          404 => 'This product variant no longer exists.',
          401 => 'Your admin session has expired.',
          _ => 'Unable to save variant prices. Try again.',
        },
      );
      return false;
    } on Object {
      _updateFailed(current, 'Unable to save variant prices. Try again.');
      return false;
    }
  }
}

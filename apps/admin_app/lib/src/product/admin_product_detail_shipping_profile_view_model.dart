part of 'admin_product_detail_view_model.dart';

/// Shipping-profile actions isolated from the core detail loader.
extension AdminProductDetailShippingProfileActions
    on AdminProductDetailViewModel {
  /// Loads one searchable page for Medusa's profile combobox.
  Future<Option<AdminShippingProfileList>> shippingProfileChoices({
    String query = '',
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return Some(await args.shippingProfiles.shippingProfiles(
        query.trim(),
        limit,
        offset,
      ));
    } on DioException catch (error) {
      _updateFailed(
        state.product,
        error.response?.statusCode == 401
            ? 'Your admin session has expired.'
            : 'Unable to load shipping profiles. Try again.',
      );
      return const None();
    } on Object {
      _updateFailed(
        state.product,
        'Unable to load shipping profiles. Try again.',
      );
      return const None();
    }
  }

  /// Replaces the scalar assignment and publishes refreshed product detail.
  Future<bool> updateShippingProfile(
    String productId,
    AdminUpdateProductShippingProfile input,
  ) async {
    final current = state.product;
    _emitShippingProfile(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
      salesChannels: state.salesChannels,
      totalSalesChannels: state.totalSalesChannels,
    ));
    try {
      await args.shippingProfiles.updateProductShippingProfile(
        productId,
        input,
      );
      final refreshed = await args.api.product(productId);
      _emitShippingProfile(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: Some(refreshed),
        salesChannels: state.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));
      return true;
    } on DioException catch (error) {
      final message = switch (error.response?.statusCode) {
        422 => 'Choose an active shipping profile.',
        404 => 'This product no longer exists.',
        401 => 'Your admin session has expired.',
        _ => 'Unable to save the shipping profile. Try again.',
      };
      _updateFailed(current, message);
      return false;
    } on Object {
      _updateFailed(
        current,
        'Unable to save the shipping profile. Try again.',
      );
      return false;
    }
  }
}

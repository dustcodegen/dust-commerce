part of 'admin_product_detail_view_model.dart';

/// Sales-channel operations kept separate from product detail loading.
extension AdminProductDetailSalesChannelActions on AdminProductDetailViewModel {
  /// Loads one Medusa-shaped editor page using the shared authenticated Dio.
  Future<Option<AdminSalesChannelDetailList>> salesChannelChoices({
    String query = '',
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      return Some(await args.salesChannels.editorSalesChannels(
        query.trim(),
        limit.clamp(1, 1000),
        offset < 0 ? 0 : offset,
      ));
    } on DioException catch (error) {
      _updateFailed(
        state.product,
        error.response?.statusCode == 401
            ? 'Your admin session has expired.'
            : 'Unable to load sales channels. Try again.',
      );
      return const None();
    } on Object {
      _updateFailed(
        state.product,
        'Unable to load sales channels. Try again.',
      );
      return const None();
    }
  }

  /// Replaces every assignment and publishes the server-confirmed selection.
  Future<bool> updateSalesChannels(
    String productId,
    AdminUpdateProductSalesChannels input,
  ) async {
    final current = state.product;
    _emitSalesChannels(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
      salesChannels: state.salesChannels,
      totalSalesChannels: state.totalSalesChannels,
    ));
    try {
      final page = await args.salesChannels.updateProductSalesChannels(
        productId,
        input,
      );
      _emitSalesChannels(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: current,
        salesChannels: page.salesChannels,
        totalSalesChannels: state.totalSalesChannels,
      ));
      return true;
    } on DioException catch (error) {
      _updateFailed(
        current,
        switch (error.response?.statusCode) {
          422 => 'Choose unique available sales channels.',
          404 => 'This product no longer exists.',
          401 => 'Your admin session has expired.',
          _ => 'Unable to save sales channels. Try again.',
        },
      );
      return false;
    } on Object {
      _updateFailed(current, 'Unable to save sales channels. Try again.');
      return false;
    }
  }
}

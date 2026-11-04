part of 'admin_product_detail_view_model.dart';

/// Media-specific operations kept outside the product detail state machine.
extension AdminProductDetailMediaActions on AdminProductDetailViewModel {
  /// Streams image files for the media editor without exposing Dio responses.
  Future<Option<List<AdminUploadedFile>>> uploadMedia(
    List<MultipartFile> files,
  ) async {
    if (files.isEmpty) return const None();
    final current = state.product;
    _emitMedia(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
    ));
    try {
      final uploaded = await args.api.uploadMedia(files);
      _emitMedia(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: current,
      ));
      return Some(uploaded.files);
    } on DioException catch (error) {
      _updateFailed(
          current,
          switch (error.response?.statusCode) {
            413 => 'Each image must be 5 MB or smaller.',
            415 || 422 => 'Choose JPEG, PNG, GIF, or WebP image files.',
            401 => 'Your admin session has expired.',
            503 => 'Product media storage is not configured.',
            _ => 'Unable to upload these images. Try again.',
          });
      return const None();
    } on Object {
      _updateFailed(current, 'Unable to upload these images. Try again.');
      return const None();
    }
  }

  /// Persists complete gallery membership, order, and thumbnail.
  Future<bool> updateMedia(String id, AdminUpdateProductMedia input) async {
    final current = state.product;
    _emitMedia(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
    ));
    try {
      final product = await args.api.updateProductMedia(id, input);
      _emitMedia(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: Some(product),
      ));
      return true;
    } on DioException catch (error) {
      _updateFailed(
          current,
          switch (error.response?.statusCode) {
            422 => 'Check the product images and try again.',
            404 => 'This product no longer exists.',
            401 => 'Your admin session has expired.',
            _ => 'Unable to save product media. Try again.',
          });
      return false;
    } on Object {
      _updateFailed(current, 'Unable to save product media. Try again.');
      return false;
    }
  }

  /// Applies image-to-variant deltas and refreshes the product detail.
  Future<bool> batchImageVariants(
    String productId,
    String imageId,
    AdminBatchImageVariants input,
  ) async {
    final current = state.product;
    _emitMedia(AdminProductDetailState(
      status: AdminProductDetailStatus.saving,
      product: current,
    ));
    try {
      await args.api.batchImageVariants(productId, imageId, input);
      final product = await args.api.product(productId);
      _emitMedia(AdminProductDetailState(
        status: AdminProductDetailStatus.ready,
        product: Some(product),
      ));
      return true;
    } on DioException catch (error) {
      _updateFailed(
          current,
          switch (error.response?.statusCode) {
            422 => 'Choose variants owned by this product.',
            404 => 'This product image no longer exists.',
            401 => 'Your admin session has expired.',
            _ => 'Unable to save associated variants. Try again.',
          });
      return false;
    } on Object {
      _updateFailed(current, 'Unable to save associated variants. Try again.');
      return false;
    }
  }

  /// Deletes one newly uploaded file before the gallery is saved.
  Future<bool> discardUpload(String id) async {
    try {
      await args.api.deleteUpload(id);
      return true;
    } on Object {
      _updateFailed(state.product, 'Unable to remove this image. Try again.');
      return false;
    }
  }
}

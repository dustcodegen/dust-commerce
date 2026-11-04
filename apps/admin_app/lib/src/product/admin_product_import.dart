part of 'admin_product_view_model.dart';

/// Product-import preview kept separate from catalogue list state.
extension AdminProductImport on AdminProductViewModel {
  /// Applies one staged import without exposing a response object.
  Future<Result<void, String>> confirmImport(String transactionId) async {
    try {
      await args.api.confirmProductImport(transactionId);
      return const Ok(null);
    } on DioException catch (error) {
      return Err(switch (error.response?.statusCode) {
        401 => 'Your admin session has expired.',
        404 => 'This product import no longer exists.',
        409 => 'This product import is no longer available.',
        422 => 'The product CSV is no longer valid.',
        _ => 'Unable to import these products. Try again.',
      });
    } on Object {
      return const Err('Unable to import these products. Try again.');
    }
  }

  /// Uploads one CSV for validation and returns its non-mutating summary.
  Future<Result<AdminProductImportPreview, String>> previewImport(
    MultipartFile file,
  ) async {
    try {
      return Ok(await args.api.previewProductImport(file));
    } on DioException catch (error) {
      return Err(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : error.response?.statusCode == 413
              ? 'The CSV file must be 5 MB or smaller.'
              : error.response?.statusCode == 422
                  ? 'The product CSV is invalid.'
                  : 'Unable to preview this import. Try again.');
    } on Object {
      return const Err('Unable to preview this import. Try again.');
    }
  }
}

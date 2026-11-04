part of 'admin_product_view_model.dart';

/// Filtered product export kept separate from list request lifecycle.
extension AdminProductExport on AdminProductViewModel {
  /// Downloads a CSV snapshot using the exact active table query.
  Future<Result<String, String>> export() async {
    final current = state;
    try {
      final csv = await args.api.exportProducts(
        current.query,
        current.statuses.map((status) => status.name).join(','),
        current.tagIds.join(','),
        current.typeIds.join(','),
        current.createdAt.isEmpty ? '' : current.createdAt.parameter,
        current.updatedAt.isEmpty ? '' : current.updatedAt.parameter,
        current.order.parameter,
      );
      return Ok(csv);
    } on DioException catch (error) {
      return Err(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to export products. Try again.');
    } on Object {
      return const Err('Unable to export products. Try again.');
    }
  }
}

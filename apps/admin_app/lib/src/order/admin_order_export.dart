part of 'admin_order_view_model.dart';

/// Keeps CSV download failures separate from the live order-list state.
extension AdminOrderExport on AdminOrderViewModel {
  /// Downloads the complete set represented by the current table query.
  Future<Result<String, String>> export() async {
    final current = state;
    try {
      final csv = await args.exports.exportOrders(
        current.query,
        current.statuses.map((status) => status.name).join(','),
        current.regionIds.join(','),
        current.salesChannelIds.join(','),
        current.createdAt.isEmpty ? '' : current.createdAt.parameter,
        current.updatedAt.isEmpty ? '' : current.updatedAt.parameter,
        current.order.parameter,
      );
      return Ok(csv);
    } on DioException catch (error) {
      return Err(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to export orders. Try again.');
    } on Object {
      return const Err('Unable to export orders. Try again.');
    }
  }
}

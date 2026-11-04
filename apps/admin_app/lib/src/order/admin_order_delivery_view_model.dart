part of 'admin_order_detail_view_model.dart';

/// Delivery mutation kept separate from order loading and shipment creation.
extension AdminOrderDeliveryMutation on AdminOrderDetailViewModel {
  /// Marks one fulfillment delivered and publishes the refreshed typed order.
  Future<bool> markDelivered(
    String orderId,
    String fulfillmentId,
    AdminMarkFulfillmentDelivered body,
  ) async {
    final revision = _beginSave();
    try {
      final order = await args.api.markDelivered(
        orderId,
        fulfillmentId,
        body,
      );
      return _publishSaved(revision, order);
    } on DioException catch (error) {
      if (revision != _revision) return false;
      _saveFailure(switch (error.response?.statusCode) {
        401 => 'Your admin session has expired.',
        404 => 'This fulfillment no longer exists.',
        422 => 'Delivery command is invalid.',
        503 => 'Delivery notification is not configured.',
        _ => 'Unable to mark this fulfillment delivered. Try again.',
      });
      return false;
    } on Object {
      if (revision != _revision) return false;
      _saveFailure('Unable to mark this fulfillment delivered. Try again.');
      return false;
    }
  }
}

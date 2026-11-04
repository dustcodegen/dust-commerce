part of 'admin_order_detail_view_model.dart';

/// Refund reason discovery and mutation kept outside general order operations.
extension AdminPaymentRefundMutation on AdminOrderDetailViewModel {
  /// Loads active merchant reasons before the refund form is shown.
  Future<void> loadRefundReasons() async {
    final revision = ++_revision;
    _publishRefund(const AdminPaymentRefundState(
      status: AdminPaymentRefundStatus.loading,
    ));
    try {
      final page = await args.api.refundReasons('', 100, 0);
      if (revision != _revision) return;
      _publishRefund(AdminPaymentRefundState(
        status: AdminPaymentRefundStatus.ready,
        reasons: page.refundReasons,
      ));
    } on DioException catch (error) {
      if (revision != _revision) return;
      _failRefund(error.response?.statusCode == 401
          ? 'Your admin session has expired.'
          : 'Unable to load refund reasons. Try again.');
    } on Object {
      if (revision != _revision) return;
      _failRefund('Unable to load refund reasons. Try again.');
    }
  }

  /// Refunds one payment and replaces detail with the server-authoritative read.
  Future<bool> refundPayment(
    String orderId,
    String paymentId,
    AdminRefundPayment body,
  ) async {
    final revision = _beginRefundSave();
    try {
      await args.api.refundPayment(paymentId, body);
      final order = await args.api.order(orderId);
      if (revision != _revision) return false;
      return _publishSaved(revision, order);
    } on DioException catch (error) {
      if (revision != _revision) return false;
      _failRefund(switch (error.response?.statusCode) {
        401 => 'Your admin session has expired.',
        404 => 'This payment no longer exists.',
        409 => 'This payment requires reconciliation.',
        422 => 'Refund amount or reason is no longer available.',
        503 => 'Refunds are unavailable for this payment provider.',
        _ => 'Unable to refund this payment. Try again.',
      });
      return false;
    } on Object {
      if (revision != _revision) return false;
      _failRefund('Unable to refund this payment. Try again.');
      return false;
    }
  }
}

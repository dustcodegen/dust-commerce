import 'package:commerce_server/src/features/admin_refund/handler.dart';
import 'package:dust_server/server.dart';

/// Refund routes merged beneath the parent Admin authentication guard.
Router adminRefundRoutes() => Router()
  ..route('/refund-reasons', get(listAdminRefundReasonsHandler))
  ..route('/payments/{id}/refund', post(refundAdminPaymentHandler));

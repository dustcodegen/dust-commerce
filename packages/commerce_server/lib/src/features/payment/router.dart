import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/payment/handler/handler.dart';
import 'package:dust_server/server.dart';

/// The payment routes.
///
/// Handlers are named here rather than built here: their dependencies arrive
/// as state, attached where the application is composed, so this file says
/// only which path serves which function.
Router paymentRoutes() {
  return Router()
    ..routeLayer(fromExtractor(const OptionalCustomerAuth()))
    ..route('/orders/{id}/payments', post(authorizePaymentHandler, status: 201))
    ..route(
      '/orders/{id}/payments/capture',
      post(capturePaymentHandler),
    );
}

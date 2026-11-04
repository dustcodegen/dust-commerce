import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/checkout/handler/handler.dart';
import 'package:dust_server/server.dart';

/// Checkout's routes.
Router checkoutRoutes() {
  final checkout = Router()
    ..routeLayer(fromExtractor(const OptionalCustomerAuth()))
    ..route('/checkout', post(placeOrderHandler, status: 201));
  final orders = Router()
    ..routeLayer(fromExtractor(const CustomerAuth()))
    ..route('/orders', get(listOrdersHandler))
    ..route('/orders/{id}', get(readOrderHandler));

  return Router()
    ..merge(checkout)
    ..merge(orders);
}

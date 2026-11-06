import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/cart/extractor.dart';
import 'package:commerce_server/src/features/cart/handler/add_form.dart';
import 'package:commerce_server/src/features/cart/handler/handler.dart';
import 'package:dust_server/server.dart';

/// The cart's routes.
///
/// Handlers are named, not built: their dependencies arrive as state, so this
/// file says only which path serves which function.
Router cartRoutes() {
  final create = Router()
    ..routeLayer(fromExtractor(const OptionalCustomerAuth()))
    ..route('/carts/buy', post(buyCartHandler, status: 201))
    ..route('/carts', post(createCartHandler, status: 201))
    ..route('/cart/add', post(addFormLineHandler));
  final byId = Router()
    ..routeLayer(fromExtractor(const CartAccessExtractor()))
    ..route(
      '/carts/{id}',
      get(readCartHandler).patch(updateCartRegionHandler),
    )
    ..route('/carts/{id}/addresses', put(updateCartAddressesHandler))
    ..route('/carts/{id}/line-items', post(addLineHandler))
    ..route(
      '/carts/{id}/line-items/{lineId}',
      patch(updateLineHandler).delete(removeLineHandler),
    )
    ..route('/carts/{id}/shipping-options', get(listShippingOptionsHandler))
    ..route('/carts/{id}/shipping-method', post(chooseShippingHandler))
    ..route('/carts/{id}/payment-sessions', post(choosePaymentHandler))
    ..route(
      // Chained, not cascaded: MethodRouter is immutable, so `..delete(...)`
      // would build a router and throw it away, leaving DELETE a 405.
      '/carts/{id}/promotions',
      post(applyPromotionHandler).delete(removePromotionHandler),
    );
  final transfer = Router()
    ..routeLayer(fromExtractor(const CustomerAuth()))
    ..route('/carts/{id}/transfer', post(transferCartHandler));

  return Router()
    ..merge(create)
    ..merge(transfer)
    ..merge(byId);
}

import 'package:commerce_server/src/features/catalog/handler/handler.dart';
import 'package:dust_server/server.dart';

/// The catalogue's routes.
///
/// Handlers are named, not built: their dependencies arrive as state, so this
/// file says only which path serves which function.
Router catalogRoutes() {
  return Router()
    ..route('/products', get(listProductsHandler))
    ..route('/product-options', get(listProductOptionsHandler))
    ..route('/products/{handle}', get(readProductHandler));
}

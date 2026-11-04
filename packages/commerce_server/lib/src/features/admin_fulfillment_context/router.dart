import 'package:commerce_server/src/features/admin_fulfillment_context/handler.dart';
import 'package:dust_server/server.dart';

/// Fulfillment choice routes merged below the Admin authentication layer.
Router adminFulfillmentContextRoutes() => Router()
  ..route('/stock-locations', get(listAdminStockLocationsHandler))
  ..route(
    '/shipping-options',
    get(listAdminFulfillmentShippingOptionsHandler),
  );

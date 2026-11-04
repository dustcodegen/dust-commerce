import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/order_return/handler/handler.dart';
import 'package:dust_server/server.dart';

/// Public discovery and authenticated Store return routes.
Router orderReturnRoutes() {
  final authenticated = Router()
    ..routeLayer(fromExtractor(const CustomerAuth()))
    ..route('/orders/{id}/returns', get(listOrderReturnHistoryHandler))
    ..route('/returns', post(createOrderReturnHandler, status: 201));

  return Router()
    ..route('/return-reasons', get(listReturnReasonsHandler))
    ..merge(authenticated);
}

import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/order_transfer/handler/handler.dart';
import 'package:dust_server/server.dart';

/// Medusa-shaped order-transfer routes.
Router orderTransferRoutes() {
  final authenticated = Router()
    ..routeLayer(fromExtractor(const CustomerAuth()))
    ..route(
      '/orders/{id}/transfer/request',
      post(requestOrderTransferHandler, status: 202),
    );

  return Router()
    ..merge(authenticated)
    ..route(
      '/orders/{id}/transfer/accept',
      post(acceptOrderTransferHandler),
    )
    ..route(
      '/orders/{id}/transfer/decline',
      post(declineOrderTransferHandler),
    );
}

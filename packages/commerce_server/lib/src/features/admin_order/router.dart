import 'package:commerce_server/src/features/admin_order/archive_order_handler.dart';
import 'package:commerce_server/src/features/admin_order/handler.dart';
import 'package:commerce_server/src/features/admin_order/cancel_order_handler.dart';
import 'package:commerce_server/src/features/admin_order/complete_order_handler.dart';
import 'package:commerce_server/src/features/admin_order/create_fulfillment_handler.dart';
import 'package:commerce_server/src/features/admin_order/create_shipment_handler.dart';
import 'package:commerce_server/src/features/admin_order/cancel_fulfillment_handler.dart';
import 'package:commerce_server/src/features/admin_order/detail_handler.dart';
import 'package:commerce_server/src/features/admin_order/export_handler.dart';
import 'package:commerce_server/src/features/admin_order/mark_delivered_handler.dart';
import 'package:dust_server/server.dart';

/// Order routes merged beneath the parent Admin authentication layer.
Router adminOrderRoutes() => Router()
  ..route('/orders', get(listAdminOrdersHandler))
  ..route('/orders/export', get(exportAdminOrdersHandler))
  ..route('/orders/{id}', get(readAdminOrderHandler))
  ..route('/orders/{id}/archive', post(archiveAdminOrderHandler))
  ..route('/orders/{id}/cancel', post(cancelAdminOrderHandler))
  ..route('/orders/{id}/complete', post(completeAdminOrderHandler))
  ..route(
    '/orders/{id}/fulfillments',
    post(createAdminOrderFulfillmentHandler),
  )
  ..route(
    '/orders/{id}/fulfillments/{fulfillment_id}/shipments',
    post(createAdminOrderShipmentHandler),
  )
  ..route(
    '/orders/{id}/fulfillments/{fulfillment_id}/mark-as-delivered',
    post(markAdminOrderFulfillmentDeliveredHandler),
  )
  ..route(
    '/orders/{id}/fulfillments/{fulfillment_id}/cancel',
    post(cancelAdminOrderFulfillmentHandler),
  );

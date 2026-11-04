import 'package:commerce_server/src/features/admin_customer_service/handler/list.dart';
import 'package:commerce_server/src/features/admin_customer_service/handler/update.dart';
import 'package:dust_server/server.dart';

/// Support routes merged beneath the parent Admin authentication layer.
Router adminCustomerServiceRoutes() => Router()
  ..route('/customer-service', get(listAdminCustomerServiceHandler))
  ..route(
    '/customer-service/{id}',
    post(updateAdminCustomerServiceHandler),
  );

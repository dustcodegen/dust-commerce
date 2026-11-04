import 'package:commerce_server/src/features/admin_customer/create_handler.dart';
import 'package:commerce_server/src/features/admin_customer/delete_handler.dart';
import 'package:commerce_server/src/features/admin_customer/detail_handler.dart';
import 'package:commerce_server/src/features/admin_customer/handler.dart';
import 'package:commerce_server/src/features/admin_customer/update_handler.dart';
import 'package:commerce_server/src/features/admin_customer_address/create_handler.dart';
import 'package:commerce_server/src/features/admin_customer_address/delete_handler.dart';
import 'package:commerce_server/src/features/admin_customer_address/update_handler.dart';
import 'package:dust_server/server.dart';

/// Customer routes merged beneath the parent Admin authentication layer.
Router adminCustomerRoutes() => Router()
  ..route(
    '/customers',
    get(listAdminCustomersHandler).post(createAdminCustomerHandler),
  )
  ..route(
    '/customers/{id}',
    get(readAdminCustomerHandler)
        .patch(updateAdminCustomerHandler)
        .delete(deleteAdminCustomerHandler),
  )
  ..route(
    '/customers/{id}/addresses',
    post(createAdminCustomerAddressHandler),
  )
  ..route(
    '/customers/{id}/addresses/{address_id}',
    post(updateAdminCustomerAddressHandler)
        .delete(deleteAdminCustomerAddressHandler),
  );

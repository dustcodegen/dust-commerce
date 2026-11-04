import 'package:commerce_server/src/features/account/extractor.dart';
import 'package:commerce_server/src/features/customer_service/handler.dart';
import 'package:dust_server/server.dart';

/// Guest-compatible Store route with optional proven customer ownership.
Router customerServiceRoutes() => Router()
  ..routeLayer(fromExtractor(const OptionalCustomerAuth()))
  ..route(
    '/customer-service',
    post(createCustomerServiceHandler, status: 201),
  );

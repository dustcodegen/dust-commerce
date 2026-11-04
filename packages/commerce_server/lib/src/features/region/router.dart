import 'package:commerce_server/src/features/region/handler.dart';
import 'package:dust_server/server.dart';

/// Public selling-region routes matching the Medusa store surface.
Router regionRoutes() => Router()
  ..route('/regions', get(listRegionsHandler))
  ..route('/payment-providers', get(listPaymentProvidersHandler));

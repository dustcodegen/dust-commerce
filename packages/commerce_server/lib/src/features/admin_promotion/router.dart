import 'package:commerce_server/src/features/admin_promotion/handler.dart';
import 'package:dust_server/server.dart';

/// Promotion routes merged below the parent Admin authentication layer.
Router adminPromotionRoutes() => Router()
  ..route(
    '/promotions',
    get(listAdminPromotionsHandler).post(
      createAdminPromotionHandler,
      status: 201,
    ),
  )
  ..route('/promotions/{id}', get(readAdminPromotionHandler));

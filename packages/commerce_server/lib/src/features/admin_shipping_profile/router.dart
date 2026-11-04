import 'package:commerce_server/src/features/admin_shipping_profile/handler.dart';
import 'package:dust_server/server.dart';

/// Shipping-profile routes merged below the parent Admin authentication layer.
Router adminShippingProfileRoutes() => Router()
  ..route(
    '/shipping-profiles',
    get(listAdminShippingProfilesHandler)
        .post(createAdminShippingProfileHandler, status: 201),
  )
  ..route(
    '/shipping-profiles/{id}',
    get(readAdminShippingProfileHandler)
        .delete(deleteAdminShippingProfileHandler),
  )
  ..route(
    '/products/{id}/shipping-profile',
    patch(updateAdminProductShippingProfileHandler),
  );

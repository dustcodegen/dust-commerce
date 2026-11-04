import 'package:commerce_server/src/features/admin/extractor.dart';
import 'package:commerce_server/src/features/admin/handler/handler.dart';
import 'package:commerce_server/src/features/admin_fulfillment_context/router.dart';
import 'package:commerce_server/src/features/admin_customer/router.dart';
import 'package:commerce_server/src/features/admin_customer_group/router.dart';
import 'package:commerce_server/src/features/admin_customer_service/router.dart';
import 'package:commerce_server/src/features/admin_order/router.dart';
import 'package:commerce_server/src/features/admin_promotion/router.dart';
import 'package:commerce_server/src/features/admin_refund/router.dart';
import 'package:commerce_server/src/features/admin_region/router.dart';
import 'package:commerce_server/src/features/admin_return/router.dart';
import 'package:commerce_server/src/features/admin_sales_channel/router.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/router.dart';
import 'package:dust_server/server.dart';

/// Authentication routes for the distinct admin actor type.
Router adminAuthRoutes() {
  final protected = Router()
    ..routeLayer(fromExtractor(const AdminAuth()))
    ..route('/admin/session', delete(adminSignOutHandler));

  return Router()
    ..route('/admin/emailpass', post(adminSignInHandler))
    ..merge(protected);
}

/// Merchant-only routes guarded once at the route-tree boundary.
Router adminRoutes() => Router()
  ..routeLayer(fromExtractor(const AdminAuth()))
  ..merge(adminOrderRoutes())
  ..merge(adminCustomerRoutes())
  ..merge(adminCustomerGroupRoutes())
  ..merge(adminCustomerServiceRoutes())
  ..merge(adminRefundRoutes())
  ..merge(adminPromotionRoutes())
  ..merge(adminFulfillmentContextRoutes())
  ..merge(adminReturnRoutes())
  ..merge(adminRegionRoutes())
  ..merge(adminSalesChannelRoutes())
  ..merge(adminShippingProfileRoutes())
  ..route('/users/me', get(readCurrentAdminHandler))
  ..route(
    '/products',
    get(listAdminProductsHandler).post(createAdminProductHandler),
  )
  ..route(
    '/products/create-context',
    get(readAdminProductCreateContextHandler),
  )
  ..route('/products/export', get(exportAdminProductsHandler))
  ..route('/products/import', post(previewAdminProductImportHandler))
  ..route(
    '/products/import/{transaction_id}/confirm',
    post(confirmAdminProductImportHandler),
  )
  ..route(
    '/product-options',
    get(listAdminProductOptionsHandler)
        .post(createAdminProductOptionHandler, status: 201),
  )
  ..route('/product-tags', get(listAdminProductTagsHandler))
  ..route(
    '/product-types',
    get(listAdminProductTypesHandler)
        .post(createAdminProductTypeHandler, status: 201),
  )
  ..route(
    '/product-types/{id}',
    get(readAdminProductTypeHandler)
        .patch(updateAdminProductTypeHandler)
        .delete(deleteAdminProductTypeHandler),
  )
  ..route(
    '/product-options/{id}',
    get(readAdminProductOptionHandler)
        .patch(updateAdminProductOptionDetailHandler)
        .delete(deleteAdminProductOptionHandler),
  )
  ..route(
    '/products/{id}',
    get(readAdminProductHandler)
        .patch(updateAdminProductHandler)
        .delete(deleteAdminProductHandler),
  )
  ..route(
    '/products/{id}/organization',
    patch(updateAdminProductOrganizationHandler),
  )
  ..route(
    '/products/{id}/media',
    put(updateAdminProductMediaHandler),
  )
  ..route(
    '/products/{id}/stock',
    put(updateAdminProductStockHandler),
  )
  ..route(
    '/products/{id}/images/{image_id}/variants/batch',
    post(batchAdminImageVariantsHandler),
  )
  ..route(
    '/products/{id}/variants/{variant_id}',
    patch(updateAdminProductVariantHandler),
  )
  ..route(
    '/products/{id}/variants/{variant_id}/prices',
    put(updateAdminVariantPricesHandler),
  )
  ..route('/uploads', post(uploadAdminMediaHandler, status: 201))
  ..route('/uploads/{key}', delete(deleteAdminMediaHandler));

/// Public immutable media reads used by admin and storefront image elements.
Router adminMediaRoutes() =>
    Router()..route('/uploads/{key}', get(readPublicMediaHandler));

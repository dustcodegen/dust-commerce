import 'package:admin_app/src/core/admin_api.dart';
import 'package:admin_app/src/core/admin_authorization_interceptor.dart';
import 'package:admin_app/src/core/admin_session_store.dart';
import 'package:admin_app/src/bootstrap/admin_customer_dependencies.dart';
import 'package:admin_app/src/bootstrap/admin_customer_group_dependencies.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_api.dart';
import 'package:admin_app/src/customer_service/admin_customer_service_view_model.dart';
import 'package:admin_app/src/order/admin_fulfillment_context_view_model.dart';
import 'package:admin_app/src/order/admin_order_detail_api.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:admin_app/src/order/admin_order_export_api.dart';
import 'package:admin_app/src/order/admin_order_region_api.dart';
import 'package:admin_app/src/order/admin_order_sales_channel_api.dart';
import 'package:admin_app/src/order/admin_order_view_model.dart';
import 'package:admin_app/src/order/admin_return_api.dart';
import 'package:admin_app/src/order/admin_return_view_model.dart';
import 'package:admin_app/src/product/admin_product_create_view_model.dart';
import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:admin_app/src/product/admin_product_sales_channel_api.dart';
import 'package:admin_app/src/product/admin_product_shipping_profile_api.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:admin_app/src/product_option/admin_product_option_detail_view_model.dart';
import 'package:admin_app/src/product_option/admin_product_option_view_model.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_view_model.dart';
import 'package:admin_app/src/product_type/admin_product_type_view_model.dart';
import 'package:admin_app/src/promotion/admin_promotion_api.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_view_model.dart';
import 'package:admin_app/src/promotion/admin_promotion_view_model.dart';
import 'package:admin_app/src/session/admin_session_view_model.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_api.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_detail_view_model.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_view_model.dart';
import 'package:dio/dio.dart';

/// Long-lived APIs and ViewModels owned by the Admin application process.
final class AdminDependencies {
  /// Creates the isolated Admin dependency graph.
  factory AdminDependencies(String baseUrl) {
    final sessions = SecureAdminSessionStore();
    final dio = Dio()
      ..interceptors.add(AdminAuthorizationInterceptor(sessions: sessions));
    final api = AdminApi(dio, baseUrl: baseUrl);
    final orderDetailApi = AdminOrderDetailApi(dio, baseUrl: baseUrl);
    final shippingProfileApi = AdminShippingProfileApi(dio, baseUrl: baseUrl);
    final promotionApi = AdminPromotionApi(dio, baseUrl: baseUrl);
    return AdminDependencies._(
      session: AdminSessionViewModel(
        AdminSessionViewModelArgs(api: api, sessions: sessions),
      ),
      products: AdminProductViewModel(AdminProductViewModelArgs(api: api)),
      customers: AdminCustomerDependencies(dio, baseUrl),
      customerGroups: AdminCustomerGroupDependencies(dio, baseUrl),
      customerService: AdminCustomerServiceViewModel(
        AdminCustomerServiceViewModelArgs(
          api: AdminCustomerServiceApi(dio, baseUrl: baseUrl),
        ),
      ),
      orders: AdminOrderViewModel(AdminOrderViewModelArgs(
        api: api,
        exports: AdminOrderExportApi(dio, baseUrl: baseUrl),
        regions: AdminOrderRegionApi(dio, baseUrl: baseUrl),
        salesChannels: AdminOrderSalesChannelApi(dio, baseUrl: baseUrl),
      )),
      orderDetail: AdminOrderDetailViewModel(
        AdminOrderDetailViewModelArgs(api: orderDetailApi),
      ),
      fulfillmentContext: AdminFulfillmentContextViewModel(
        AdminFulfillmentContextViewModelArgs(api: orderDetailApi),
      ),
      returns: AdminReturnViewModel(
        AdminReturnViewModelArgs(
          api: AdminReturnApi(dio, baseUrl: baseUrl),
        ),
      ),
      productDetail: AdminProductDetailViewModel(
        AdminProductDetailViewModelArgs(
          api: api,
          salesChannels: AdminProductSalesChannelApi(dio, baseUrl: baseUrl),
          shippingProfiles: AdminProductShippingProfileApi(
            dio,
            baseUrl: baseUrl,
          ),
        ),
      ),
      productCreate: AdminProductCreateViewModel(
        AdminProductCreateViewModelArgs(api: api),
      ),
      productOptions: AdminProductOptionViewModel(
        AdminProductOptionViewModelArgs(api: api),
      ),
      productOptionDetail: AdminProductOptionDetailViewModel(
        AdminProductOptionDetailViewModelArgs(api: api),
      ),
      productTypes: AdminProductTypeViewModel(
        AdminProductTypeViewModelArgs(api: api),
      ),
      productTypeDetail: AdminProductTypeDetailViewModel(
        AdminProductTypeDetailViewModelArgs(api: api),
      ),
      shippingProfiles: AdminShippingProfileViewModel(
        AdminShippingProfileViewModelArgs(api: shippingProfileApi),
      ),
      shippingProfileDetail: AdminShippingProfileDetailViewModel(
        AdminShippingProfileDetailViewModelArgs(api: shippingProfileApi),
      ),
      promotions: AdminPromotionViewModel(
        AdminPromotionViewModelArgs(api: promotionApi),
      ),
      promotionDetail: AdminPromotionDetailViewModel(
        AdminPromotionDetailViewModelArgs(api: promotionApi),
      ),
    );
  }

  const AdminDependencies._({
    required this.session,
    required this.products,
    required this.customers,
    required this.customerGroups,
    required this.customerService,
    required this.orders,
    required this.orderDetail,
    required this.fulfillmentContext,
    required this.returns,
    required this.productDetail,
    required this.productCreate,
    required this.productOptions,
    required this.productOptionDetail,
    required this.productTypes,
    required this.productTypeDetail,
    required this.shippingProfiles,
    required this.shippingProfileDetail,
    required this.promotions,
    required this.promotionDetail,
  });

  /// Signed-in Admin session state.
  final AdminSessionViewModel session;

  /// Product collection state.
  final AdminProductViewModel products;

  /// Customer feature dependency group.
  final AdminCustomerDependencies customers;

  /// Customer-group feature dependency group.
  final AdminCustomerGroupDependencies customerGroups;

  /// Customer-service inbox and lifecycle state.
  final AdminCustomerServiceViewModel customerService;

  /// Order collection state.
  final AdminOrderViewModel orders;

  /// Selected order detail state.
  final AdminOrderDetailViewModel orderDetail;

  /// Fulfillment command context.
  final AdminFulfillmentContextViewModel fulfillmentContext;

  /// Return-management state.
  final AdminReturnViewModel returns;

  /// Selected product detail state.
  final AdminProductDetailViewModel productDetail;

  /// Product-creation command state.
  final AdminProductCreateViewModel productCreate;

  /// Product-option collection state.
  final AdminProductOptionViewModel productOptions;

  /// Selected product-option detail state.
  final AdminProductOptionDetailViewModel productOptionDetail;

  /// Product-type collection state.
  final AdminProductTypeViewModel productTypes;

  /// Selected product-type detail state.
  final AdminProductTypeDetailViewModel productTypeDetail;

  /// Shipping-profile collection state.
  final AdminShippingProfileViewModel shippingProfiles;

  /// Selected shipping-profile detail state.
  final AdminShippingProfileDetailViewModel shippingProfileDetail;

  /// Promotion collection state.
  final AdminPromotionViewModel promotions;

  /// Selected promotion detail state.
  final AdminPromotionDetailViewModel promotionDetail;
}

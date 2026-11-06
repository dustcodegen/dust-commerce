import 'package:commerce_server/src/features/account/account.dart';
import 'package:commerce_server/src/features/admin/admin.dart';
import 'package:commerce_server/src/features/admin_customer/admin_customer.dart';
import 'package:commerce_server/src/features/admin_customer_group/admin_customer_group.dart';
import 'package:commerce_server/src/features/admin_customer_service/admin_customer_service.dart';
import 'package:commerce_server/src/features/admin_fulfillment_context/admin_fulfillment_context.dart';
import 'package:commerce_server/src/features/admin_order/admin_order.dart';
import 'package:commerce_server/src/features/admin_promotion/admin_promotion.dart';
import 'package:commerce_server/src/features/admin_refund/admin_refund.dart';
import 'package:commerce_server/src/features/admin_region/admin_region.dart';
import 'package:commerce_server/src/features/admin_return/admin_return.dart';
import 'package:commerce_server/src/features/admin_sales_channel/admin_sales_channel.dart';
import 'package:commerce_server/src/features/admin_shipping_profile/admin_shipping_profile.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_server/server.dart';

/// Keeps Admin dependency registration separate from public route assembly.
extension AdminStateRegistration on Router {
  /// Attaches every dependency consumed beneath the authenticated Admin router.
  void attachAdminState({
    required CommerceDatabase database,
    required Executor executor,
    required Clock clock,
    required PasswordWorkLimiter passwordWork,
    required Future<String> dummyPasswordHash,
    required AdminMediaStorage mediaStorage,
  }) {
    withState(AdminDeps(
      database: database,
      reads: AdminReadRepository(executor),
      writes: AdminCreateRepository(executor),
      deletes: AdminDeleteRepository(executor),
      clock: clock,
      passwordWork: passwordWork,
      dummyPasswordHash: dummyPasswordHash,
      products: AdminProductRepository(executor),
      productExports: AdminProductExportRepository(executor),
      productImports: AdminProductImportRepository(executor),
      productTags: AdminProductTagRepository(executor),
      productTypes: AdminProductTypeRepository(executor),
      productTypeReads: AdminProductTypeReadRepository(executor),
      productOptions: AdminProductOptionRepository(executor),
      productCreates: AdminProductCreateRepository(executor),
      productReads: AdminProductReadRepository(executor),
      media: AdminMediaRepository(executor),
      mediaStorage: mediaStorage,
    ));
    withState(AdminOrderDeps(
      orders: AdminOrderRepository(executor),
      details: AdminOrderDetailRepository(executor),
      exports: AdminOrderExportRepository(executor),
      database: database,
      nextId: clock.nextId,
    ));
    withState(AdminCustomerDeps(
      customers: AdminCustomerRepository(executor),
      details: AdminCustomerDetailRepository(executor),
      creates: AdminCustomerCreateRepository(executor),
      clock: clock,
      database: database,
    ));
    withState(AdminCustomerGroupDeps(
      groups: AdminCustomerGroupListRepository(executor),
      creates: AdminCustomerGroupCreateRepository(executor),
      details: AdminCustomerGroupDetailRepository(executor),
      database: database,
      clock: clock,
    ));
    withState(AdminCustomerServiceDeps(
      database: database,
      requests: AdminCustomerServiceRepository(executor),
    ));
    withState(AdminReturnDeps(
      database: database,
      returns: AdminReturnRepository(executor),
    ));
    withState(AdminPromotionDeps(
      promotions: AdminPromotionRepository(executor),
      creates: AdminPromotionCreateRepository(executor),
      deletes: AdminPromotionDeleteRepository(executor),
      updates: AdminPromotionUpdateRepository(executor),
      clock: clock,
    ));
    withState(AdminRefundReasonDeps(
      reasons: AdminRefundReasonRepository(executor),
      clock: clock,
    ));
    withState(AdminRegionDeps(regions: AdminRegionRepository(executor)));
    withState(AdminFulfillmentContextDeps(
      choices: AdminFulfillmentContextRepository(executor),
    ));
    withState(AdminSalesChannelDeps(
      salesChannels: AdminSalesChannelRepository(executor),
      database: database,
      clock: clock,
    ));
    withState(AdminShippingProfileDeps(
      database: database,
      management: AdminShippingProfileManagementRepository(executor),
      profiles: AdminShippingProfileRepository(executor),
      clock: clock,
    ));
  }
}

import 'package:commerce_server/src/features/account/account.dart';
import 'package:commerce_server/src/features/admin/admin.dart';
import 'package:commerce_server/src/app/admin_state.dart';
import 'package:commerce_server/src/features/cart/cart.dart';
import 'package:commerce_server/src/features/category/category.dart';
import 'package:commerce_server/src/features/catalog/catalog.dart';
import 'package:commerce_server/src/features/checkout/checkout.dart';
import 'package:commerce_server/src/features/collection/collection.dart';
import 'package:commerce_server/src/features/customer_service/customer_service.dart';
import 'package:commerce_server/src/features/order_transfer/order_transfer.dart';
import 'package:commerce_server/src/features/order_return/order_return.dart';
import 'package:commerce_server/src/features/payment/payment.dart';
import 'package:commerce_server/src/features/region/region.dart';
import 'package:commerce_server/src/http/http.dart';
import 'package:commerce_server/src/infra/database.dart';
import 'package:dust_dart/db.dart';
import 'package:dust_server/server.dart';

/// Mounts feature routes and attaches their explicit state dependencies.
/// Identifiers and time remain injected so route tests control both.
Router buildApp(
  CommerceDatabase database, {
  String Function()? nextId,
  DateTime Function()? now,
  PasswordWorkLimiter? passwordWork,
  AdminMediaStorage mediaStorage = const UnavailableAdminMediaStorage(),
  EmailVerificationMailer emailVerificationMailer =
      const UnavailableEmailVerificationMailer(),
  OrderTransferMailer orderTransferMailer =
      const UnavailableOrderTransferMailer(),
  bool requireEmailVerification = false,
}) {
  final executor = database.executor;
  final clock = Clock(now: now ?? DateTime.now, nextId: nextId ?? _randomId);

  final catalogReads = CatalogReadRepository(executor);
  final orderReads = CheckoutReadRepository(executor);
  final resolvedPasswordWork = passwordWork ?? PasswordWorkLimiter();
  final accountDeps = AccountDeps(
    database: database,
    reads: AccountReadRepository(executor),
    lists: AccountListRepository(executor),
    writes: AccountCreateRepository(executor),
    updates: AccountUpdateRepository(executor),
    deletes: AccountDeleteRepository(executor),
    emailVerificationMailer: emailVerificationMailer,
    clock: clock,
    passwordWork: resolvedPasswordWork,
    requireEmailVerification: requireEmailVerification,
  );
  return Router()
    ..layer(const NoStoreByDefault())
    ..nest('/auth', accountAuthRoutes())
    ..nest('/auth', adminAuthRoutes())
    ..nest('/admin', adminRoutes())
    ..merge(adminMediaRoutes())
    ..nest('/store', accountStoreRoutes())
    ..nest('/store', categoryRoutes())
    ..nest('/store', catalogRoutes())
    ..nest('/store', collectionRoutes())
    ..nest('/store', customerServiceRoutes())
    ..nest('/store', cartRoutes())
    ..nest('/store', checkoutRoutes())
    ..nest('/store', orderTransferRoutes())
    ..nest('/store', orderReturnRoutes())
    ..nest('/store', paymentRoutes())
    ..nest('/store', regionRoutes())
    ..route('/health', get(_health))
    ..withState(accountDeps)
    ..attachAdminState(
      database: database,
      executor: executor,
      clock: clock,
      passwordWork: resolvedPasswordWork,
      dummyPasswordHash: accountDeps.dummyPasswordHash,
      mediaStorage: mediaStorage,
    )
    ..withState(
      CatalogDeps(
        reads: catalogReads,
        lists: CatalogListRepository(executor),
        counts: CatalogCountRepository(executor),
        options: CatalogOptionRepository(executor),
      ),
    )
    ..withState(CategoryDeps(categories: ProductCategoryRepository(executor)))
    ..withState(CustomerServiceDeps(
      requests: CustomerServiceRepository(executor),
      nextId: clock.nextId,
    ))
    ..withState(
      CollectionDeps(collections: ProductCollectionRepository(executor)),
    )
    ..withState(
      CartDeps(
        reads: CartReadRepository(executor),
        lists: CartListRepository(executor),
        writes: CartUpdateRepository(executor),
        catalog: catalogReads,
        clock: clock,
        database: database,
        shipping: CartShippingRepository(executor),
        payments: CartPaymentRepository(executor),
      ),
    )
    ..withState(
      CheckoutDeps(
        database: database,
        reads: orderReads,
        customerReads: CheckoutCustomerReadRepository(executor),
        lists: CheckoutListRepository(executor),
        clock: clock,
      ),
    )
    ..withState(PaymentDeps(database: database, clock: clock))
    ..withState(
      OrderTransferDeps(
        database: database,
        reads: OrderTransferReadRepository(executor),
        creates: OrderTransferCreateRepository(executor),
        updates: OrderTransferUpdateRepository(executor),
        clock: clock,
        mailer: orderTransferMailer,
      ),
    )
    ..withState(OrderReturnDeps(
      database: database,
      reads: OrderReturnReadRepository(executor),
      lists: OrderReturnListRepository(executor),
      creates: OrderReturnCreateRepository(executor),
      clock: clock,
    ))
    ..withState(RegionDeps(regions: SellingRegionRepository(executor)));
}

/// `GET /health` — the shallowest possible answer that the process is up.
Map<String, Object?> _health(Request request) => const {'status': 'ok'};

String _randomId() => 'id_${Tokens.issue()}';

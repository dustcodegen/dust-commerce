part of 'commerce_app.dart';

/// Material root composed beneath every long-lived storefront state scope.
final class _StorefrontRoot extends StatelessWidget {
  const _StorefrontRoot({
    required this.api,
    required this.account,
    required this.addresses,
    required this.orderDetail,
    required this.orders,
    required this.returnHistory,
    required this.orderReturn,
    required this.orderTransfer,
    required this.cart,
    required this.checkout,
    required this.emailVerification,
    required this.shell,
    required this.routerConfig,
  });

  final CommerceApi api;
  final AccountViewModel account;
  final AddressBookViewModel addresses;
  final AccountOrderDetailViewModel orderDetail;
  final AccountOrdersViewModel orders;
  final OrderReturnHistoryViewModel returnHistory;
  final OrderReturnViewModel orderReturn;
  final OrderTransferViewModel orderTransfer;
  final CartViewModel cart;
  final CheckoutViewModel checkout;
  final EmailVerificationViewModel emailVerification;
  final StoreShellViewModel shell;
  final RouterConfig<CommerceRoute> routerConfig;

  @override
  Widget build(BuildContext context) {
    final i18n = I18nScope.of(context);
    return _StorefrontScopes(
      api: api,
      account: account,
      addresses: addresses,
      orderDetail: orderDetail,
      orders: orders,
      returnHistory: returnHistory,
      orderReturn: orderReturn,
      orderTransfer: orderTransfer,
      cart: cart,
      checkout: checkout,
      emailVerification: emailVerification,
      shell: shell,
      child: MaterialApp.router(
        onGenerateTitle: (context) => context.tr(
          'shop_brand',
          defaultText: 'Morrow',
        ),
        debugShowCheckedModeBanner: false,
        locale: appI18nLocaleOf(i18n.locale),
        supportedLocales: appI18nSupportedLocales,
        localizationsDelegates: appI18nLocalizationsDelegates,
        theme: StoreTheme.light,
        routerConfig: routerConfig,
      ),
    );
  }
}

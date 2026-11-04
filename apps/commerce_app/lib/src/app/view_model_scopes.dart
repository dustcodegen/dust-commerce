part of 'commerce_app.dart';

final class _StorefrontScopes extends StatelessWidget {
  const _StorefrontScopes({
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
    required this.child,
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
  final Widget child;

  @override
  Widget build(BuildContext context) => EmailVerificationViewModelScope.value(
        value: emailVerification,
        child: AccountViewModelScope.value(
          value: account,
          child: AddressBookViewModelScope.value(
            value: addresses,
            child: AccountOrderDetailViewModelScope.value(
              value: orderDetail,
              child: AccountOrdersViewModelScope.value(
                value: orders,
                child: OrderReturnHistoryViewModelScope.value(
                  value: returnHistory,
                  child: OrderReturnViewModelScope.value(
                    value: orderReturn,
                    child: OrderTransferViewModelScope.value(
                      value: orderTransfer,
                      child: CartViewModelScope.value(
                        value: cart,
                        child: CheckoutViewModelScope.value(
                          value: checkout,
                          child: CustomerServiceViewModelScope(
                            args: (_) => CustomerServiceViewModelArgs(api: api),
                            create: (_, args) => CustomerServiceViewModel(args),
                            child: ProductViewModelScope(
                              args: (_) => ProductViewModelArgs(api: api),
                              create: (_, args) => ProductViewModel(args),
                              child: CatalogViewModelScope(
                                args: (_) => CatalogViewModelArgs(api: api),
                                create: (_, args) => CatalogViewModel(args),
                                child: ProductListingViewModelScope(
                                  args: (_) =>
                                      ProductListingViewModelArgs(api: api),
                                  create: (_, args) =>
                                      ProductListingViewModel(args),
                                  child: StoreShellViewModelScope.value(
                                    value: shell,
                                    child: child,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

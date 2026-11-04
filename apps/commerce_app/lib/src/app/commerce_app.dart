import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/i18n/app_i18n.g.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

part 'account_identity.dart';
part 'storefront_preparation.dart';
part 'storefront_root.dart';
part 'view_model_scopes.dart';

/// The storefront application and its long-lived state owners.
class CommerceApp extends StatefulWidget {
  /// Creates a [CommerceApp].
  const CommerceApp({
    required this.api,
    required this.returnHistoryApi,
    required this.sessions,
    required this.countries,
    required this.locales,
    required this.initialLocation,
    super.key,
  });

  /// The storefront API every view model is given.
  final CommerceApi api;

  /// Focused return-history API sharing the same Dio bearer interceptor.
  final OrderReturnHistoryApi returnHistoryApi;

  /// Secure customer-session persistence shared with Dio authorization.
  final AuthSessionStore sessions;

  /// Persisted country selection shared by storefront routes.
  final CountryPreferenceStore countries;

  /// Persisted language selection shared by the Dust i18n controller.
  final LocalePreferenceStore locales;

  /// Browser or platform location captured before the router can normalize it.
  final Uri initialLocation;

  @override
  State<CommerceApp> createState() => _CommerceAppState();
}

class _CommerceAppState extends State<CommerceApp> {
  late final AccountViewModel _account;
  late final AddressBookViewModel _addresses;
  late final AccountOrderDetailViewModel _orderDetail;
  late final AccountOrdersViewModel _orders;
  late final OrderReturnHistoryViewModel _returnHistory;
  late final OrderReturnViewModel _orderReturn;
  late final OrderTransferViewModel _orderTransfer;
  late final CartViewModel _cart;
  late final CheckoutViewModel _checkout;
  late final EmailVerificationViewModel _emailVerification;
  late final StoreShellViewModel _shell;
  late I18nController _i18n;
  late final CommerceRouter _router;
  late final RouterConfig<CommerceRoute> _routerConfig;
  bool _prepareStarted = false;
  bool _routerReady = false;
  String? _accountOwnerId;

  @override
  void initState() {
    super.initState();
    _account = AccountViewModel(
      AccountViewModelArgs(api: widget.api, sessions: widget.sessions),
    );
    _addresses = AddressBookViewModel(
      AddressBookViewModelArgs(api: widget.api),
    );
    _orders = AccountOrdersViewModel(
      AccountOrdersViewModelArgs(api: widget.api),
    );
    _orderDetail = AccountOrderDetailViewModel(
      AccountOrderDetailViewModelArgs(api: widget.api),
    );
    _returnHistory = OrderReturnHistoryViewModel(
      OrderReturnHistoryViewModelArgs(api: widget.returnHistoryApi),
    );
    _orderReturn = OrderReturnViewModel(
      OrderReturnViewModelArgs(
        api: widget.api,
        onCreated: _returnHistory.record,
      ),
    );
    _orderTransfer = OrderTransferViewModel(
      OrderTransferViewModelArgs(api: widget.api),
    );
    _emailVerification = EmailVerificationViewModel(
      EmailVerificationViewModelArgs(api: widget.api),
    );
    _shell = StoreShellViewModel(
      StoreShellViewModelArgs(
        api: widget.api,
        countries: widget.countries,
        locales: widget.locales,
        supportedLocales: appI18nLocales,
      ),
    );
    _cart = CartViewModel(
      CartViewModelArgs(
        api: widget.api,
        cartIds: SecureCartIdStore(),
        selectedRegion: () => _shell.state.selectedRegion,
      ),
    );
    _checkout = CheckoutViewModel(
      CheckoutViewModelArgs(
        api: widget.api,
        cart: _cart,
        receipts: SecureOrderReceiptStore(),
        currentCustomer: () => _account.state.customer,
      ),
    );
    _account.addListener(_onAccountIdentityChanged);
    _router = CommerceRouter(
      initialLocation: widget.initialLocation,
      account: _account,
      cart: _cart,
    );
    _routerConfig = _router.config;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _i18n = I18nScope.of(context);
    if (_prepareStarted) return;
    _prepareStarted = true;
    unawaited(_prepareStorefront());
  }

  void _showStorefront() {
    _i18n.setLocale(_shell.state.localeOr(appI18nFallbackLocale));
    setState(() => _routerReady = true);
  }

  @override
  void dispose() {
    _account.removeListener(_onAccountIdentityChanged);
    _checkout.dispose();
    _emailVerification.dispose();
    _shell.dispose();
    _cart.dispose();
    _addresses.dispose();
    _orderDetail.dispose();
    _orders.dispose();
    _returnHistory.dispose();
    _orderReturn.dispose();
    _orderTransfer.dispose();
    _account.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_routerReady) return const SizedBox.shrink();
    return _StorefrontRoot(
      api: widget.api,
      account: _account,
      addresses: _addresses,
      orderDetail: _orderDetail,
      orders: _orders,
      returnHistory: _returnHistory,
      orderReturn: _orderReturn,
      orderTransfer: _orderTransfer,
      cart: _cart,
      checkout: _checkout,
      emailVerification: _emailVerification,
      shell: _shell,
      routerConfig: _routerConfig,
    );
  }
}

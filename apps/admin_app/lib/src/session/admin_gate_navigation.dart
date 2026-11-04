part of 'admin_gate.dart';

/// Keeps route transitions out of the authenticated shell composition.
mixin _AdminHomeNavigation on State<_AdminHome>, _AdminHomeActions {
  Widget buildAdminHome(BuildContext context) {
    final optionDetail =
        context.watchAdminProductOptionDetailViewModel().value.productOption;
    final orderDetail = context.watchAdminOrderDetailViewModel().value.order;
    final customerDetail =
        context.watchAdminCustomerDetailViewModel().value.customer;
    final customerGroupDetail =
        context.watchAdminCustomerGroupDetailViewModel().value.customerGroup;
    final typeDetail =
        context.watchAdminProductTypeDetailViewModel().value.productType;
    final profileDetail = context
        .watchAdminShippingProfileDetailViewModel()
        .value
        .shippingProfile;
    final promotionDetail =
        context.watchAdminPromotionDetailViewModel().value.promotion;
    return AdminShell(
      user: widget.user,
      themes: widget.themes,
      title: _adminShellTitle(
        route: _route,
        optionDetail: optionDetail,
        orderDetail: orderDetail,
        customerDetail: customerDetail,
        customerGroupDetail: customerGroupDetail,
        typeDetail: typeDetail,
        profileDetail: profileDetail,
        promotionDetail: promotionDetail,
      ),
      onSearchRequested: _requestSearch,
      onCustomersRequested: _showCustomers,
      onCustomerGroupsRequested: _showCustomerGroups,
      onCustomerServiceRequested: _showCustomerService,
      onOrdersRequested: _showOrders,
      onProductsRequested: _showProducts,
      onProductOptionsRequested: _showProductOptions,
      onPromotionsRequested: _showPromotions,
      onProductTypesRequested: _showProductTypes,
      onShippingProfilesRequested: _showShippingProfiles,
      selectedSection: switch (_route) {
        _AdminRoute.customers ||
        _AdminRoute.customer ||
        _AdminRoute.customerOrder =>
          AdminShellSection.customers,
        _AdminRoute.customerGroups ||
        _AdminRoute.customerGroup =>
          AdminShellSection.customerGroups,
        _AdminRoute.customerService => AdminShellSection.customerService,
        _AdminRoute.orders || _AdminRoute.order => AdminShellSection.orders,
        _AdminRoute.products ||
        _AdminRoute.product =>
          AdminShellSection.products,
        _AdminRoute.productOptions ||
        _AdminRoute.productOption =>
          AdminShellSection.productOptions,
        _AdminRoute.promotions ||
        _AdminRoute.promotion =>
          AdminShellSection.promotions,
        _AdminRoute.productTypes ||
        _AdminRoute.productType =>
          AdminShellSection.productTypes,
        _AdminRoute.shippingProfiles ||
        _AdminRoute.shippingProfile =>
          AdminShellSection.shippingProfiles,
      },
      onSignOut: widget.state.isBusy
          ? null
          : context.readAdminSessionViewModel().signOut,
      child: switch (_route) {
        _AdminRoute.customers => AdminCustomerPage(
            searchFocus: _customerSearchFocus,
            onOpen: _showCustomer,
            onCreate: _createCustomer,
          ),
        _AdminRoute.customerGroups => AdminCustomerGroupPage(
            searchFocus: _customerGroupSearchFocus,
            onCreate: _createCustomerGroup,
            onOpen: _showCustomerGroup,
          ),
        _AdminRoute.customerService => AdminCustomerServicePage(
            searchFocus: _supportSearchFocus,
          ),
        _AdminRoute.customerGroup => AdminCustomerGroupDetailPage(
            customerGroupId: selectedIdForNavigation,
            onBack: _showCustomerGroups,
            onOpenCustomer: _showCustomer,
          ),
        _AdminRoute.customer => AdminCustomerDetailPage(
            customerId: selectedIdForNavigation,
            onBack: _showCustomers,
            onOpenOrder: _showCustomerOrder,
          ),
        _AdminRoute.customerOrder => AdminOrderDetailPage(
            orderId: selectedIdForNavigation,
            onBack: () => _showCustomer(selectedCustomerIdForNavigation),
          ),
        _AdminRoute.orders => AdminOrderPage(
            searchFocus: _orderSearchFocus,
            onOpen: _showOrder,
          ),
        _AdminRoute.order => AdminOrderDetailPage(
            orderId: selectedIdForNavigation,
            onBack: _showOrders,
          ),
        _AdminRoute.product => AdminProductDetailPage(
            productId: selectedIdForNavigation,
            onBack: _showProducts,
            onOpenOption: _showProductOption,
            onOpenShippingProfile: _showShippingProfile,
          ),
        _AdminRoute.products => AdminProductPage(
            searchFocus: _searchFocus,
            onCreateProduct: _createProduct,
            onOpenProduct: _showProduct,
          ),
        _AdminRoute.productOptions => AdminProductOptionPage(
            searchFocus: _optionSearchFocus,
            onOpen: _showProductOption,
            onCreate: _createProductOption,
          ),
        _AdminRoute.productOption => AdminProductOptionDetailPage(
            productOptionId: selectedIdForNavigation,
            onBack: _showProductOptions,
            onOpenProduct: _showProduct,
          ),
        _AdminRoute.productTypes => AdminProductTypePage(
            searchFocus: _typeSearchFocus,
            onOpen: _showProductType,
          ),
        _AdminRoute.promotions => AdminPromotionPage(
            searchFocus: _promotionSearchFocus,
            onOpen: _showPromotion,
          ),
        _AdminRoute.promotion => AdminPromotionDetailPage(
            promotionId: selectedIdForNavigation,
            onBack: _showPromotions,
          ),
        _AdminRoute.productType => AdminProductTypeDetailPage(
            productTypeId: selectedIdForNavigation,
            onBack: _showProductTypes,
            onOpenProduct: _showProduct,
          ),
        _AdminRoute.shippingProfiles => AdminShippingProfilePage(
            searchFocus: _profileSearchFocus,
            onOpen: _showShippingProfile,
          ),
        _AdminRoute.shippingProfile => AdminShippingProfileDetailPage(
            shippingProfileId: selectedIdForNavigation,
            onBack: _showShippingProfiles,
          ),
      },
    );
  }
}

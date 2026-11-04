part of 'admin_gate.dart';

/// Owns authenticated route transitions separately from shell composition.
mixin _AdminHomeActions
    on State<_AdminHome>, _AdminCustomerGroupActions, _AdminSupportActions {
  FocusNode get _customerSearchFocus;
  FocusNode get _orderSearchFocus;
  FocusNode get _optionSearchFocus;
  FocusNode get _searchFocus;
  FocusNode get _typeSearchFocus;
  FocusNode get _profileSearchFocus;
  FocusNode get _promotionSearchFocus;

  String get selectedIdForNavigation => _selectedId;
  String get selectedCustomerIdForNavigation => _selectedCustomerId;

  void _requestSearch() {
    if (requestSupportSearch()) return;
    if (_route == _AdminRoute.customerGroups) {
      _showCustomerGroups();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _customerGroupSearchFocus.requestFocus();
      });
      return;
    }
    if (_route == _AdminRoute.customers ||
        _route == _AdminRoute.customer ||
        _route == _AdminRoute.customerOrder) {
      _showCustomers();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _customerSearchFocus.requestFocus();
      });
      return;
    }
    if (_route == _AdminRoute.orders || _route == _AdminRoute.order) {
      _showOrders();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _orderSearchFocus.requestFocus();
      });
      return;
    }
    if (_route == _AdminRoute.productTypes ||
        _route == _AdminRoute.productType) {
      _showProductTypes();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _typeSearchFocus.requestFocus();
      });
      return;
    }
    if (_route == _AdminRoute.shippingProfiles ||
        _route == _AdminRoute.shippingProfile) {
      _showShippingProfiles();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _profileSearchFocus.requestFocus();
      });
      return;
    }
    if (_route == _AdminRoute.promotions || _route == _AdminRoute.promotion) {
      _showPromotions();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _promotionSearchFocus.requestFocus();
      });
      return;
    }
    final options = _route == _AdminRoute.productOptions ||
        _route == _AdminRoute.productOption;
    options ? _showProductOptions() : _showProducts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        (options ? _optionSearchFocus : _searchFocus).requestFocus();
      }
    });
  }

  void _showCustomers() {
    context.readAdminCustomerViewModel().load(offset: 0);
    setState(() {
      _route = _AdminRoute.customers;
      _selectedId = '';
      _selectedCustomerId = '';
    });
  }

  void _showCustomer(String id) => setState(() {
        _route = _AdminRoute.customer;
        _selectedId = id;
        _selectedCustomerId = id;
      });

  void _showCustomerOrder(String id) => setState(() {
        _route = _AdminRoute.customerOrder;
        _selectedId = id;
      });

  void _showOrder(String id) => setState(() {
        _route = _AdminRoute.order;
        _selectedId = id;
        _selectedCustomerId = '';
      });

  void _showOrders() {
    context.readAdminOrderViewModel()
      ..load(offset: 0)
      ..loadFilterOptions();
    setState(() {
      _route = _AdminRoute.orders;
      _selectedId = '';
      _selectedCustomerId = '';
    });
  }

  void _showProducts() => setState(() {
        _route = _AdminRoute.products;
        _selectedId = '';
      });

  void _showProduct(String id) => setState(() {
        _route = _AdminRoute.product;
        _selectedId = id;
      });

  void _showProductOptions() {
    context.readAdminProductOptionViewModel().load(offset: 0);
    setState(() {
      _route = _AdminRoute.productOptions;
      _selectedId = '';
    });
  }

  void _showProductOption(String id) => setState(() {
        _route = _AdminRoute.productOption;
        _selectedId = id;
      });

  void _showProductTypes() {
    context.readAdminProductTypeViewModel().load(offset: 0);
    setState(() {
      _route = _AdminRoute.productTypes;
      _selectedId = '';
    });
  }

  void _showProductType(String id) => setState(() {
        _route = _AdminRoute.productType;
        _selectedId = id;
      });

  void _showShippingProfiles() {
    context.readAdminShippingProfileViewModel().load(offset: 0);
    setState(() {
      _route = _AdminRoute.shippingProfiles;
      _selectedId = '';
    });
  }

  void _showShippingProfile(String id) => setState(() {
        _route = _AdminRoute.shippingProfile;
        _selectedId = id;
      });

  void _showPromotions() {
    context.readAdminPromotionViewModel().load(offset: 0);
    setState(() {
      _route = _AdminRoute.promotions;
      _selectedId = '';
    });
  }

  void _showPromotion(String id) => setState(() {
        _route = _AdminRoute.promotion;
        _selectedId = id;
      });

  Future<void> _createProduct() async {
    final created = await showAdminProductCreatePage(context);
    if (!mounted) return;
    if (created case Some(value: final product)) {
      await context.readAdminProductViewModel().load(offset: 0);
      if (mounted) _showProduct(product.id);
    }
  }

  Future<void> _createCustomer() async {
    final created = await showAdminCustomerCreatePage(context);
    if (!mounted || created == null) return;
    await context.readAdminCustomerViewModel().load(offset: 0);
    if (mounted) _showCustomer(created.id);
  }

  Future<void> _createProductOption() async {
    final created = await showAdminProductOptionCreatePage(context);
    if (!mounted || created == null) return;
    _showProductOption(created.id);
  }
}

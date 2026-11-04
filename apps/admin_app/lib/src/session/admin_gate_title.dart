part of 'admin_gate.dart';

String _adminShellTitle({
  required _AdminRoute route,
  required Option<AdminProductOptionDetail> optionDetail,
  required Option<AdminOrderDetail> orderDetail,
  required Option<AdminCustomerDetail> customerDetail,
  required Option<AdminCustomerGroupDetail> customerGroupDetail,
  required Option<AdminProductType> typeDetail,
  required Option<AdminShippingProfile> profileDetail,
  required Option<AdminPromotion> promotionDetail,
}) =>
    switch (route) {
      _AdminRoute.customers => 'Customers',
      _AdminRoute.customerService => 'Customer Service',
      _AdminRoute.customerGroups => 'Customer Groups',
      _AdminRoute.customerGroup => switch (customerGroupDetail) {
          Some(value: final group) => 'Customer Groups  ›  ${group.name}',
          None() => 'Customer Groups',
        },
      _AdminRoute.customer => switch (customerDetail) {
          Some(value: final customer) =>
            'Customers  ›  ${customer.email.match(some: (value) => value, none: () => customer.id)}',
          None() => 'Customers',
        },
      _AdminRoute.customerOrder => switch (orderDetail) {
          Some(value: final order) => 'Customers  ›  #${order.displayId}',
          None() => 'Customers',
        },
      _AdminRoute.orders => 'Orders',
      _AdminRoute.order => switch (orderDetail) {
          Some(value: final order) => 'Orders  ›  #${order.displayId}',
          None() => 'Orders',
        },
      _AdminRoute.products => 'Products',
      _AdminRoute.product => 'Product details',
      _AdminRoute.productOptions => 'Options',
      _AdminRoute.productOption => switch (optionDetail) {
          Some(value: final option) => 'Options  ›  ${option.title}',
          None() => 'Options',
        },
      _AdminRoute.productTypes => 'Settings  ›  Product Types',
      _AdminRoute.productType => switch (typeDetail) {
          Some(value: final type) => 'Product Types  ›  ${type.value}',
          None() => 'Product Types',
        },
      _AdminRoute.promotions => 'Promotions',
      _AdminRoute.promotion => switch (promotionDetail) {
          Some(:final value) => 'Promotions  ›  ${value.code}',
          None() => 'Promotions',
        },
      _AdminRoute.shippingProfiles => 'Settings  ›  Shipping Profiles',
      _AdminRoute.shippingProfile => switch (profileDetail) {
          Some(:final value) => 'Shipping Profiles  ›  ${value.name}',
          None() => 'Shipping Profiles',
        },
    };

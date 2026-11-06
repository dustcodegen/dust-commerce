/// Sidebar section selected by the current authenticated route.
enum AdminShellSection {
  /// Merchant customer-list routes.
  customers,

  /// Merchant customer-segmentation routes.
  customerGroups,

  /// Merchant customer-service inbox.
  customerService,

  /// Merchant order-list routes.
  orders,

  /// Inventory and stock-location routes.
  inventory,

  /// Product list and product detail routes.
  products,

  /// Product-option list and detail routes.
  productOptions,

  /// Promotion-list routes.
  promotions,

  /// Settings routes for reusable product classifications.
  productTypes,

  /// Settings routes for fulfillment requirement groups.
  shippingProfiles,

  /// Settings routes for merchant refund reasons.
  refundReasons,
}

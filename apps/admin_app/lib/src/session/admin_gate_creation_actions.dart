part of 'admin_gate.dart';

/// Keeps create-flow transitions out of the route-navigation mixin.
mixin _AdminCreationActions on State<_AdminHome>, _AdminHomeActions {
  @override
  Future<void> _createProduct() async {
    final created = await showAdminProductCreatePage(context);
    if (!mounted) return;
    if (created case Some(value: final product)) {
      await context.readAdminProductViewModel().load(offset: 0);
      if (mounted) _showProduct(product.id);
    }
  }

  @override
  Future<void> _createCustomer() async {
    final created = await showAdminCustomerCreatePage(context);
    if (!mounted || created == null) return;
    await context.readAdminCustomerViewModel().load(offset: 0);
    if (mounted) _showCustomer(created.id);
  }

  @override
  Future<void> _createProductOption() async {
    final created = await showAdminProductOptionCreatePage(context);
    if (!mounted || created == null) return;
    _showProductOption(created.id);
  }

  @override
  Future<void> _createPromotion() async {
    final created = await showAdminPromotionCreatePage(context);
    if (!mounted || created == null) return;
    await context.readAdminPromotionViewModel().load(offset: 0);
    if (mounted) _showPromotion(created.id);
  }
}

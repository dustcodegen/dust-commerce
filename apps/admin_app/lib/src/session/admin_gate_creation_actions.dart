part of 'admin_gate.dart';

/// Keeps create-flow transitions out of the route-navigation mixin.
mixin _AdminCreationActions on State<_AdminHome> {
  void _showProduct(String id);
  void _showCustomer(String id);
  void _showProductOption(String id);

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

part of 'admin_product_detail_page.dart';

/// Loaded product sections and their feature-specific actions.
final class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.product,
    required this.salesChannels,
    required this.totalSalesChannels,
    required this.onBack,
    required this.onOpenOption,
    required this.onOpenShippingProfile,
  });

  final VoidCallback onBack;
  final ValueChanged<String> onOpenOption;
  final ValueChanged<String> onOpenShippingProfile;
  final AdminProductDetail product;
  final List<AdminSalesChannel> salesChannels;
  final Option<int> totalSalesChannels;

  @override
  Widget build(BuildContext context) {
    Future<void> editGeneral() async {
      final saved = await showAdminProductEditDrawer(context, product);
      if (saved != true || !context.mounted) return;
      unawaited(context.readAdminProductViewModel().load());
      _updated(context, 'Product updated.');
    }

    Future<void> editMedia() async {
      final saved = await showAdminProductMediaEditor(context, product);
      if (saved != true || !context.mounted) return;
      unawaited(context.readAdminProductViewModel().load());
      _updated(context, 'Product media updated.');
    }

    Future<void> editOrganization() async {
      final types = context.readAdminProductTypeViewModel();
      await types.load(offset: 0);
      if (!context.mounted) return;
      if (types.state.status == AdminProductTypeStatus.failed) {
        _updated(context, 'Unable to load product types. Try again.');
        return;
      }
      final saved = await showAdminProductOrganizationDrawer(
        context,
        product,
        types.state.productTypes,
      );
      if (saved != true || !context.mounted) return;
      unawaited(context.readAdminProductViewModel().load());
      _updated(context, 'Product organization updated.');
    }

    Future<void> editVariant(AdminProductVariant variant) async {
      final saved = await showAdminProductVariantEditDrawer(
        context,
        product,
        variant,
      );
      if (saved != true || !context.mounted) return;
      unawaited(context.readAdminProductViewModel().load());
      _updated(context, 'Variant updated.');
    }

    Future<void> editVariantPrices(AdminProductVariant variant) async {
      final saved = await showAdminProductVariantPricingPage(
        context,
        product,
        variant,
      );
      if (saved != true || !context.mounted) return;
      unawaited(context.readAdminProductViewModel().load());
      _updated(context, 'Variant prices updated.');
    }

    Future<void> editStock() async {
      final saved = await showAdminProductStockPage(context, product);
      if (saved != true || !context.mounted) return;
      unawaited(context.readAdminProductViewModel().load());
      _updated(context, 'Product stock updated.');
    }

    Future<void> deleteProduct() async {
      final deleted = await deleteAdminProduct(
        context,
        id: product.id,
        title: product.title,
      );
      if (deleted && context.mounted) onBack();
    }

    final main = Column(children: [
      AdminProductGeneralSection(
        product: product,
        onEdit: editGeneral,
        onDelete: deleteProduct,
      ),
      const SizedBox(height: 12),
      AdminProductMediaSection(
        product: product,
        onEdit: editMedia,
        onDelete: (ids) => deleteAdminProductMedia(context, product, ids),
        onManageVariants: (image) =>
            manageAdminProductImageVariants(context, product, image),
      ),
      const SizedBox(height: 12),
      AdminProductOptionSection(
        options: product.options,
        onOpen: (option) => onOpenOption(option.id),
        onUnavailable: () => showAdminUnavailable(context),
      ),
      const SizedBox(height: 12),
      AdminProductVariantSection(
        variants: product.variants,
        onEdit: editVariant,
        onEditPrices: editVariantPrices,
        onEditStock: editStock,
        onUnavailable: () => showAdminUnavailable(context),
      ),
    ]);
    final side = AdminProductSidebarSections(
      product: product,
      salesChannels: salesChannels,
      totalSalesChannels: totalSalesChannels,
      onEditOrganization: editOrganization,
      onEditSalesChannels: () => editAdminProductSalesChannels(
        context,
        product,
        salesChannels,
      ),
      onEditShippingProfile: () =>
          editAdminProductShippingProfile(context, product),
      onOpenShippingProfile: onOpenShippingProfile,
      onUnavailable: () => showAdminUnavailable(context),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text('Products'),
              ),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder: (context, constraints) => constraints.maxWidth >= 900
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 7, child: main),
                          const SizedBox(width: 12),
                          Expanded(flex: 3, child: side),
                        ],
                      )
                    : Column(children: [
                        main,
                        const SizedBox(height: 12),
                        side,
                      ]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updated(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
}

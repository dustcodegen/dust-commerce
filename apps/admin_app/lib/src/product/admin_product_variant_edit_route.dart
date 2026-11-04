part of 'admin_product_variant_edit_drawer.dart';

/// Opens the Medusa-shaped right-side variant editor.
Future<bool?> showAdminProductVariantEditDrawer(
  BuildContext context,
  AdminProductDetail product,
  AdminProductVariant variant,
) =>
    showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close variant editor',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: _VariantEditDrawer(product: product, variant: variant),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );

final class _VariantEditDrawer extends StatefulWidget {
  const _VariantEditDrawer({required this.product, required this.variant});

  final AdminProductDetail product;
  final AdminProductVariant variant;

  @override
  State<_VariantEditDrawer> createState() => _VariantEditDrawerState();
}

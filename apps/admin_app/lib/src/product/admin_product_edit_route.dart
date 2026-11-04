part of 'admin_product_edit_drawer.dart';

/// Opens the Medusa-shaped right-side general product editor.
Future<bool?> showAdminProductEditDrawer(
  BuildContext context,
  AdminProductDetail product,
) =>
    showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close product editor',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => Align(
        alignment: Alignment.centerRight,
        child: _AdminProductEditDrawer(product: product),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );

final class _AdminProductEditDrawer extends StatefulWidget {
  const _AdminProductEditDrawer({required this.product});

  final AdminProductDetail product;

  @override
  State<_AdminProductEditDrawer> createState() =>
      _AdminProductEditDrawerState();
}

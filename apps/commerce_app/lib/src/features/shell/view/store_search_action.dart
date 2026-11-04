import 'package:commerce_app/route.dart';
import 'package:commerce_app/src/features/shell/view/store_search_drawer.dart';
import 'package:commerce_app/src/features/shell/view_model/store_shell_view_model.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa header search trigger.
final class StoreSearchAction extends StatelessWidget {
  /// Creates the header search trigger.
  const StoreSearchAction({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: context.tr(
          'shop_search_products',
          defaultText: 'Search products',
        ),
        icon: const Icon(Icons.search, size: 20),
        onPressed: () => _open(context),
      );

  void _open(BuildContext context) {
    final shell = context.readStoreShellViewModel();
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.tr(
        'shop_search_close',
        defaultText: 'Close search',
      ),
      barrierColor: Colors.black.withValues(alpha: 0.20),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (dialogContext, _, __) => StoreSearchDrawer(
        shell: shell,
        currencyCode: shell.state.currencyCode,
        onProductSelected: (handle) {
          Navigator.of(dialogContext).pop();
          context.navigator.product(handle: handle).push();
        },
      ),
      transitionBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: child,
      ),
    );
  }
}

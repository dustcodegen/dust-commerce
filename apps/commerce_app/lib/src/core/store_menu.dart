import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import '../features/shell/view/country_select.dart';

/// Source-shaped inset storefront navigation panel.
class StoreMenu extends StatelessWidget {
  /// Creates the responsive menu.
  const StoreMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final viewportWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = viewportWidth < 640
        ? viewportWidth - 16
        : (viewportWidth / 3).clamp(392.0, viewportWidth);
    return Drawer(
      width: drawerWidth,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      backgroundColor: Colors.transparent,
      child: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          // shortcut: keep the generator Dart-only; restore the native blur
          // when Dust can resolve dart:ui from Flutter's SDK source map.
          child: ColoredBox(
            color: StoreColors.inverted.withValues(alpha: 0.5),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: Navigator.of(context).pop,
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      alignment: Alignment.topRight,
                      constraints: const BoxConstraints.tightFor(
                        width: 44,
                        height: 44,
                      ),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ),
                  const Spacer(),
                  _MenuLink(
                    label: context.tr('shop_home', defaultText: 'Home'),
                    onPressed: () => _go(
                      context,
                      () => context.navigator.catalog().go(),
                    ),
                  ),
                  _MenuLink(
                    label: context.tr('shop_title', defaultText: 'Store'),
                    onPressed: () => _go(
                      context,
                      () => context.navigator.store().go(),
                    ),
                  ),
                  _MenuLink(
                    label: context.tr(
                      'shop_account_title',
                      defaultText: 'Account',
                    ),
                    onPressed: () => _go(
                      context,
                      () => context.navigator.account().go(),
                    ),
                  ),
                  _MenuLink(
                    label: context.tr(
                      'shop_cart_title',
                      defaultText: 'Cart',
                    ),
                    onPressed: () => _go(
                      context,
                      () => context.navigator.cart().go(),
                    ),
                  ),
                  const Spacer(),
                  const StoreLanguageSelect(),
                  const SizedBox(height: 24),
                  const StoreCountrySelect(),
                  const SizedBox(height: 24),
                  Text(
                    context.tr(
                      'shop_footer_rights',
                      defaultText: '© {year} Morrow. All rights reserved.',
                      args: {'year': DateTime.now().year.toString()},
                    ),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, VoidCallback navigate) {
    Navigator.of(context).pop();
    navigate();
  }
}

class _MenuLink extends StatelessWidget {
  const _MenuLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w400,
          ),
        ),
        child: Text(label),
      );
}

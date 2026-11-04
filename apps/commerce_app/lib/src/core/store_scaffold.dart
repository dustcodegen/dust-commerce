import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import '../features/shell/view/store_search_action.dart';
import 'store_menu.dart';

/// The navigation shell translated from Medusa DTC Nav and SideMenu.
class StoreScaffold extends StatelessWidget {
  /// Creates the shared storefront shell.
  const StoreScaffold({required this.body, super.key});

  /// Route content below the fixed-height storefront header.
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final brand = context.tr('shop_brand', defaultText: 'MORROW');
    const actionStyle = TextStyle(
      fontSize: 12,
      height: 20 / 12,
      fontWeight: FontWeight.w400,
    );
    const brandStyle = TextStyle(
      fontSize: 18,
      height: 20 / 18,
      fontWeight: FontWeight.w500,
    );
    void openStore() => context.navigator.catalog().go();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 240) {
              return const SizedBox.shrink();
            }
            final desktop = MediaQuery.sizeOf(context).width >= 1024;
            return AppBar(
              excludeHeaderSemantics: true,
              toolbarHeight: 64,
              leadingWidth: 88,
              leading: Builder(
                builder: (context) => TextButton(
                  onPressed: Scaffold.of(context).openDrawer,
                  child: const TranslatedText(
                    'shop_menu',
                    defaultText: 'Menu',
                    style: actionStyle,
                  ),
                ),
              ),
              title: Semantics(
                button: true,
                container: true,
                label: brand,
                namesRoute: true,
                onTap: openStore,
                child: ExcludeSemantics(
                  child: TextButton(
                    onPressed: openStore,
                    child: Text(brand, style: brandStyle),
                  ),
                ),
              ),
              actions: [
                const StoreSearchAction(),
                const SizedBox(width: 4),
                if (desktop)
                  TextButton(
                    onPressed: () => context.navigator.account().go(),
                    child: const TranslatedText(
                      'shop_account_title',
                      defaultText: 'Account',
                      style: actionStyle,
                    ),
                  ),
                if (desktop) const SizedBox(width: 12),
                const CartPreview(),
                const SizedBox(width: 12),
              ],
            );
          },
        ),
      ),
      drawerScrimColor: Colors.transparent,
      drawer: const StoreMenu(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                const CartMismatchBanner(),
                Expanded(child: body),
              ],
            ),
          ),
          const Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: FreeShippingPriceNudge(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

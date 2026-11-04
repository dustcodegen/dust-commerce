import 'package:admin_app/src/shell/admin_sidebar.dart';
import 'package:admin_app/src/shell/admin_shell_section.dart';
import 'package:admin_app/src/theme/admin_theme.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Responsive Medusa-shaped frame shared by authenticated admin routes.
final class AdminShell extends StatelessWidget {
  /// Creates the merchant shell.
  const AdminShell({
    required this.user,
    required this.themes,
    required this.onSearchRequested,
    required this.onCustomersRequested,
    required this.onCustomerGroupsRequested,
    required this.onCustomerServiceRequested,
    required this.onOrdersRequested,
    required this.onProductsRequested,
    required this.onProductOptionsRequested,
    required this.onPromotionsRequested,
    required this.onProductTypesRequested,
    required this.onShippingProfilesRequested,
    required this.selectedSection,
    required this.onSignOut,
    required this.title,
    required this.child,
    super.key,
  });

  /// Current route body.
  final Widget child;

  /// Focuses the active route search field.
  final VoidCallback onSearchRequested;

  /// Opens the merchant customer table.
  final VoidCallback onCustomersRequested;

  /// Opens the merchant customer-group table.
  final VoidCallback onCustomerGroupsRequested;

  /// Opens the merchant customer-service inbox.
  final VoidCallback onCustomerServiceRequested;

  /// Opens the merchant order table.
  final VoidCallback onOrdersRequested;

  /// Returns to the product catalogue route.
  final VoidCallback onProductsRequested;

  /// Opens the global product-options table.
  final VoidCallback onProductOptionsRequested;

  /// Opens the merchant promotions table.
  final VoidCallback onPromotionsRequested;

  /// Opens product classifications in Settings.
  final VoidCallback onProductTypesRequested;

  /// Opens fulfillment profiles in Settings.
  final VoidCallback onShippingProfilesRequested;

  /// Revokes the merchant session.
  final VoidCallback? onSignOut;

  /// Sidebar group highlighted for the current route.
  final AdminShellSection selectedSection;

  /// Local appearance preference.
  final AdminThemeController themes;

  /// Active route title.
  final String title;

  /// Proven merchant identity.
  final AdminUser user;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;
          final sidebar = AdminSidebar(
            user: user,
            themes: themes,
            onSearchRequested: onSearchRequested,
            onCustomersRequested: onCustomersRequested,
            onCustomerGroupsRequested: onCustomerGroupsRequested,
            onCustomerServiceRequested: onCustomerServiceRequested,
            onOrdersRequested: onOrdersRequested,
            onProductsRequested: onProductsRequested,
            onProductOptionsRequested: onProductOptionsRequested,
            onPromotionsRequested: onPromotionsRequested,
            onProductTypesRequested: onProductTypesRequested,
            onShippingProfilesRequested: onShippingProfilesRequested,
            selectedSection: selectedSection,
            onSignOut: onSignOut,
          );
          return Scaffold(
            drawer: desktop ? null : Drawer(width: 220, child: sidebar),
            body: Row(
              children: [
                if (desktop) SizedBox(width: 220, child: sidebar),
                Expanded(
                  child: Column(
                    children: [
                      _Topbar(desktop: desktop, title: title),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
}

final class _Topbar extends StatelessWidget {
  const _Topbar({required this.desktop, required this.title});

  final bool desktop;
  final String title;

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          children: [
            if (!desktop)
              Builder(
                builder: (context) => IconButton(
                  tooltip: 'Open navigation',
                  onPressed: Scaffold.of(context).openDrawer,
                  icon: const Icon(Icons.menu_rounded, size: 18),
                ),
              ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const Spacer(),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => showDialog<void>(
                context: context,
                builder: (context) => const AlertDialog(
                  title: Text('Notifications'),
                  content: Text("You're all caught up."),
                ),
              ),
              icon: const Icon(Icons.notifications_none_rounded, size: 18),
            ),
          ],
        ),
      );
}

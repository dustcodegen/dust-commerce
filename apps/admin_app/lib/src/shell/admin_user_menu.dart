import 'package:admin_app/src/theme/admin_theme.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Compact store or merchant initial shown in the shell.
final class AdminAvatar extends StatelessWidget {
  /// Creates the bordered avatar.
  const AdminAvatar({required this.label, super.key});

  /// Single-character merchant or store label.
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      );
}

/// Merchant menu with working appearance selection and sign-out.
final class AdminUserMenu extends StatelessWidget {
  /// Creates the merchant utility menu.
  const AdminUserMenu({
    required this.user,
    required this.themes,
    required this.onSignOut,
    super.key,
  });

  /// Revokes the current admin session.
  final VoidCallback? onSignOut;

  /// Local appearance preference.
  final AdminThemeController themes;

  /// Proven merchant rendered in the menu.
  final AdminUser user;

  @override
  Widget build(BuildContext context) {
    final name = [user.firstName, user.lastName]
        .whereType<String>()
        .where((value) => value.isNotEmpty)
        .join(' ');
    final label = name.isEmpty ? user.email : name;
    return PopupMenuButton<_UserAction>(
      tooltip: 'User menu',
      position: PopupMenuPosition.over,
      onSelected: (action) {
        switch (action) {
          case _UserAction.system:
            themes.value = ThemeMode.system;
          case _UserAction.light:
            themes.value = ThemeMode.light;
          case _UserAction.dark:
            themes.value = ThemeMode.dark;
          case _UserAction.signOut:
            onSignOut?.call();
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: _UserAction.system, child: Text('System theme')),
        PopupMenuItem(value: _UserAction.light, child: Text('Light theme')),
        PopupMenuItem(value: _UserAction.dark, child: Text('Dark theme')),
        PopupMenuDivider(),
        PopupMenuItem(value: _UserAction.signOut, child: Text('Sign out')),
      ],
      child: SizedBox(
        height: 38,
        child: Row(
          children: [
            AdminAvatar(label: label.characters.first.toUpperCase()),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, overflow: TextOverflow.ellipsis),
                  Text(
                    'Powered by dust',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.unfold_more_rounded, size: 15),
          ],
        ),
      ),
    );
  }
}

enum _UserAction { system, light, dark, signOut }

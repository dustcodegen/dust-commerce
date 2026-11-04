import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

import 'account_section.dart';

const _accountNavLinkHeight = TextStyle(fontSize: 16, height: 1.5);

/// One destination in the desktop account navigation.
final class AccountNavigationLink extends StatelessWidget {
  /// Creates a source-shaped account destination.
  const AccountNavigationLink({
    required this.active,
    required this.section,
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Currently selected account section.
  final AccountSection active;

  /// Human-readable destination label.
  final String label;

  /// Route transition owned by the account shell.
  final VoidCallback onPressed;

  /// Destination represented by this link.
  final AccountSection section;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: section == active
                ? StoreColors.foreground
                : StoreColors.foregroundSubtle,
            textStyle: _accountNavLinkHeight.copyWith(
              fontWeight: section == active ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          child: Text(label),
        ),
      );
}

/// One full-width destination in Medusa's compact account menu.
final class MobileAccountNavigationItem extends StatelessWidget {
  /// Creates a compact account destination.
  const MobileAccountNavigationItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    super.key,
  });

  /// Whether the destination accepts interaction.
  final bool enabled;

  /// Leading source-equivalent destination icon.
  final IconData icon;

  /// Human-readable destination label.
  final String label;

  /// Route or sign-out action owned by the account shell.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 32),
            horizontalTitleGap: 8,
            leading: Icon(icon, size: 20),
            minLeadingWidth: 20,
            title: Text(label),
            titleTextStyle: Theme.of(context).textTheme.bodyLarge,
            trailing: const Icon(Icons.chevron_right, size: 16),
            enabled: enabled,
            onTap: onTap,
          ),
          const Divider(height: 1),
        ],
      );
}

import 'package:admin_app/src/customer_group/admin_customer_group_actions_menu.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa-compatible group identity and active customer count.
final class AdminCustomerGroupGeneralSection extends StatelessWidget {
  /// Creates the read-only general section.
  const AdminCustomerGroupGeneralSection({
    required this.customerGroup,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Complete merchant customer-group allowlist.
  final AdminCustomerGroupDetail customerGroup;

  /// Opens the destructive group confirmation when available.
  final VoidCallback? onDelete;

  /// Opens the existing customer-group edit drawer.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x12000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Row(children: [
              Expanded(
                child: Text(
                  customerGroup.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              AdminCustomerGroupActionsMenu(
                onDelete: onDelete,
                onEdit: onEdit,
              ),
            ]),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            child: Row(children: [
              const Expanded(
                child: Text(
                  'Customers',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  customerGroup.customers.isEmpty
                      ? '—'
                      : '${customerGroup.customers.length}',
                ),
              ),
            ]),
          ),
        ]),
      );
}

import 'package:admin_app/src/customer_group/admin_customer_group_customer_section.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_data_sections.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_general_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Responsive single-column composition matching Medusa's group detail.
final class AdminCustomerGroupDetailLayout extends StatelessWidget {
  /// Creates the complete read-only detail composition.
  const AdminCustomerGroupDetailLayout({
    required this.customerGroup,
    required this.state,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenCustomer,
    required this.onAddCustomer,
    required this.onRemoveCustomers,
    required this.membershipBusy,
    super.key,
  });

  /// Opens the customer candidate focus route.
  final VoidCallback onAddCustomer;

  /// Complete customer-group allowlist.
  final AdminCustomerGroupDetail customerGroup;

  /// Opens the destructive confirmation when deletion is available.
  final VoidCallback? onDelete;

  /// Opens the Medusa-shaped customer-group editor.
  final VoidCallback onEdit;

  /// Opens one customer profile from the group table.
  final ValueChanged<String> onOpenCustomer;

  /// Confirms and removes selected memberships.
  final Future<bool> Function(List<String>) onRemoveCustomers;

  /// Whether an add/remove command is in flight.
  final bool membershipBusy;

  /// Current detail and customer-section state.
  final AdminCustomerGroupDetailState state;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(children: [
              AdminCustomerGroupGeneralSection(
                customerGroup: customerGroup,
                onDelete: onDelete,
                onEdit: onEdit,
              ),
              const SizedBox(height: 12),
              AdminCustomerGroupCustomerSection(
                state: state,
                onOpenCustomer: onOpenCustomer,
                onAdd: onAddCustomer,
                onRemove: onRemoveCustomers,
                busy: membershipBusy,
              ),
              const SizedBox(height: 12),
              AdminCustomerGroupDataSections(customerGroup: customerGroup),
            ]),
          ),
        ),
      );
}

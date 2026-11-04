import 'package:admin_app/src/customer/admin_customer_address_section.dart';
import 'package:admin_app/src/customer/admin_customer_detail_state.dart';
import 'package:admin_app/src/customer/admin_customer_general_section.dart';
import 'package:admin_app/src/customer/admin_customer_order_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Responsive two-column composition matching Medusa's customer detail.
final class AdminCustomerDetailLayout extends StatelessWidget {
  /// Creates the profile layout and functional order navigation.
  const AdminCustomerDetailLayout({
    required this.customer,
    required this.state,
    required this.onEditCustomer,
    required this.onDeleteCustomer,
    required this.onAddAddress,
    required this.onDeleteAddress,
    required this.onOpenOrder,
    super.key,
  });

  /// Complete customer profile.
  final AdminCustomerDetail customer;

  /// Opens the focused customer-address form.
  final VoidCallback onAddAddress;

  /// Opens typed confirmation for one address when no deletion is active.
  final ValueChanged<AdminCustomerAddress>? onDeleteAddress;

  /// Opens the customer contact editor.
  final VoidCallback onEditCustomer;

  /// Opens typed confirmation for customer deletion when no request is active.
  final VoidCallback? onDeleteCustomer;

  /// Opens one customer-owned order.
  final ValueChanged<String> onOpenOrder;

  /// Current profile and order-section state.
  final AdminCustomerDetailState state;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: LayoutBuilder(builder: (context, constraints) {
              if (constraints.maxWidth < 1000) {
                return Column(children: [
                  AdminCustomerGeneralSection(
                    customer: customer,
                    onEdit: onEditCustomer,
                    onDelete: onDeleteCustomer,
                  ),
                  const SizedBox(height: 12),
                  AdminCustomerAddressSection(
                    customer: customer,
                    onAdd: onAddAddress,
                    onDelete: onDeleteAddress,
                  ),
                  const SizedBox(height: 12),
                  AdminCustomerOrderSection(
                    state: state,
                    onOpenOrder: onOpenOrder,
                  ),
                ]);
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(children: [
                      AdminCustomerGeneralSection(
                        customer: customer,
                        onEdit: onEditCustomer,
                        onDelete: onDeleteCustomer,
                      ),
                      const SizedBox(height: 12),
                      AdminCustomerOrderSection(
                        state: state,
                        onOpenOrder: onOpenOrder,
                      ),
                    ]),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 440,
                    child: AdminCustomerAddressSection(
                      customer: customer,
                      onAdd: onAddAddress,
                      onDelete: onDeleteAddress,
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      );
}

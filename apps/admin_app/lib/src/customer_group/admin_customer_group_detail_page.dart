import 'package:admin_app/src/customer_group/admin_customer_group_add_page.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_failure.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_layout.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_state.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_delete_dialog.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_delete_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_edit_drawer.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_membership_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_remove_dialog.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Protected Medusa-shaped route for one merchant customer group.
final class AdminCustomerGroupDetailPage extends StatefulWidget {
  /// Creates the detail route for [customerGroupId].
  const AdminCustomerGroupDetailPage({
    required this.customerGroupId,
    required this.onBack,
    required this.onOpenCustomer,
    super.key,
  });

  /// Stable customer-group identifier loaded from the Admin API.
  final String customerGroupId;

  /// Returns to the customer-group table.
  final VoidCallback onBack;

  /// Opens one group customer in the existing customer detail route.
  final ValueChanged<String> onOpenCustomer;

  @override
  State<AdminCustomerGroupDetailPage> createState() =>
      _AdminCustomerGroupDetailPageState();
}

final class _AdminCustomerGroupDetailPageState
    extends State<AdminCustomerGroupDetailPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AdminCustomerGroupDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerGroupId != widget.customerGroupId) _load();
  }

  void _load() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .readAdminCustomerGroupDetailViewModel()
              .load(widget.customerGroupId);
        }
      });

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerGroupDetailViewModel().value;
    final deletion = context.watchAdminCustomerGroupDeleteViewModel().value;
    final membership =
        context.watchAdminCustomerGroupMembershipViewModel().value;
    return switch (state.customerGroup) {
      Some(value: final group) => AdminCustomerGroupDetailLayout(
          customerGroup: group,
          state: state,
          onDelete: deletion.isBusy ? null : () => _delete(group),
          onEdit: () => _edit(group),
          onOpenCustomer: widget.onOpenCustomer,
          onAddCustomer: () => _addCustomers(group),
          onRemoveCustomers: _removeCustomers,
          membershipBusy: membership.isBusy,
        ),
      None() when state.status == AdminCustomerGroupDetailStatus.loading =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      None() => AdminCustomerGroupDetailFailure(
          message: state.failure.match(
            some: (value) => value,
            none: () => 'Unable to load this customer group.',
          ),
          onBack: widget.onBack,
          onRetry: _load,
        ),
    };
  }

  Future<void> _delete(AdminCustomerGroupDetail group) async {
    final confirmed = await confirmAdminCustomerGroupDelete(context, group);
    if (!confirmed || !mounted) return;
    final viewModel = context.readAdminCustomerGroupDeleteViewModel();
    final result = await viewModel.delete(group.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case Some():
        messenger.showSnackBar(SnackBar(
          content: Text(
            'Customer group ${group.name} was successfully deleted.',
          ),
        ));
        widget.onBack();
      case None():
        messenger.showSnackBar(SnackBar(
          content: Text(viewModel.state.failure.match(
            some: (message) => message,
            none: () => 'Unable to delete this customer group. Try again.',
          )),
        ));
    }
  }

  Future<void> _edit(AdminCustomerGroupDetail group) async {
    final updated = await showAdminCustomerGroupEditDrawer(context, group);
    if (updated == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        'Customer group ${updated.name} was successfully updated.',
      ),
    ));
    await context.readAdminCustomerGroupDetailViewModel().load(updated.id);
  }

  Future<void> _addCustomers(AdminCustomerGroupDetail group) async {
    final count = await showAdminCustomerGroupAddPage(
      context,
      customerGroupId: group.id,
      existingCustomerIds:
          group.customers.map((customer) => customer.id).toSet(),
    );
    if (count == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(count == 1
          ? 'Customer was successfully added to the group.'
          : 'Customers were successfully added to the group.'),
    ));
    await context.readAdminCustomerGroupDetailViewModel().load(group.id);
  }

  Future<bool> _removeCustomers(List<String> customerIds) async {
    if (customerIds.isEmpty) return false;
    final confirmed = await confirmAdminCustomerGroupMemberRemoval(
      context,
      customerIds.length,
    );
    if (!confirmed || !mounted) return false;
    final viewModel = context.readAdminCustomerGroupMembershipViewModel();
    final result = await viewModel.update(
      widget.customerGroupId,
      remove: customerIds,
    );
    if (!mounted) return false;
    return switch (result) {
      Some() => await _refreshAfterRemoval(),
      None() => _showMembershipFailure(viewModel),
    };
  }

  Future<bool> _refreshAfterRemoval() async {
    await context
        .readAdminCustomerGroupDetailViewModel()
        .load(widget.customerGroupId);
    return mounted;
  }

  bool _showMembershipFailure(AdminCustomerGroupMembershipViewModel viewModel) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(viewModel.state.failure.match(
        some: (message) => message,
        none: () => 'Unable to update group customers. Try again.',
      )),
    ));
    return false;
  }
}

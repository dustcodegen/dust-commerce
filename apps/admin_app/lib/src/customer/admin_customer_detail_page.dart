import 'package:admin_app/src/customer/admin_customer_address_create_page.dart';
import 'package:admin_app/src/customer/admin_customer_address_delete_dialog.dart';
import 'package:admin_app/src/customer/admin_customer_address_delete_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_detail_layout.dart';
import 'package:admin_app/src/customer/admin_customer_detail_state.dart';
import 'package:admin_app/src/customer/admin_customer_detail_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_delete_dialog.dart';
import 'package:admin_app/src/customer/admin_customer_delete_view_model.dart';
import 'package:admin_app/src/customer/admin_customer_edit_drawer.dart';
import 'package:admin_app/src/customer/admin_customer_presenter.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Protected Medusa-shaped route for one merchant customer profile.
final class AdminCustomerDetailPage extends StatefulWidget {
  /// Creates the detail route for [customerId].
  const AdminCustomerDetailPage({
    required this.customerId,
    required this.onBack,
    required this.onOpenOrder,
    super.key,
  });

  /// Stable customer identifier loaded from the Admin API.
  final String customerId;

  /// Returns to the customer table.
  final VoidCallback onBack;

  /// Opens one order from this customer's history.
  final ValueChanged<String> onOpenOrder;

  @override
  State<AdminCustomerDetailPage> createState() =>
      _AdminCustomerDetailPageState();
}

final class _AdminCustomerDetailPageState
    extends State<AdminCustomerDetailPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AdminCustomerDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customerId != widget.customerId) _load();
  }

  void _load() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.readAdminCustomerDetailViewModel().load(widget.customerId);
        }
      });

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerDetailViewModel().value;
    final deletion = context.watchAdminCustomerDeleteViewModel().value;
    final addressDeletion =
        context.watchAdminCustomerAddressDeleteViewModel().value;
    return switch (state.customer) {
      Some(value: final customer) => AdminCustomerDetailLayout(
          customer: customer,
          state: state,
          onAddAddress: () => _addAddress(customer),
          onDeleteAddress: addressDeletion.isBusy
              ? null
              : (address) => _deleteAddress(customer.id, address),
          onEditCustomer: () => _edit(customer),
          onDeleteCustomer: deletion.isBusy ? null : () => _delete(customer),
          onOpenOrder: widget.onOpenOrder,
        ),
      None() when state.status == AdminCustomerDetailStatus.loading =>
        const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      None() => _AdminCustomerDetailFailure(
          message: switch (state.failure) {
            Some(:final value) => value,
            None() => 'Unable to load this customer.',
          },
          onBack: widget.onBack,
          onRetry: _load,
        ),
    };
  }

  Future<void> _addAddress(AdminCustomerDetail customer) async {
    final updated = await showAdminCustomerAddressCreatePage(
      context,
      customer.id,
    );
    if (updated != null && mounted) {
      await context.readAdminCustomerDetailViewModel().load(updated.id);
    }
  }

  Future<void> _delete(AdminCustomerDetail customer) async {
    final confirmed = await confirmAdminCustomerDelete(context, customer);
    if (!confirmed || !mounted) return;
    final result =
        await context.readAdminCustomerDeleteViewModel().delete(customer.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case Some():
        messenger.showSnackBar(SnackBar(
          content: Text(
            'Customer ${adminCustomerDetailText(customer.email)} '
            'was successfully deleted.',
          ),
        ));
        widget.onBack();
      case None():
        final failure =
            context.readAdminCustomerDeleteViewModel().state.failure;
        messenger.showSnackBar(SnackBar(
          content: Text(failure.match(
            some: (message) => message,
            none: () => 'Unable to delete this customer. Try again.',
          )),
        ));
    }
  }

  Future<void> _deleteAddress(
      String customerId, AdminCustomerAddress address) async {
    final confirmed = await confirmAdminCustomerAddressDelete(context, address);
    if (!confirmed || !mounted) return;
    final viewModel = context.readAdminCustomerAddressDeleteViewModel();
    final result = await viewModel.delete(customerId, address.id);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case Some():
        messenger.showSnackBar(const SnackBar(content: Text('Success')));
        await context.readAdminCustomerDetailViewModel().load(customerId);
      case None():
        messenger.showSnackBar(SnackBar(
          content: Text(viewModel.state.failure.match(
            some: (message) => message,
            none: () => 'Unable to delete this address. Try again.',
          )),
        ));
    }
  }

  Future<void> _edit(AdminCustomerDetail customer) async {
    final updated = await showAdminCustomerEditDrawer(context, customer);
    if (updated != null && mounted) {
      await context.readAdminCustomerDetailViewModel().load(updated.id);
    }
  }
}

final class _AdminCustomerDetailFailure extends StatelessWidget {
  const _AdminCustomerDetailFailure({
    required this.message,
    required this.onBack,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onBack;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(message),
          const SizedBox(height: 12),
          Wrap(spacing: 8, children: [
            OutlinedButton(onPressed: onBack, child: const Text('Customers')),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ]),
        ]),
      );
}

import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:admin_app/src/order/admin_shipment_draft.dart';
import 'package:admin_app/src/order/admin_shipment_label_controllers.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_create_shipment_dialog_sections.dart';
part 'admin_create_shipment_dialog_chrome.dart';

/// Full-screen shipment form copied from Medusa's current Admin source.
final class AdminCreateShipmentDialog extends StatefulWidget {
  /// Creates a shipment form for one pending fulfillment.
  const AdminCreateShipmentDialog({
    required this.order,
    required this.fulfillment,
    super.key,
  });

  /// Pending fulfillment whose exact items will be marked shipped.
  final AdminOrderFulfillment fulfillment;

  /// Complete order used for route identity and display context.
  final AdminOrderDetail order;

  @override
  State<AdminCreateShipmentDialog> createState() =>
      _AdminCreateShipmentDialogState();
}

final class _AdminCreateShipmentDialogState
    extends State<AdminCreateShipmentDialog> {
  final List<AdminShipmentLabelControllers> _labels = [];
  String _validation = '';

  void _addTracking() => setState(() {
        _labels.add(AdminShipmentLabelControllers());
        _validation = '';
      });

  Future<void> _submit() async {
    final draft = buildAdminShipmentCommand(
      fulfillment: widget.fulfillment,
      labels: [for (final row in _labels) row.draft],
    );
    final command = switch (draft) {
      Some(:final value) => value,
      None() => null,
    };
    if (command == null) {
      setState(() => _validation =
          'Use only HTTP(S) links and keep the fulfillment items unchanged.');
      return;
    }
    final saved = await context.readAdminOrderDetailViewModel().createShipment(
          widget.order.id,
          widget.fulfillment.id,
          command,
        );
    if (saved && mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    for (final row in _labels) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.watchAdminOrderDetailViewModel().value;
    final saving = detail.status == AdminOrderDetailStatus.saving;
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: _AdminShipmentDialogHeader(
            orderNumber: widget.order.displayId,
            onClose: saving ? null : Navigator.of(context).pop,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 736),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create shipment',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  for (var index = 0; index < _labels.length; index++)
                    AdminShipmentTrackingRow(
                      controllers: _labels[index],
                      showDesktopLabels: index == 0,
                      enabled: !saving,
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: saving ? null : _addTracking,
                      child: const Text('Add tracking'),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Divider(color: Theme.of(context).dividerColor),
                  const SizedBox(height: 24),
                  const _AdminShipmentNotificationField(),
                  _AdminShipmentFormMessage(
                    validation: _validation,
                    saveFailure: detail.failure,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _AdminShipmentDialogFooter(
          saving: saving,
          onCancel: Navigator.of(context).pop,
          onSubmit: _submit,
        ),
      ),
    );
  }
}

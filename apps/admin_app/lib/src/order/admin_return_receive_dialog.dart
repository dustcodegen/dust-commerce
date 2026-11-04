import 'package:admin_app/src/order/admin_return_state.dart';
import 'package:admin_app/src/order/admin_return_item_fields.dart';
import 'package:admin_app/src/order/admin_return_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Atomic Admin form for intact and damaged units received now.
final class AdminReturnReceiveDialog extends StatefulWidget {
  /// Creates a receipt dialog for one requested return.
  const AdminReturnReceiveDialog({
    required this.order,
    required this.value,
    super.key,
  });

  /// Order snapshot used for customer-facing line labels.
  final AdminOrderDetail order;

  /// Requested return being received.
  final AdminReturn value;

  @override
  State<AdminReturnReceiveDialog> createState() =>
      _AdminReturnReceiveDialogState();
}

final class _AdminReturnReceiveDialogState
    extends State<AdminReturnReceiveDialog> {
  final _intact = <String, TextEditingController>{};
  final _damaged = <String, TextEditingController>{};
  bool _sendNotification = false;
  String _validation = '';

  @override
  void initState() {
    super.initState();
    for (final item in widget.value.items) {
      final remaining = item.quantity - item.receivedQuantity;
      _intact[item.id] = TextEditingController(text: '$remaining');
      _damaged[item.id] = TextEditingController(text: '0');
    }
  }

  @override
  void dispose() {
    for (final controller in [..._intact.values, ..._damaged.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  int _read(Map<String, TextEditingController> values, String id) =>
      int.tryParse(values[id]?.text ?? '') ?? -1;

  Future<void> _submit() async {
    final items = <AdminReceiveReturnItem>[];
    for (final item in widget.value.items) {
      final intact = _read(_intact, item.id);
      final damaged = _read(_damaged, item.id);
      final remaining = item.quantity - item.receivedQuantity;
      if (intact < 0 || damaged < 0 || intact + damaged > remaining) {
        setState(() => _validation = 'Enter quantities up to $remaining.');
        return;
      }
      if (intact + damaged > 0) {
        items.add(AdminReceiveReturnItem(
          id: item.id,
          quantity: intact,
          damagedQuantity: damaged,
        ));
      }
    }
    if (items.isEmpty) {
      setState(() => _validation = 'Receive at least one item.');
      return;
    }
    await context.readAdminReturnViewModel().receive(
          widget.value.id,
          AdminReceiveReturn(
            items: items,
            noNotification: !_sendNotification,
          ),
        );
    if (mounted &&
        context.readAdminReturnViewModel().state.status ==
            AdminReturnLoadStatus.ready) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminReturnViewModel().value;
    final titles = {for (final item in widget.order.items) item.id: item.title};
    return AlertDialog(
      title: Text('Receive return #${widget.value.displayId}'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in widget.value.items)
                AdminReturnItemFields(
                  title: titles[item.orderItemId] ?? item.orderItemId,
                  remaining: item.quantity - item.receivedQuantity,
                  intact: _intact[item.id]!,
                  damaged: _damaged[item.id]!,
                ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Send notification'),
                subtitle: const Text('Notify the customer about this receipt.'),
                value: _sendNotification,
                onChanged: state.status == AdminReturnLoadStatus.saving
                    ? null
                    : (value) => setState(() => _sendNotification = value),
              ),
              if (_validation.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(_validation),
                ),
              if (state.failure case Some(:final value))
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(value),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: state.status == AdminReturnLoadStatus.saving
              ? null
              : Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              state.status == AdminReturnLoadStatus.saving ? null : _submit,
          child: Text(
            state.status == AdminReturnLoadStatus.saving ? 'Saving…' : 'Save',
          ),
        ),
      ],
    );
  }
}

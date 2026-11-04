import 'package:admin_app/src/order/admin_create_fulfillment_fields.dart';
import 'package:admin_app/src/order/admin_create_fulfillment_items.dart';
import 'package:admin_app/src/order/admin_fulfillment_context_state.dart';
import 'package:admin_app/src/order/admin_fulfillment_context_view_model.dart';
import 'package:admin_app/src/order/admin_fulfillment_draft.dart';
import 'package:admin_app/src/order/admin_fulfillment_selection.dart';
import 'package:admin_app/src/order/admin_order_detail_state.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_create_fulfillment_dialog_sections.dart';

/// Focus-mode fulfillment form shaped from Medusa's current Admin source.
final class AdminCreateFulfillmentDialog extends StatefulWidget {
  /// Creates the form from one complete order snapshot.
  const AdminCreateFulfillmentDialog({required this.order, super.key});

  /// Order whose remaining items may be assigned to a fulfillment.
  final AdminOrderDetail order;

  @override
  State<AdminCreateFulfillmentDialog> createState() =>
      _AdminCreateFulfillmentDialogState();
}

final class _AdminCreateFulfillmentDialogState
    extends State<AdminCreateFulfillmentDialog> {
  late final Map<String, int> _remaining;
  late final Map<String, int> _quantities;
  Option<String> _requestedShippingOptionId = const None();
  String _validation = '';

  @override
  void initState() {
    super.initState();
    _remaining = adminFulfillableQuantities(widget.order);
    _quantities = Map.of(_remaining);
  }

  Future<void> _selectLocation(String locationId) async {
    setState(() {
      _requestedShippingOptionId = const None();
      _validation = '';
    });
    await context
        .readAdminFulfillmentContextViewModel()
        .selectLocation(locationId);
  }

  void _selectShippingOption(String shippingOptionId) => setState(() {
        _requestedShippingOptionId = Some(shippingOptionId);
        _validation = '';
      });

  void _setQuantity(String id, int quantity) => setState(() {
        _quantities[id] = quantity;
        _validation = '';
      });

  Future<void> _submit(
    AdminFulfillmentContextState choices,
    Option<AdminFulfillmentShippingOption> selected,
  ) async {
    final locationId = switch (choices.selectedLocationId) {
      Some(:final value) => value,
      None() => '',
    };
    final option = switch (selected) {
      Some(:final value) => value,
      None() => null,
    };
    if (locationId.isEmpty || option == null) {
      setState(() => _validation = 'Choose a location and shipping method.');
      return;
    }
    final draft = buildAdminFulfillmentCommand(
      order: widget.order,
      locationId: locationId,
      shippingOption: option,
      quantities: _quantities,
    );
    final command = switch (draft) {
      Some(:final value) => value,
      None() => null,
    };
    if (command == null) {
      setState(() => _validation =
          'Select at least one compatible item within its remaining quantity.');
      return;
    }
    final saved = await context
        .readAdminOrderDetailViewModel()
        .createFulfillment(widget.order.id, command);
    if (saved && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final choices = context.watchAdminFulfillmentContextViewModel().value;
    final detail = context.watchAdminOrderDetailViewModel().value;
    final selected = resolveAdminFulfillmentShippingOption(
      choices.shippingOptions,
      _requestedShippingOptionId,
      widget.order.shippingOptionId,
    );
    final profile = switch (selected) {
      Some(:final value) => Some(value.shippingProfileId),
      None() => const None<String>(),
    };
    final saving = detail.status == AdminOrderDetailStatus.saving;
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: _AdminFulfillmentDialogHeader(
            orderNumber: widget.order.displayId,
            onClose: saving ? null : Navigator.of(context).pop,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 736),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminFulfillmentLocationField(
                    state: choices,
                    onChanged: _selectLocation,
                  ),
                  Divider(color: Theme.of(context).dividerColor),
                  AdminFulfillmentShippingOptionField(
                    options: choices.shippingOptions,
                    selected: selected.map((value) => value.id),
                    loading:
                        choices.status == AdminFulfillmentContextStatus.loading,
                    onChanged: _selectShippingOption,
                  ),
                  if (adminUsesDifferentFulfillmentOption(
                    selected,
                    widget.order,
                  ))
                    const _AdminFulfillmentMethodWarning(),
                  const SizedBox(height: 24),
                  AdminCreateFulfillmentItems(
                    order: widget.order,
                    remaining: _remaining,
                    quantities: _quantities,
                    shippingProfileId: profile,
                    enabled: !saving,
                    onChanged: _setQuantity,
                  ),
                  const SizedBox(height: 24),
                  const _AdminFulfillmentNotificationField(),
                  _AdminFulfillmentFormMessage(
                    validation: _validation,
                    choiceFailure: choices.failure,
                    saveFailure: detail.failure,
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _AdminFulfillmentDialogFooter(
          saving: saving,
          canSubmit: selected is Some<AdminFulfillmentShippingOption> &&
              choices.selectedLocationId is Some<String>,
          onCancel: Navigator.of(context).pop,
          onSubmit: () => _submit(choices, selected),
        ),
      ),
    );
  }
}

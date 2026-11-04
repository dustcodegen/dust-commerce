import 'package:admin_app/src/order/admin_fulfillment_context_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Location selector and source-faithful explanatory copy.
final class AdminFulfillmentLocationField extends StatelessWidget {
  /// Creates the location control.
  const AdminFulfillmentLocationField({
    required this.state,
    required this.onChanged,
    super.key,
  });

  /// Current discovery state.
  final AdminFulfillmentContextState state;

  /// Selects a new inventory origin.
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => _FulfillmentFieldRow(
        label: 'Location',
        hint: 'Choose the location that will fulfill these items.',
        child: DropdownButtonFormField<String>(
          initialValue: switch (state.selectedLocationId) {
            Some(:final value) => value,
            None() => null,
          },
          items: [
            for (final location in state.stockLocations)
              DropdownMenuItem(value: location.id, child: Text(location.name)),
          ],
          onChanged: state.status == AdminFulfillmentContextStatus.loading
              ? null
              : (value) {
                  if (value case final id?) onChanged(id);
                },
        ),
      );
}

/// Shipping-method selector constrained by location and order region.
final class AdminFulfillmentShippingOptionField extends StatelessWidget {
  /// Creates the method control.
  const AdminFulfillmentShippingOptionField({
    required this.options,
    required this.selected,
    required this.loading,
    required this.onChanged,
    super.key,
  });

  /// Whether compatible methods are being refreshed.
  final bool loading;

  /// Selects a shipping method.
  final ValueChanged<String> onChanged;

  /// Compatible active methods.
  final List<AdminFulfillmentShippingOption> options;

  /// Current method selection.
  final Option<String> selected;

  @override
  Widget build(BuildContext context) => _FulfillmentFieldRow(
        label: 'Shipping method',
        hint: 'Choose the shipping method for this fulfillment.',
        child: DropdownButtonFormField<String>(
          key: ValueKey((options.map((value) => value.id).toList(), selected)),
          initialValue: switch (selected) {
            Some(:final value) => value,
            None() => null,
          },
          items: [
            for (final option in options)
              DropdownMenuItem(value: option.id, child: Text(option.name)),
          ],
          onChanged: loading
              ? null
              : (value) {
                  if (value case final id?) onChanged(id);
                },
        ),
      );
}

final class _FulfillmentFieldRow extends StatelessWidget {
  const _FulfillmentFieldRow({
    required this.label,
    required this.hint,
    required this.child,
  });
  final Widget child;
  final String hint;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: LayoutBuilder(
          builder: (context, constraints) => constraints.maxWidth >= 620
              ? _WideFulfillmentFieldRow(
                  label: label,
                  hint: hint,
                  child: child,
                )
              : _NarrowFulfillmentFieldRow(
                  label: label,
                  hint: hint,
                  child: child,
                ),
        ),
      );
}

final class _WideFulfillmentFieldRow extends StatelessWidget {
  const _WideFulfillmentFieldRow({
    required this.label,
    required this.hint,
    required this.child,
  });
  final Widget child;
  final String hint;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _FulfillmentFieldLabel(label: label, hint: hint)),
          const SizedBox(width: 32),
          Expanded(child: child),
        ],
      );
}

final class _NarrowFulfillmentFieldRow extends StatelessWidget {
  const _NarrowFulfillmentFieldRow({
    required this.label,
    required this.hint,
    required this.child,
  });
  final Widget child;
  final String hint;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FulfillmentFieldLabel(label: label, hint: hint),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: child),
        ],
      );
}

final class _FulfillmentFieldLabel extends StatelessWidget {
  const _FulfillmentFieldLabel({required this.label, required this.hint});
  final String hint;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(
            hint,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
}

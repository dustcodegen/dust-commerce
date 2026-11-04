import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/order/admin_payment_refund_state.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Amount, optional reason, note, and failure content for the refund drawer.
final class AdminPaymentRefundFields extends StatelessWidget {
  /// Creates source-shaped refund controls.
  const AdminPaymentRefundFields({
    required this.amount,
    required this.note,
    required this.currencyCode,
    required this.refundableAmount,
    required this.refund,
    required this.selectedReasonId,
    required this.busy,
    required this.validateAmount,
    required this.onReasonChanged,
    super.key,
  });

  /// Exact decimal amount controller.
  final TextEditingController amount;

  /// Whether a command is in flight.
  final bool busy;

  /// Lowercase payment currency.
  final String currencyCode;

  /// Optional note controller.
  final TextEditingController note;

  /// Selects or clears the optional standardized reason.
  final ValueChanged<String?> onReasonChanged;

  /// Remaining balance in minor units.
  final int refundableAmount;

  /// Reason discovery and display-safe failure state.
  final AdminPaymentRefundState refund;

  /// Explicit selected reason.
  final Option<String> selectedReasonId;

  /// Validates the exact minor-unit amount.
  final FormFieldValidator<String> validateAmount;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            '${currencyCode.toUpperCase()} '
            '${formatMinorUnits(refundableAmount, currencyCode)} refundable',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Text('Amount', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: amount,
            enabled: !busy,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration:
                InputDecoration(prefixText: '${currencyCode.toUpperCase()} '),
            validator: validateAmount,
          ),
          const SizedBox(height: 20),
          Text('Refund reason', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          DropdownButtonFormField<String?>(
            initialValue: switch (selectedReasonId) {
              Some(:final value) => value,
              None() => null,
            },
            items: [
              const DropdownMenuItem<String?>(
                child: Text('No reason'),
              ),
              for (final reason in refund.reasons)
                DropdownMenuItem<String?>(
                  value: reason.id,
                  child: Text(reason.label),
                ),
            ],
            onChanged: busy ? null : onReasonChanged,
          ),
          const SizedBox(height: 20),
          Text('Note', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          TextFormField(
            controller: note,
            enabled: !busy,
            maxLength: 1000,
            minLines: 3,
            maxLines: 5,
          ),
          if (refund.failure case Some(:final value)) ...[
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      );
}

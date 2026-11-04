import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Optional Medusa-style reason selector for one selected return item.
final class OrderReturnReasonField extends StatelessWidget {
  /// Creates a selector entirely controlled by generated ViewModel state.
  const OrderReturnReasonField({
    required this.itemId,
    required this.reasons,
    required this.status,
    required this.selectedReasonId,
    required this.disabled,
    super.key,
  });

  /// Whether the field is locked while the request is submitted.
  final bool disabled;

  /// Frozen order-item identifier receiving the selection.
  final String itemId;

  /// Active reasons in server-owned taxonomy order.
  final List<ReturnReasonView> reasons;

  /// Selected reason identifier, or absence.
  final String? selectedReasonId;

  /// Current reason-discovery lifecycle.
  final OrderReturnReasonStatus status;

  @override
  Widget build(BuildContext context) => switch (status) {
        OrderReturnReasonStatus.idle ||
        OrderReturnReasonStatus.loading =>
          Semantics(
            label: context.tr(
              'shop_account_return_reason_loading',
              defaultText: 'Loading return reasons',
            ),
            child: const LinearProgressIndicator(minHeight: 2),
          ),
        OrderReturnReasonStatus.failed => Row(
            children: [
              const Expanded(
                child: TranslatedText(
                  'shop_account_return_reason_failed',
                  defaultText: 'Return reasons could not be loaded.',
                  style: TextStyle(color: StoreColors.foregroundSubtle),
                ),
              ),
              TextButton(
                onPressed: disabled
                    ? null
                    : () => context.readOrderReturnViewModel().loadReasons(),
                child: const TranslatedText(
                  'shop_retry',
                  defaultText: 'Try again',
                ),
              ),
            ],
          ),
        OrderReturnReasonStatus.loaded when reasons.isEmpty =>
          const TranslatedText(
            'shop_account_return_reason_empty',
            defaultText: 'No return reasons are available.',
            style: TextStyle(color: StoreColors.foregroundSubtle),
          ),
        OrderReturnReasonStatus.loaded => DropdownButtonFormField<String>(
            key: ValueKey('$itemId:$selectedReasonId:${reasons.length}'),
            initialValue: selectedReasonId ?? '',
            isExpanded: true,
            decoration: InputDecoration(
              labelText: context.tr(
                'shop_account_return_reason',
                defaultText: 'Reason (optional)',
              ),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(
                value: '',
                child: TranslatedText(
                  'shop_account_return_reason_choose',
                  defaultText: 'Choose a reason',
                  style: const TextStyle(color: StoreColors.foregroundSubtle),
                ),
              ),
              for (final reason in reasons)
                DropdownMenuItem(value: reason.id, child: Text(reason.label)),
            ],
            onChanged: disabled
                ? null
                : (value) => context.readOrderReturnViewModel().setReason(
                      itemId,
                      value == null || value.isEmpty
                          ? const None()
                          : Some(value),
                    ),
          ),
      };
}

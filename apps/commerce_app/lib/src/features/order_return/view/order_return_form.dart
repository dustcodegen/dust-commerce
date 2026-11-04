import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'order_return_feedback.dart';
import 'order_return_exhausted_state.dart';
import 'order_return_item_choice.dart';

/// Expanded item-selection form for one eligible order.
final class OrderReturnForm extends StatelessWidget {
  /// Creates the form from generated [state].
  const OrderReturnForm({
    required this.order,
    required this.state,
    super.key,
  });

  /// Frozen order that supplies item labels and maximum quantities.
  final Order order;

  /// Generated return-request state.
  final OrderReturnRequestState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == OrderReturnRequestStatus.succeeded) {
      return OrderReturnFeedback(state: state);
    }
    final pending = state.status == OrderReturnRequestStatus.submitting;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: StoreColors.neutral50,
        border: Border.all(color: StoreColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TranslatedText(
            'shop_account_request_return',
            defaultText: 'Request a return',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          if (state.availableQuantities.isEmpty)
            const OrderReturnExhaustedState()
          else ...[
            const TranslatedText(
              'shop_account_return_choose_items',
              defaultText:
                  'Choose the items and quantities you want to return.',
              style: TextStyle(color: StoreColors.foregroundSubtle),
            ),
            const SizedBox(height: 16),
            for (final item in order.items)
              if (state.availableQuantities[item.id] case final maximum?)
                OrderReturnItemChoice(
                  item: item,
                  availableQuantity: maximum,
                  quantity: state.quantities[item.id],
                  reasonId: state.reasonIds[item.id],
                  reasons: state.reasons,
                  reasonStatus: state.reasonStatus,
                  disabled: pending,
                ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.note.unwrapOr(''),
              enabled: !pending,
              minLines: 2,
              maxLines: 4,
              maxLength: 2000,
              onChanged: context.readOrderReturnViewModel().setNote,
              decoration: InputDecoration(
                labelText: context.tr(
                  'shop_account_return_note',
                  defaultText: 'Note (optional)',
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            if (state.status == OrderReturnRequestStatus.failed) ...[
              const SizedBox(height: 8),
              OrderReturnFailureText(failure: state.failure),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      pending ? null : context.readOrderReturnViewModel().close,
                  child: const TranslatedText(
                    'shop_cancel',
                    defaultText: 'Cancel',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: pending || state.quantities.isEmpty
                      ? null
                      : () => unawaited(
                            context.readOrderReturnViewModel().submit(),
                          ),
                  child: pending
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const TranslatedText(
                          'shop_account_submit_return',
                          defaultText: 'Submit return',
                        ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

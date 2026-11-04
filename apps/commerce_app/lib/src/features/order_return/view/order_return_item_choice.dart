import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// One frozen order line with an explicit return quantity.
final class OrderReturnItemChoice extends StatelessWidget {
  /// Creates an item choice controlled by the generated ViewModel state.
  const OrderReturnItemChoice({
    required this.item,
    required this.availableQuantity,
    required this.quantity,
    required this.reasonId,
    required this.reasons,
    required this.reasonStatus,
    required this.disabled,
    super.key,
  });

  /// Units that can still enter a new return request.
  final int availableQuantity;

  /// Whether controls are disabled during submission.
  final bool disabled;

  /// Frozen line item shown to the customer.
  final OrderLineItem item;

  /// Selected quantity, or absent when the item is not selected.
  final int? quantity;

  /// Selected optional merchant reason identifier.
  final String? reasonId;

  /// Active merchant reasons in server-owned taxonomy order.
  final List<ReturnReasonView> reasons;

  /// Current reason-discovery lifecycle.
  final OrderReturnReasonStatus reasonStatus;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: quantity != null,
                  onChanged: disabled
                      ? null
                      : (_) =>
                          context.readOrderReturnViewModel().toggle(item.id),
                ),
                SizedBox.square(
                  dimension: 48,
                  child: ProductImage(url: item.thumbnail, aspectRatio: 1),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      if (item.variantTitle case final title?)
                        Text(
                          title,
                          style: const TextStyle(
                            color: StoreColors.foregroundSubtle,
                          ),
                        ),
                    ],
                  ),
                ),
                if (quantity case final selected?) ...[
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: selected,
                    onChanged: disabled
                        ? null
                        : (value) {
                            if (value != null) {
                              context
                                  .readOrderReturnViewModel()
                                  .setQuantity(item.id, value);
                            }
                          },
                    items: [
                      for (var value = 1; value <= availableQuantity; value++)
                        DropdownMenuItem(
                          value: value,
                          child: Text(context.tr(
                            'shop_account_return_quantity',
                            defaultText: 'Qty {quantity}',
                            args: {'quantity': value},
                          )),
                        ),
                    ],
                  ),
                ],
              ],
            ),
            if (quantity != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: OrderReturnReasonField(
                  itemId: item.id,
                  reasons: reasons,
                  status: reasonStatus,
                  selectedReasonId: reasonId,
                  disabled: disabled,
                ),
              ),
            ],
          ],
        ),
      );
}

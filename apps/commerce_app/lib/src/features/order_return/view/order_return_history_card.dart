import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// One compact customer-safe return status row.
final class OrderReturnHistoryCard extends StatelessWidget {
  /// Creates a card for one explicit Store return allowlist.
  const OrderReturnHistoryCard({required this.item, super.key});

  /// Customer-visible request facts.
  final OrderReturnView item;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: StoreColors.neutral50,
          border: Border.all(color: StoreColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      'shop_account_return_number',
                      defaultText: 'Return #{id}',
                      args: {'id': item.displayId},
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatStoreDate(MaterialLocalizations.of(context), item.requestedAt)} · '
                    '${item.itemQuantity == 1 ? context.tr(
                        'shop_account_return_item',
                        defaultText: '{quantity} item',
                        args: {'quantity': item.itemQuantity},
                      ) : context.tr(
                        'shop_account_return_items',
                        defaultText: '{quantity} items',
                        args: {'quantity': item.itemQuantity},
                      )}',
                    style: const TextStyle(
                      color: StoreColors.foregroundSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              switch (item.status) {
                OrderReturnStatus.open => context.tr(
                    'shop_account_return_status_open',
                    defaultText: 'Open',
                  ),
                OrderReturnStatus.requested => context.tr(
                    'shop_account_return_status_requested',
                    defaultText: 'Requested',
                  ),
                OrderReturnStatus.partiallyReceived => context.tr(
                    'shop_account_return_status_partially_received',
                    defaultText: 'Partially received',
                  ),
                OrderReturnStatus.received => context.tr(
                    'shop_account_return_status_received',
                    defaultText: 'Received',
                  ),
                OrderReturnStatus.canceled => context.tr(
                    'shop_account_return_status_canceled',
                    defaultText: 'Canceled',
                  ),
              },
              style: const TextStyle(color: StoreColors.foregroundSubtle),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      );
}

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Dismissible response shown after a transfer request is accepted.
final class AccountOrderTransferSuccess extends StatelessWidget {
  /// Creates delivery-aware success feedback.
  const AccountOrderTransferSuccess({
    required this.state,
    required this.fallbackOrderId,
    super.key,
  });

  /// Input used only if the protocol response omitted its order id.
  final String fallbackOrderId;

  /// Completed request state.
  final OrderTransferState state;

  @override
  Widget build(BuildContext context) {
    final id = state.orderId.unwrapOr(fallbackOrderId);
    final delivered =
        state.deliveryStatus == const Some(OrderTransferDeliveryStatus.sent);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: StoreColors.neutral50,
          border: Border.all(color: StoreColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              size: 16,
              color: StoreColors.success,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.tr(
                      'shop_account_transfer_requested',
                      defaultText: 'Transfer for order {id} requested',
                      args: {'id': id},
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    delivered
                        ? context.tr(
                            'shop_account_transfer_email_sent',
                            defaultText:
                                'Email sent to the current order contact.',
                          )
                        : context.tr(
                            'shop_account_transfer_email_pending',
                            defaultText: 'Email delivery is pending. Submit '
                                'the same order again to retry.',
                          ),
                    style: const TextStyle(
                      color: StoreColors.foregroundSubtle,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: context.readOrderTransferViewModel().reset,
              tooltip: context.tr('shop_close', defaultText: 'Close'),
              icon: const Icon(
                Icons.cancel,
                size: 16,
                color: StoreColors.foregroundMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

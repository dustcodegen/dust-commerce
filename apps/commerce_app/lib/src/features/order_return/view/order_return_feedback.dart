import 'package:commerce_app/commerce_app.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Live-region acknowledgement after the server persists a return request.
final class OrderReturnFeedback extends StatelessWidget {
  /// Creates feedback from successful generated state.
  const OrderReturnFeedback({required this.state, super.key});

  /// State containing the persisted acknowledgement.
  final OrderReturnRequestState state;

  @override
  Widget build(BuildContext context) => state.request.match(
        some: (request) => Semantics(
          liveRegion: true,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: StoreColors.neutral50,
              border: Border.all(color: StoreColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: StoreColors.success,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr(
                          'shop_account_return_received',
                          defaultText: 'Return request #{id} received',
                          args: {'id': request.displayId},
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        context.tr(
                          'shop_account_return_received_body',
                          defaultText:
                              'We will review your request for {quantity} item(s).',
                          args: {'quantity': request.itemQuantity},
                        ),
                        style: const TextStyle(
                          color: StoreColors.foregroundSubtle,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: context.readOrderReturnViewModel().close,
                  tooltip: context.tr('shop_close', defaultText: 'Close'),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
          ),
        ),
        none: () => const SizedBox.shrink(),
      );
}

/// Localized public failure that never echoes server internals.
final class OrderReturnFailureText extends StatelessWidget {
  /// Creates a live-region failure from the classified state.
  const OrderReturnFailureText({required this.failure, super.key});

  /// Latest classified return failure.
  final Option<OrderReturnFailure> failure;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Text(
          _message(context),
          style: const TextStyle(color: StoreColors.danger),
        ),
      );

  String _message(BuildContext context) => failure.match(
        some: (value) => switch (value) {
          OrderReturnFailure.invalidSelection => context.tr(
              'shop_account_return_choose_one',
              defaultText: 'Choose at least one item to return.',
            ),
          OrderReturnFailure.unauthorized => context.tr(
              'shop_account_return_session_expired',
              defaultText: 'Your session has expired. Please sign in again.',
            ),
          OrderReturnFailure.unavailable => context.tr(
              'shop_account_return_unavailable',
              defaultText: 'This order is no longer available.',
            ),
          OrderReturnFailure.notEligible => context.tr(
              'shop_account_return_not_eligible',
              defaultText: 'These items can no longer be returned.',
            ),
          OrderReturnFailure.retryable => context.tr(
              'shop_account_return_failed',
              defaultText: 'We could not request the return. Please try again.',
            ),
        },
        none: () => context.tr(
          'shop_account_return_failed',
          defaultText: 'We could not request the return. Please try again.',
        ),
      );
}

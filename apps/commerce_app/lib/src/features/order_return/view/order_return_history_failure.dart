import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Retryable, display-safe customer return-history failure.
final class OrderReturnHistoryFailureNotice extends StatelessWidget {
  /// Creates a failure notice without server internals.
  const OrderReturnHistoryFailureNotice({required this.failure, super.key});

  /// Classified history failure.
  final OrderReturnHistoryFailure failure;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: Row(
          children: [
            Expanded(
              child: Text(
                switch (failure) {
                  OrderReturnHistoryFailure.sessionExpired => context.tr(
                      'shop_account_return_session_expired',
                      defaultText:
                          'Your session has expired. Please sign in again.',
                    ),
                  OrderReturnHistoryFailure.unavailable => context.tr(
                      'shop_account_return_unavailable',
                      defaultText: 'This order is no longer available.',
                    ),
                  OrderReturnHistoryFailure.retryable => context.tr(
                      'shop_account_return_history_failed',
                      defaultText: 'Return history could not be loaded.',
                    ),
                },
                style: const TextStyle(color: StoreColors.danger),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => unawaited(
                context.readOrderReturnHistoryViewModel().retry(),
              ),
              child: const TranslatedText(
                'shop_retry',
                defaultText: 'Try again',
              ),
            ),
          ],
        ),
      );
}

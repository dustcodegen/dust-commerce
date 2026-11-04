import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'order_return_history_card.dart';
import 'order_return_history_failure.dart';

/// Customer-visible return history beneath the source-shaped help block.
final class OrderReturnHistory extends StatelessWidget {
  /// Creates history from generated paginated state.
  const OrderReturnHistory({required this.state, super.key});

  /// Current customer-owned history state.
  final OrderReturnHistoryState state;

  @override
  Widget build(BuildContext context) {
    if (state.status == OrderReturnHistoryStatus.loading &&
        state.returns.isEmpty) {
      return Semantics(
        label: context.tr(
          'shop_account_return_history_loading',
          defaultText: 'Loading return history',
        ),
        child: const LinearProgressIndicator(),
      );
    }
    if (state.returns.isEmpty) {
      return state.failure.match(
        some: (failure) => OrderReturnHistoryFailureNotice(failure: failure),
        none: () => const SizedBox.shrink(),
      );
    }
    final loadingMore = state.status == OrderReturnHistoryStatus.loadingMore;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TranslatedText(
          'shop_account_return_history',
          defaultText: 'Return history',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        for (final item in state.returns) ...[
          OrderReturnHistoryCard(item: item),
          const SizedBox(height: 8),
        ],
        state.failure.match(
          some: (failure) => OrderReturnHistoryFailureNotice(failure: failure),
          none: () => const SizedBox.shrink(),
        ),
        if (state.hasMore) ...[
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: loadingMore
                ? null
                : () => unawaited(
                      context.readOrderReturnHistoryViewModel().loadMore(),
                    ),
            icon: loadingMore
                ? const SizedBox.square(
                    dimension: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.expand_more, size: 18),
            label: const TranslatedText(
              'shop_account_return_load_more',
              defaultText: 'Show more returns',
            ),
          ),
        ],
      ],
    );
  }
}

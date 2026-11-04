import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Latest five customer orders in the compact Medusa overview format.
final class AccountRecentOrders extends StatelessWidget {
  /// Creates the recent-order result state.
  const AccountRecentOrders({
    required this.state,
    required this.orders,
    super.key,
  });

  /// At most five orders, already restricted by the overview summary.
  final List<Order> orders;

  /// Source loading and failure state.
  final AccountOrdersState state;

  @override
  Widget build(BuildContext context) {
    if (!state.hasLoaded) {
      return switch (state.status) {
        AccountOrdersStatus.failed => _OrderLoadFailure(
            failure: state.failure,
          ),
        _ => const Align(
            alignment: Alignment.centerLeft,
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      };
    }
    if (orders.isEmpty) {
      return const TranslatedText(
        'shop_account_no_orders',
        defaultText: 'No recent orders',
      );
    }
    return Column(
      children: [
        for (final (index, order) in orders.indexed) ...[
          _RecentOrderCard(order: order),
          if (index < orders.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

final class _RecentOrderCard extends StatelessWidget {
  const _RecentOrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        excludeSemantics: true,
        label: context.tr(
          'shop_account_open_order',
          defaultText: 'Go to order #{id}',
          args: {'id': order.displayId},
        ),
        child: Material(
          color: StoreColors.neutral50,
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () =>
                context.navigator.accountOrderDetail(id: order.id).go(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _OrderValue(
                          label: context.tr(
                            'shop_account_date_placed',
                            defaultText: 'Date placed',
                          ),
                          value: formatStoreDate(
                            MaterialLocalizations.of(context),
                            order.placedAt,
                          ),
                        ),
                        _OrderValue(
                          label: context.tr(
                            'shop_account_order_number',
                            defaultText: 'Order number',
                          ),
                          value: '#${order.displayId}',
                        ),
                        _OrderValue(
                          label: context.tr(
                            'shop_account_total_amount',
                            defaultText: 'Total amount',
                          ),
                          value: formatMoney(order.total),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const RotatedBox(
                    quarterTurns: 3,
                    child: Icon(Icons.keyboard_arrow_down, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

final class _OrderValue extends StatelessWidget {
  const _OrderValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
      );
}

final class _OrderLoadFailure extends StatelessWidget {
  const _OrderLoadFailure({required this.failure});

  final Option<AccountOrdersFailure> failure;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_message(context)),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: context.readAccountOrdersViewModel().load,
            child: const TranslatedText('shop_retry', defaultText: 'Try again'),
          ),
        ],
      );

  String _message(BuildContext context) => switch (failure) {
        Some(value: AccountOrdersFailure.unauthorized) => context.tr(
            'shop_account_order_session_expired',
            defaultText: 'Your session has expired. Please sign in again.',
          ),
        _ => context.tr(
            'shop_account_orders_load_failed',
            defaultText: 'We could not load your orders. Please try again.',
          ),
      };
}

import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_order_detail_content.dart';
import 'account_route_layout.dart';
import 'account_section.dart';

/// Authenticated Medusa order-detail route.
@AppRoute(
  '/account/orders/details/:id',
  name: 'accountOrderDetail',
  guards: [CustomerGuard],
)
final class AccountOrderDetailPage extends StatefulWidget {
  /// Creates the order-detail route for [id].
  const AccountOrderDetailPage({required this.id, super.key});

  /// Opaque order identifier checked against the authenticated customer.
  final String id;

  @override
  State<AccountOrderDetailPage> createState() => _AccountOrderDetailPageState();
}

final class _AccountOrderDetailPageState extends State<AccountOrderDetailPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(AccountOrderDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id != widget.id) _load();
  }

  void _load() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(
            context.readAccountOrderDetailViewModel().load(widget.id),
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    final account = context.watchAccountViewModel().value;
    final state = context.watchAccountOrderDetailViewModel().value;
    final customer = account.customer;
    return StoreScaffold(
      body: customer == null
          ? const Center(child: CircularProgressIndicator())
          : AccountRouteLayout(
              customer: customer,
              state: account,
              active: AccountSection.orders,
              child: _AccountOrderDetailBody(id: widget.id, state: state),
            ),
    );
  }
}

final class _AccountOrderDetailBody extends StatelessWidget {
  const _AccountOrderDetailBody({required this.id, required this.state});

  final String id;
  final AccountOrderDetailState state;

  @override
  Widget build(BuildContext context) => switch (state.status) {
        AccountOrderDetailStatus.idle ||
        AccountOrderDetailStatus.loading =>
          const Center(child: CircularProgressIndicator()),
        AccountOrderDetailStatus.ready => state.order.match(
            some: (order) => AccountOrderDetailContent(order: order),
            none: () => _AccountOrderDetailFailure(id: id, state: state),
          ),
        AccountOrderDetailStatus.failed =>
          _AccountOrderDetailFailure(id: id, state: state),
      };
}

final class _AccountOrderDetailFailure extends StatelessWidget {
  const _AccountOrderDetailFailure({required this.id, required this.state});

  final String id;
  final AccountOrderDetailState state;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(state.failure.match(
            some: (failure) => switch (failure) {
              AccountOrderDetailFailure.sessionExpired => context.tr(
                  'shop_account_order_session_expired',
                  defaultText:
                      'Your session has expired. Please sign in again.',
                ),
              AccountOrderDetailFailure.unavailable => context.tr(
                  'shop_account_order_unavailable',
                  defaultText: 'We could not find that order.',
                ),
              AccountOrderDetailFailure.retryable => context.tr(
                  'shop_account_order_load_failed',
                  defaultText:
                      'We could not load this order. Please try again.',
                ),
            },
            none: () => context.tr(
              'shop_account_order_load_failed',
              defaultText: 'We could not load this order. Please try again.',
            ),
          )),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.readAccountOrderDetailViewModel().load(id),
            child: const TranslatedText('shop_retry', defaultText: 'Try again'),
          ),
        ],
      );
}

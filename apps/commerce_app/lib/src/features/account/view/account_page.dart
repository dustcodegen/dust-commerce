import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_auth_form.dart';
import 'account_overview.dart';

/// Medusa-compatible account entrypoint and authenticated overview.
@AppRoute('/account', name: 'account', guards: [])
class AccountPage extends StatelessWidget {
  /// Creates the account page.
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watchAccountViewModel().value;
    final addresses = context.watchAddressBookViewModel().value;
    final orders = context.watchAccountOrdersViewModel().value;
    if (state.customer != null) {
      _queueOverviewLoads(context, addresses, orders);
    }
    return StoreScaffold(
      body: switch (state) {
        AccountState(customer: final customer?) => AccountOverview(
            customer: customer,
            state: state,
            addresses: addresses,
            orders: orders,
          ),
        AccountState(
          status: AccountStatus.loading,
          operation: AccountOperation.restore,
        ) ||
        AccountState(status: AccountStatus.initial) =>
          const Center(child: CircularProgressIndicator()),
        AccountState(
          status: AccountStatus.failed,
          operation: AccountOperation.restore,
        ) =>
          _RestoreFailure(message: state.message),
        _ => const AccountAuthForm(),
      },
    );
  }
}

void _queueOverviewLoads(
  BuildContext context,
  AddressBookState addresses,
  AccountOrdersState orders,
) {
  final addressBook = context.readAddressBookViewModel();
  final orderHistory = context.readAccountOrdersViewModel();
  if (addresses.status == AddressBookStatus.idle) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(addressBook.load()),
    );
  }
  if (orders.status == AccountOrdersStatus.idle) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(orderHistory.load()),
    );
  }
}

class _RestoreFailure extends StatelessWidget {
  const _RestoreFailure({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message ??
                    context.tr(
                      'shop_account_restore_failed',
                      defaultText: 'We could not verify your saved session.',
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: context.readAccountViewModel().restore,
                child: const TranslatedText(
                  'shop_retry',
                  defaultText: 'Try again',
                ),
              ),
            ],
          ),
        ),
      );
}

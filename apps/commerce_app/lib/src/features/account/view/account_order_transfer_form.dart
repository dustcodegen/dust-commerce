import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

import 'account_order_transfer_intro.dart';
import 'account_order_transfer_request.dart';
import 'account_order_transfer_success.dart';

/// Source-shaped form for connecting an existing order to this account.
final class AccountOrderTransferForm extends StatefulWidget {
  /// Creates the order-transfer request form.
  const AccountOrderTransferForm({super.key});

  @override
  State<AccountOrderTransferForm> createState() =>
      _AccountOrderTransferFormState();
}

final class _AccountOrderTransferFormState
    extends State<AccountOrderTransferForm> {
  final _form = GlobalKey<FormState>();
  final _orderId = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readOrderTransferViewModel().reset();
    });
  }

  @override
  void dispose() {
    _orderId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchOrderTransferViewModel().value;
    final desktop = MediaQuery.sizeOf(context).width >= 1024;
    const intro = AccountOrderTransferIntro();
    final form = AccountOrderTransferRequest(
      formKey: _form,
      orderIdController: _orderId,
      state: state,
      onSubmit: _submit,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (desktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: intro),
              const SizedBox(width: 32),
              Expanded(child: form),
            ],
          )
        else ...[
          intro,
          const SizedBox(height: 16),
          form,
        ],
        if (state.status == OrderTransferActionStatus.failed) ...[
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              orderTransferFailureMessage(context, state.failure),
              textAlign: TextAlign.right,
              style: const TextStyle(color: StoreColors.rose),
            ),
          ),
        ],
        if (state.status == OrderTransferActionStatus.succeeded) ...[
          const SizedBox(height: 16),
          AccountOrderTransferSuccess(
            state: state,
            fallbackOrderId: _orderId.text.trim(),
          ),
        ],
      ],
    );
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    unawaited(context.readOrderTransferViewModel().request(_orderId.text));
  }
}

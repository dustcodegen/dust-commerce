import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Order ID field and submit action for an ownership-transfer request.
final class AccountOrderTransferRequest extends StatelessWidget {
  /// Creates the request controls owned by the parent form lifecycle.
  const AccountOrderTransferRequest({
    required this.formKey,
    required this.orderIdController,
    required this.state,
    required this.onSubmit,
    super.key,
  });

  /// Form boundary used to validate deliberate submissions.
  final GlobalKey<FormState> formKey;

  /// Submits the normalized order ID through the transfer ViewModel.
  final VoidCallback onSubmit;

  /// Controller owned and disposed by the route-level form.
  final TextEditingController orderIdController;

  /// Current request lifecycle used to disable duplicate submissions.
  final OrderTransferState state;

  @override
  Widget build(BuildContext context) {
    final busy = state.status == OrderTransferActionStatus.pending;
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextFormField(
            controller: orderIdController,
            enabled: !busy,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) {
              if (!busy) onSubmit();
            },
            validator: (value) => value == null || value.trim().isEmpty
                ? context.tr(
                    'shop_account_order_id_required',
                    defaultText: 'Order ID is required',
                  )
                : null,
            decoration: InputDecoration(
              hintText: context.tr(
                'shop_account_order_id',
                defaultText: 'Order ID',
              ),
              filled: true,
              fillColor: StoreColors.subtle,
              border: const OutlineInputBorder(),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: StoreColors.border),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: busy ? null : onSubmit,
            child: busy
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const TranslatedText(
                    'shop_account_request_transfer',
                    defaultText: 'Request transfer',
                  ),
          ),
        ],
      ),
    );
  }
}

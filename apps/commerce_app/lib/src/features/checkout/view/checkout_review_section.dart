import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'checkout_primary_action.dart';
import 'checkout_step_header.dart';

/// Legal acknowledgement and final idempotent place-order action.
final class CheckoutReviewSection extends StatelessWidget {
  /// Creates the review step.
  const CheckoutReviewSection({
    required this.open,
    required this.state,
    super.key,
  });

  /// Whether final review is expanded.
  final bool open;

  /// Placement progress and retry-safe failure state.
  final CheckoutState state;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CheckoutStepHeader(
            title: context.tr('shop_checkout_review', defaultText: 'Review'),
            open: open,
            complete: false,
          ),
          if (open) ...[
            const TranslatedText(
              'shop_checkout_review_terms',
              defaultText:
                  'By clicking the Place Order button, you confirm that you '
                  'have read, understand and accept our Terms of Use, Terms of '
                  'Sale and Returns Policy and acknowledge that you have read '
                  "Morrow's Privacy Policy.",
              style: _reviewTermsStyle,
            ),
            if (state.status == CheckoutStatus.failed &&
                state.operation == CheckoutOperation.place)
              StoreErrorMessage(state.message!),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: CheckoutPrimaryAction(
                label: context.tr(
                  'shop_checkout_place_order',
                  defaultText: 'Place order',
                ),
                busy: state.isBusy,
                onPressed: () => _place(context),
              ),
            ),
          ],
        ],
      );

  Future<void> _place(BuildContext context) async {
    final checkout = context.readCheckoutViewModel();
    if (!await checkout.placeOrder() || !context.mounted) return;
    context.navigator.orderConfirmed(id: checkout.state.order!.id).go();
  }
}

const _reviewTermsStyle = TextStyle(
  fontSize: 14,
  height: 20 / 14,
  fontWeight: FontWeight.w600,
);

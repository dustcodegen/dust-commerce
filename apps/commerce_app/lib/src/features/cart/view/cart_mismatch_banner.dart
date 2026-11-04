import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Global Medusa-style recovery banner for an unclaimed customer cart.
final class CartMismatchBanner extends StatelessWidget {
  /// Creates the cart ownership recovery banner.
  const CartMismatchBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final account = context.watchAccountViewModel().value;
    final cartState = context.watchCartViewModel().value;
    final cart = cartState.cart?.cart;
    if (!account.isAuthenticated || cart == null || cart.customerId != null) {
      return const SizedBox.shrink();
    }
    final pending = cartState.status == CartStatus.loading &&
        cartState.operation == CartOperation.transfer;

    return ColoredBox(
      color: const Color(0xfffdba74),
      child: Padding(
        padding: EdgeInsets.all(
          MediaQuery.sizeOf(context).width >= 640 ? 16 : 8,
        ),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            const Icon(
              Icons.error,
              size: 16,
              color: Color(0xff9a3412),
            ),
            Text(
              context.tr(
                'shop_cart_transfer_failed',
                defaultText:
                    'Something went wrong when we tried to transfer your cart',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff9a3412),
                fontSize: 14,
              ),
            ),
            const Icon(
              Icons.circle,
              size: 3,
              color: Color(0xff9a3412),
            ),
            TextButton(
              onPressed: pending
                  ? null
                  : context.readCartViewModel().transferToCustomer,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xff431407),
                disabledForegroundColor: const Color(0xfff97316),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                pending
                    ? context.tr(
                        'shop_cart_transferring',
                        defaultText: 'Transferring..',
                      )
                    : context.tr(
                        'shop_cart_transfer_retry',
                        defaultText: 'Run transfer again',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

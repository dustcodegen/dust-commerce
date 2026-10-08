import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'cart_preview_footer.dart';
import 'cart_preview_line.dart';

/// Source-sized contents of the desktop navigation cart popover.
class CartPreviewPanel extends StatelessWidget {
  /// Creates the preview for [state].
  const CartPreviewPanel({
    required this.state,
    required this.onEnter,
    required this.onExit,
    required this.onClose,
    super.key,
  });

  /// Current server cart state.
  final CartState state;

  /// Keeps the overlay open while its pointer is inside.
  final VoidCallback onEnter;

  /// Schedules dismissal when the pointer leaves.
  final VoidCallback onExit;

  /// Closes the overlay before navigation.
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => onEnter(),
        onExit: (_) => onExit(),
        child: Container(
          width: 420,
          decoration: const BoxDecoration(
            color: StoreColors.base,
            border: Border(
              left: BorderSide(color: StoreColors.border),
              right: BorderSide(color: StoreColors.border),
              bottom: BorderSide(color: StoreColors.border),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: TranslatedText(
                  'shop_cart_title',
                  defaultText: 'Cart',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (state.cart case final view? when !view.cart.isEmpty)
                _PopulatedPreview(
                  view: view,
                  state: state,
                  onClose: onClose,
                )
              else
                _EmptyPreview(onClose: onClose),
            ],
          ),
        ),
      );
}

class _PopulatedPreview extends StatelessWidget {
  const _PopulatedPreview({
    required this.view,
    required this.state,
    required this.onClose,
  });

  final VoidCallback onClose;
  final CartState state;
  final CartView view;

  double get _listHeight {
    final count = view.cart.items.length;
    return (count * 96 + (count - 1) * 32).clamp(96, 402).toDouble();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SizedBox(
            height: _listHeight,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (_, index) => CartPreviewLine(
                item: view.cart.items.reversed.elementAt(index),
                state: state,
                onClose: onClose,
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 32),
              itemCount: view.cart.items.length,
            ),
          ),
          CartPreviewFooter(subtotal: view.subtotal, onClose: onClose),
        ],
      );
}

class _EmptyPreview extends StatelessWidget {
  const _EmptyPreview({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: StoreColors.inverted,
                shape: BoxShape.circle,
              ),
              child: Text(
                0.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            const TranslatedText(
              'shop_cart_preview_empty',
              defaultText: 'Your shopping bag is empty.',
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                onClose();
                context.navigator.catalog().go();
              },
              child: const TranslatedText(
                'shop_explore_products',
                defaultText: 'Explore products',
              ),
            ),
          ],
        ),
      );
}

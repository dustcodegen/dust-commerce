import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Cart row remove/select controls translated from Medusa's `Item`.
class CartQuantityControl extends StatelessWidget {
  /// Creates the cart quantity controls for one line.
  const CartQuantityControl({
    required this.item,
    required this.enabled,
    required this.active,
    super.key,
  });

  /// Whether this line is currently mutating.
  final bool active;

  /// Whether line mutations are currently accepted.
  final bool enabled;

  /// Cart line controlled by this widget.
  final LineItem item;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: enabled
                ? () => context.readCartViewModel().remove(item.id)
                : null,
            icon: const Icon(Icons.delete_outline, size: 18),
            tooltip: context.tr('shop_cart_remove', defaultText: 'Remove'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 40),
          ),
          Container(
            width: 56,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: StoreColors.subtleHover,
              border: Border.all(color: StoreColors.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: item.quantity.clamp(1, 10),
                isExpanded: true,
                onChanged: enabled ? (value) => _update(context, value) : null,
                items: [
                  for (var quantity = 1; quantity <= 10; quantity++)
                    DropdownMenuItem(value: quantity, child: Text('$quantity')),
                ],
              ),
            ),
          ),
          if (active) ...[
            const SizedBox(width: 8),
            const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ],
      );

  void _update(BuildContext context, int? value) {
    if (value == null || value == item.quantity) return;
    context.readCartViewModel().updateQuantity(item.id, value);
  }
}

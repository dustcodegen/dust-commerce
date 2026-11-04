import 'package:flutter/material.dart';

/// Applied promotion badge copied from the source discount row.
class CartPromotionBadge extends StatelessWidget {
  /// Creates the applied promotion badge.
  const CartPromotionBadge({
    required this.code,
    required this.value,
    super.key,
  });

  /// Promotion code shown inside the grey pill.
  final String code;

  /// Human-readable percentage or fixed discount value.
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xfff3f4f6),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                code,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff374151),
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Text(
            ' ($value)',
            style: const TextStyle(
              fontSize: 12,
              height: 20 / 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
}

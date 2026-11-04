import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped free-shipping label and progress track.
final class FreeShippingProgressSummary extends StatelessWidget {
  /// Creates a summary from server-derived cart progress.
  const FreeShippingProgressSummary({required this.progress, super.key});

  /// Current progress toward the configured shipping rule.
  final FreeShippingProgress progress;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: progress.targetReached
                    ? const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Color(0xff22c55e),
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          TranslatedText(
                            'shop_free_shipping_unlocked',
                            defaultText: 'Free Shipping unlocked!',
                            style: TextStyle(
                              color: Color(0xffa1a1aa),
                              fontSize: 15,
                            ),
                          ),
                        ],
                      )
                    : const TranslatedText(
                        'shop_free_shipping_unlock',
                        defaultText: 'Unlock Free Shipping',
                        style: TextStyle(
                          color: Color(0xffa1a1aa),
                          fontSize: 15,
                        ),
                      ),
              ),
              if (!progress.targetReached)
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: Color(0xffa1a1aa),
                      fontSize: 15,
                    ),
                    children: [
                      TextSpan(
                        text: context.tr(
                          'shop_free_shipping_only',
                          defaultText: 'Only ',
                        ),
                      ),
                      TextSpan(
                        text: formatMoney(progress.remaining),
                        style: const TextStyle(color: StoreColors.base),
                      ),
                      TextSpan(
                        text: context.tr(
                          'shop_free_shipping_away',
                          defaultText: ' away',
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.end,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const ColoredBox(color: Color(0xff52525b)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.fraction,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: progress.targetReached
                              ? const [Color(0xff4ade80), Color(0xff22c55e)]
                              : const [Color(0xffa1a1aa), Color(0xff71717a)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}

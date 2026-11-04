import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'free_shipping_progress_summary.dart';

/// Source-shaped free-shipping popup and its completion fade.
final class FreeShippingPopup extends StatelessWidget {
  /// Creates the popup for current [progress].
  const FreeShippingPopup({
    required this.progress,
    required this.fading,
    required this.onFadeEnd,
    super.key,
  });

  /// Whether the unlocked message is fading out.
  final bool fading;

  /// Marks the completed fade as hidden.
  final VoidCallback onFadeEnd;

  /// Current progress toward free shipping.
  final FreeShippingProgress progress;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
        opacity: fading ? 0 : 1,
        duration: const Duration(milliseconds: 500),
        onEnd: onFadeEnd,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed: context.readCartViewModel().dismissFreeShippingNudge,
                tooltip: context.tr(
                  'shop_free_shipping_close',
                  defaultText: 'Close free shipping message',
                ),
                style: IconButton.styleFrom(
                  backgroundColor: StoreColors.foreground,
                  foregroundColor: StoreColors.base,
                ),
                icon: const Icon(Icons.close, size: 20),
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FreeShippingProgressSummary(progress: progress),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          OutlinedButton(
                            onPressed: () => context.navigator.cart().go(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: StoreColors.base,
                              backgroundColor: Colors.transparent,
                              side: const BorderSide(color: StoreColors.base),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const TranslatedText(
                              'shop_free_shipping_view_cart',
                              defaultText: 'View cart',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: () => context.navigator.store().go(),
                              style: FilledButton.styleFrom(
                                backgroundColor: StoreColors.base,
                                foregroundColor: StoreColors.foreground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const TranslatedText(
                                'shop_free_shipping_view_products',
                                defaultText: 'View products',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

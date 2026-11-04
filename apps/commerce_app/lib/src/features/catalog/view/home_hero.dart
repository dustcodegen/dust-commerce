import 'package:commerce_app/src/core/store_theme.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-height storefront hero using the Morrow brand contract.
class HomeHero extends StatelessWidget {
  /// Creates the storefront hero.
  const HomeHero({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: MediaQuery.sizeOf(context).height * 0.75,
        constraints: const BoxConstraints(minHeight: 440),
        decoration: const BoxDecoration(
          color: StoreColors.subtle,
          border: Border(bottom: BorderSide(color: StoreColors.border)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 240) {
              return const SizedBox.shrink();
            }
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const TranslatedText(
                    'shop_hero_title',
                    defaultText: 'Everyday essentials, considered.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const TranslatedText(
                    'shop_hero_subtitle',
                    defaultText: 'Powered by dust',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                      color: StoreColors.foregroundSubtle,
                    ),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () =>
                        PrimaryScrollController.of(context).animateTo(
                      MediaQuery.sizeOf(context).height * 0.75,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                    ),
                    child: const TranslatedText(
                      'shop_products_action',
                      defaultText: 'Shop products',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
}

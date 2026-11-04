import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'store_footer_links.dart';

/// Shared main-route footer translated from Medusa's Footer template.
class StoreFooter extends StatelessWidget {
  /// Creates the source-shaped storefront footer.
  const StoreFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = context.watchStoreShellViewModel().value;
    return DecoratedBox(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: StoreColors.border)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1440),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 160),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final brand = _FooterBrand(
                        onPressed: () => context.navigator.catalog().go(),
                      );
                      final links = StoreFooterLinks(
                        categories: shell.categories,
                        collections: shell.collections,
                      );
                      if (constraints.maxWidth < 576) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            brand,
                            const SizedBox(height: 24),
                            links,
                          ],
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          brand,
                          const SizedBox(width: 40),
                          Flexible(child: links),
                        ],
                      );
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: _FooterBottom(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: StoreColors.foregroundSubtle,
          textStyle: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        child: const TranslatedText(
          'shop_brand',
          defaultText: 'MORROW',
        ),
      );
}

class _FooterBottom extends StatelessWidget {
  const _FooterBottom();

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        spacing: 24,
        runSpacing: 12,
        children: [
          Text(
            context.tr(
              'shop_footer_rights',
              defaultText: '© {year} Morrow. All rights reserved.',
              args: {'year': DateTime.now().year.toString()},
            ),
            style: const TextStyle(
              color: StoreColors.foregroundMuted,
              fontSize: 12,
            ),
          ),
          const PoweredByDustLink(),
        ],
      );
}

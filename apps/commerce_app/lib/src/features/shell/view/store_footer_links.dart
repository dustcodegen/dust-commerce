import 'dart:async';

import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_app/route.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Dynamic category, collection, and Dust links from the source footer.
class StoreFooterLinks extends StatelessWidget {
  /// Creates the footer navigation columns.
  const StoreFooterLinks({
    required this.categories,
    required this.collections,
    super.key,
  });

  /// Active category hierarchy from the store API.
  final List<ProductCategory> categories;

  /// Active collections from the store API.
  final List<ProductCollection> collections;

  @override
  Widget build(BuildContext context) {
    final roots = categories
        .where((category) => category.parentId == null)
        .take(6)
        .toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) => Wrap(
        spacing: constraints.maxWidth < 768 ? 40 : 64,
        runSpacing: 40,
        children: [
          if (roots.isNotEmpty)
            _FooterColumn(
              title: context.tr(
                'shop_footer_categories',
                defaultText: 'Categories',
              ),
              children: [
                for (final root in roots) ...[
                  FooterTextLink(
                    label: root.name,
                    emphasized: categories.any(
                      (category) => category.parentId == root.id,
                    ),
                    onPressed: () =>
                        context.navigator.category(handle: root.handle).go(),
                  ),
                  for (final child in categories.where(
                    (category) => category.parentId == root.id,
                  ))
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: FooterTextLink(
                        label: child.name,
                        onPressed: () => context.navigator
                            .category(handle: child.handle)
                            .go(),
                      ),
                    ),
                ],
              ],
            ),
          if (collections.isNotEmpty)
            _FooterColumn(
              title: context.tr(
                'shop_footer_collections',
                defaultText: 'Collections',
              ),
              children: [
                for (final collection in collections.take(6))
                  FooterTextLink(
                    label: collection.title,
                    onPressed: () => context.navigator
                        .collection(handle: collection.handle)
                        .go(),
                  ),
              ],
            ),
          _FooterColumn(
            title: 'Dust',
            children: [
              FooterTextLink(
                label: 'GitHub',
                onPressed: () => _open('https://github.com/dustcodegen/dust'),
              ),
              FooterTextLink(
                label: context.tr(
                  'shop_footer_documentation',
                  defaultText: 'Documentation',
                ),
                onPressed: () => _open(
                  'https://github.com/dustcodegen/dust/tree/main/docs',
                ),
              ),
              FooterTextLink(
                label: context.tr(
                  'shop_footer_source_code',
                  defaultText: 'Source code',
                ),
                onPressed: () => _open(
                  'https://github.com/dustcodegen/dust-commerce',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static void _open(String location) {
    unawaited(launchUrl(Uri.parse(location)));
  }
}

class _FooterColumn extends StatelessWidget {
  const _FooterColumn({required this.title, required this.children});

  final List<Widget> children;
  final String title;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: StoreColors.foreground,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            for (final child in children) ...[
              child,
              const SizedBox(height: 8),
            ],
          ],
        ),
      );
}

/// Compact source-style footer link with a full semantic tap target.
class FooterTextLink extends StatelessWidget {
  /// Creates a footer link.
  const FooterTextLink({
    required this.label,
    required this.onPressed,
    this.emphasized = false,
    super.key,
  });

  /// Whether a parent category should use stronger text.
  final bool emphasized;

  /// Visible link label.
  final String label;

  /// Link destination action.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 20),
          alignment: Alignment.centerLeft,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: StoreColors.foregroundSubtle,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        child: Text(label),
      );
}

/// The only platform attribution requested for the Morrow storefront.
class PoweredByDustLink extends StatelessWidget {
  /// Creates the lowercase Dust attribution.
  const PoweredByDustLink({super.key});

  @override
  Widget build(BuildContext context) => FooterTextLink(
        label: context.tr(
          'shop_hero_subtitle',
          defaultText: 'Powered by dust',
        ),
        onPressed: () => StoreFooterLinks._open(
          'https://github.com/dustcodegen/dust',
        ),
      );
}

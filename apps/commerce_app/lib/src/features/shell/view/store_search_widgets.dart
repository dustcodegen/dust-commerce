import 'package:commerce_app/src/core/product_image.dart';
import 'package:commerce_app/src/core/store_theme.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Search result, loading, empty, and error states.
final class StoreSearchBody extends StatelessWidget {
  /// Creates the drawer body.
  const StoreSearchBody({
    required this.failed,
    required this.hits,
    required this.loading,
    required this.query,
    required this.searched,
    required this.onProductSelected,
    super.key,
  });

  /// Whether the last search request failed.
  final bool failed;

  /// Products returned for the current query.
  final List<Product> hits;

  /// Whether the search request is in flight.
  final bool loading;

  /// Opens a selected product handle.
  final ValueChanged<String> onProductSelected;

  /// Current trimmed query.
  final String query;

  /// Whether the customer has typed a query yet.
  final bool searched;

  @override
  Widget build(BuildContext context) {
    if (!searched) {
      return const _StoreSearchMessage(
        child: TranslatedText(
          'shop_search_start',
          defaultText: 'Start typing to search for products.',
        ),
      );
    }
    if (loading) {
      return const _StoreSearchMessage(
        child: TranslatedText(
          'shop_search_loading',
          defaultText: 'Searching…',
        ),
      );
    }
    if (failed) {
      return const _StoreSearchMessage(
        color: StoreColors.danger,
        child: TranslatedText(
          'shop_search_failed',
          defaultText: 'Could not search products.',
        ),
      );
    }
    if (hits.isEmpty) return _StoreSearchEmpty(query: query);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: hits.length,
      itemBuilder: (context, index) => _StoreSearchHit(
        product: hits[index],
        onSelected: onProductSelected,
      ),
    );
  }
}

final class _StoreSearchHit extends StatelessWidget {
  const _StoreSearchHit({required this.product, required this.onSelected});

  final ValueChanged<String> onSelected;
  final Product product;

  @override
  Widget build(BuildContext context) => Semantics(
        link: true,
        label: product.title,
        onTap: () => onSelected(product.handle),
        child: ExcludeSemantics(
          child: InkWell(
            hoverColor: StoreColors.subtleHover,
            onTap: () => onSelected(product.handle),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: ProductImage(
                      url: product.thumbnail,
                      aspectRatio: 7 / 8,
                      border: false,
                      placeholderColor: StoreColors.foregroundMuted,
                      placeholderSize: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: StoreColors.foreground,
                        fontSize: 14,
                        height: 22.4 / 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

final class _StoreSearchEmpty extends StatelessWidget {
  const _StoreSearchEmpty({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Text(
          '${context.tr(
            'shop_search_empty',
            defaultText: 'No products found for',
          )} "$query"',
          textAlign: TextAlign.center,
          style: const TextStyle(color: StoreColors.foregroundSubtle),
        ),
      );
}

final class _StoreSearchMessage extends StatelessWidget {
  const _StoreSearchMessage({
    required this.child,
    this.color = StoreColors.foregroundSubtle,
  });

  final Widget child;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: DefaultTextStyle.merge(
          textAlign: TextAlign.center,
          style: TextStyle(color: color),
          child: child,
        ),
      );
}

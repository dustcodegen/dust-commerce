import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _listingTitleStyle = TextStyle(
  fontSize: 30,
  height: 1.6,
  fontWeight: FontWeight.w600,
);

/// Title, breadcrumb, description, and child links from CategoryTemplate.
class ListingHeader extends StatelessWidget {
  /// Creates listing context above the product grid.
  const ListingHeader({
    required this.state,
    required this.onCategorySelected,
    super.key,
  });

  /// Opens a category using its full handle.
  final ValueChanged<String> onCategorySelected;

  /// Current listing metadata.
  final ProductListingState state;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: [
              for (final parent in state.parents)
                _ParentLink(
                  category: parent,
                  onPressed: onCategorySelected,
                ),
              TranslatedText.dynamic(
                'shop_listing_${state.requestKey}',
                fallback: state.title,
                style: _listingTitleStyle,
              ),
            ],
          ),
          if (state.description.isNotEmpty) ...[
            const SizedBox(height: 32),
            TranslatedText.dynamic(
              'shop_listing_description_${state.requestKey}',
              fallback: state.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (state.children.isNotEmpty) ...[
            const SizedBox(height: 32),
            for (final (index, child) in state.children.indexed) ...[
              StoreInteractiveLink(
                onPressed: () => onCategorySelected(child.handle),
                child: TranslatedText.dynamic(
                  'shop_category_${child.id}',
                  fallback: child.name,
                ),
              ),
              if (index < state.children.length - 1) const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 32),
        ],
      );
}

class _ParentLink extends StatelessWidget {
  const _ParentLink({required this.category, required this.onPressed});

  final ProductCategory category;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => onPressed(category.handle),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              foregroundColor: StoreColors.foregroundSubtle,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: _listingTitleStyle,
            ),
            child: TranslatedText.dynamic(
              'shop_category_${category.id}',
              fallback: category.name,
            ),
          ),
          const SizedBox(width: 16),
          TranslatedText.dynamic(
            'shop_category_separator',
            fallback: '/',
            style: _listingTitleStyle.copyWith(
              color: StoreColors.foregroundSubtle,
            ),
          ),
        ],
      );
}

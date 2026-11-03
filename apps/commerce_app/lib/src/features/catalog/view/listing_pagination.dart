import 'package:commerce_app/src/core/store_theme.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _paginationTextStyle = TextStyle(
  fontSize: 18,
  height: 1.6,
  fontWeight: FontWeight.w500,
);
const _paginationMutedTextStyle = TextStyle(
  color: StoreColors.foregroundMuted,
  fontSize: 18,
  height: 1.6,
  fontWeight: FontWeight.w500,
);

/// One visible entry in the bounded Medusa pagination sequence.
sealed class ListingPaginationItem {
  const ListingPaginationItem();
}

/// A selectable one-based page entry.
final class ListingPage extends ListingPaginationItem {
  /// Creates a page entry.
  const ListingPage(this.page);

  /// One-based destination page.
  final int page;
}

/// A non-interactive gap between distant page ranges.
final class ListingEllipsis extends ListingPaginationItem {
  /// Creates an ellipsis entry.
  const ListingEllipsis();
}

/// Medusa pagination with edge pages and bounded ellipses.
class ListingPagination extends StatelessWidget {
  /// Creates a one-based pagination control.
  const ListingPagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.search = false,
    super.key,
  });

  /// Current one-based page.
  final int currentPage;

  /// Receives a selected one-based page.
  final ValueChanged<int> onPageChanged;

  /// Whether this control follows StoreHits search pagination.
  final bool search;

  /// Last one-based page.
  final int totalPages;

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 12,
        children: [
          for (final item in listingPaginationItems(
            currentPage,
            totalPages,
            search: search,
          ))
            switch (item) {
              ListingEllipsis() => const _PaginationEllipsis(),
              ListingPage(:final page) => _PaginationPageButton(
                  page: page,
                  current: page == currentPage,
                  onPressed: () => onPageChanged(page),
                ),
            },
        ],
      );
}

/// Builds the exact bounded page sequence used by the pinned Medusa source.
List<ListingPaginationItem> listingPaginationItems(
  int page,
  int total, {
  bool search = false,
}) {
  if (search) return searchListingPaginationItems(page, total);
  ListingPage item(int value) => ListingPage(value);
  if (total <= 7) {
    return [for (var value = 1; value <= total; value++) item(value)];
  }
  if (page <= 4) {
    return [
      for (var value = 1; value <= 5; value++) item(value),
      const ListingEllipsis(),
      item(total),
    ];
  }
  if (page >= total - 3) {
    return [
      item(1),
      const ListingEllipsis(),
      for (var value = total - 4; value <= total; value++) item(value),
    ];
  }
  return [
    item(1),
    const ListingEllipsis(),
    for (var value = page - 1; value <= page + 1; value++) item(value),
    const ListingEllipsis(),
    item(total),
  ];
}

/// Builds the current StoreHits pagination window from source padding 2.
List<ListingPaginationItem> searchListingPaginationItems(int page, int total) {
  if (total < 1) return const [];
  ListingPage item(int value) => ListingPage(value);
  final current = (page - 1).clamp(0, total - 1);
  final start = (current - 2).clamp(0, total - 1);
  final end = (current + 2).clamp(0, total - 1);
  final pages = [for (var value = start; value <= end; value++) value];
  return [
    if (!pages.contains(0)) item(1),
    if (!pages.contains(0) && !pages.contains(1)) const ListingEllipsis(),
    for (final value in pages) item(value + 1),
    if (!pages.contains(total - 1) && !pages.contains(total - 2))
      const ListingEllipsis(),
    if (!pages.contains(total - 1)) item(total),
  ];
}

final class _PaginationPageButton extends StatelessWidget {
  const _PaginationPageButton({
    required this.page,
    required this.current,
    required this.onPressed,
  });

  final bool current;
  final VoidCallback onPressed;
  final int page;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: current ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: StoreColors.foregroundMuted,
          disabledForegroundColor: StoreColors.foreground,
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: _paginationTextStyle,
        ),
        child: TranslatedText.dynamic(
          'shop_page_$page',
          fallback: '$page',
        ),
      );
}

final class _PaginationEllipsis extends StatelessWidget {
  const _PaginationEllipsis();

  @override
  Widget build(BuildContext context) => const TranslatedText(
        'shop_pagination_ellipsis',
        defaultText: '...',
        style: _paginationMutedTextStyle,
      );
}

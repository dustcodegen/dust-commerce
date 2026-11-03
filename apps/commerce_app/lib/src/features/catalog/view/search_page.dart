import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'listing_grid.dart';
import 'listing_search_box.dart';

/// Search results route translated from Medusa's dedicated SearchPage.
@AppRoute('/search', name: 'search', guards: [])
final class SearchPage extends StatefulWidget {
  /// Creates the source-compatible search route.
  const SearchPage({this.page = 1, this.q = '', super.key});

  /// One-based search result page.
  final int page;

  /// Bounded free-text product query.
  final String q;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

final class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    _loadAfterFrame();
  }

  @override
  void didUpdateWidget(SearchPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.q != widget.q || oldWidget.page != widget.page) {
      _loadAfterFrame();
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = normalizedSearchQuery(widget.q);
    final page = widget.page < 1 ? 1 : widget.page;
    final currency = context.watchStoreShellViewModel().value.currencyCode;
    final requestKey = listingRequestKey(
      'store',
      '',
      page,
      'relevance',
      const [],
      const [],
      const [],
      currency,
      query,
    );
    final state = context.watchProductListingViewModel().value;
    if (query.isNotEmpty &&
        (state.requestKey != requestKey ||
            state.status == ProductListingStatus.idle ||
            state.status == ProductListingStatus.loading)) {
      return const StoreScaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (query.isNotEmpty && state.status == ProductListingStatus.failed) {
      return StoreScaffold(
        body: Center(
          child: Text(
            context.tr(
              'shop_search_failed',
              defaultText: 'Could not search products.',
            ),
            style: TextStyle(color: StoreColors.danger),
          ),
        ),
      );
    }
    return StoreScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        query.isEmpty
                            ? context.tr(
                                'shop_search_title',
                                defaultText: 'Search',
                              )
                            : context.tr(
                                'shop_search_results_for',
                                defaultText: 'Search results for "$query"',
                                args: {'query': query},
                              ),
                        style: const TextStyle(
                          fontSize: 30,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListingSearchBox(
                        query: query,
                        onChanged: (value) => context.navigator
                            .search(q: normalizedSearchQuery(value))
                            .go(),
                      ),
                      if (query.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            context.tr(
                              'shop_search_start',
                              defaultText:
                                  'Start typing to search for products.',
                            ),
                            style: TextStyle(
                              color: StoreColors.foregroundMuted,
                            ),
                          ),
                        )
                      else if (state.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: TranslatedText(
                            'shop_search_no_match',
                            defaultText:
                                'No products match your search. Try a different keyword.',
                            style: TextStyle(
                              color: StoreColors.foregroundSubtle,
                            ),
                          ),
                        )
                      else
                        ListingGrid(
                          products: state.products,
                          currencyCode: state.currencyCode,
                          currentPage: state.currentPage,
                          totalPages: state.totalPages,
                          searchPagination: true,
                          onPageChanged: (value) => context.navigator
                              .search(q: query, page: value)
                              .go(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const StoreFooter(),
          ],
        ),
      ),
    );
  }

  void _loadAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final query = normalizedSearchQuery(widget.q);
      if (query.isEmpty) return;
      final shell = context.watchStoreShellViewModel().value;
      context.readProductListingViewModel().loadStore(
            page: widget.page < 1 ? 1 : widget.page,
            query: query,
            sortBy: 'relevance',
            currency: shell.currencyCode,
          );
    });
  }
}

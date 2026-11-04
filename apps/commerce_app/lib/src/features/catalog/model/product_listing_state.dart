import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'product_listing_state.g.dart';

/// Lifecycle of a source-shaped product listing route.
enum ProductListingStatus {
  /// No route has requested data yet.
  idle,

  /// Taxonomy and products are being resolved.
  loading,

  /// The requested listing is ready, including a valid empty result.
  ready,

  /// The collection or category handle does not exist.
  missing,

  /// A dependency failed without exposing its internal error to the customer.
  failed,
}

/// One category facet in the Store refinement sidebar.
@Derive([ToString(), Eq()])
final class ProductCategoryFilter with _$ProductCategoryFilter {
  /// Creates a category facet from product response categories.
  const ProductCategoryFilter({
    required this.handle,
    required this.name,
    required this.count,
  });

  /// Number of currently matching products in this category.
  final int count;

  /// Stable category handle sent as the repeated `category` query.
  final String handle;

  /// Customer-facing category label.
  final String name;
}

/// One product-label facet in the Store refinement sidebar.
@Derive([ToString(), Eq()])
final class ProductLabelFilter with _$ProductLabelFilter {
  /// Creates a label facet from product response tags.
  const ProductLabelFilter({
    required this.value,
    required this.count,
  });

  /// Number of currently matching products with this label.
  final int count;

  /// Customer-facing tag value sent as the repeated `labels` query.
  final String value;
}

/// Minor-unit bounds for the Store price refinement.
@Derive([ToString(), Eq()])
final class ProductPriceBounds with _$ProductPriceBounds {
  /// Creates a price-range facet from matching product prices.
  const ProductPriceBounds({required this.min, required this.max});

  /// Highest cheapest-product price in the current currency.
  final int max;

  /// Lowest cheapest-product price in the current currency.
  final int min;

  /// Whether the bounds can render a useful slider.
  bool get canRefine => min < max;
}

/// Complete render state for store, collection, and category listings.
@Derive([ToString(), Eq(), CopyWith()])
final class ProductListingState with _$ProductListingState {
  /// Creates an immutable listing state.
  const ProductListingState({
    this.status = ProductListingStatus.idle,
    this.requestKey = '',
    this.title = '',
    this.description = '',
    this.parents = const [],
    this.children = const [],
    this.categoryFilters = const [],
    this.labelFilters = const [],
    this.optionFilters = const [],
    this.priceBounds = const None(),
    this.canRefineOnSale = false,
    this.onSaleCount = 0,
    this.selectedCategoryHandles = const [],
    this.selectedLabelValues = const [],
    this.selectedMaxPrice = const None(),
    this.selectedMinPrice = const None(),
    this.selectedOnSale = false,
    this.selectedOptionValueIds = const [],
    this.searchQuery = '',
    this.products = const [],
    this.sortBy = 'created_at',
    this.currentPage = 1,
    this.totalPages = 0,
    this.currencyCode = 'usd',
  });

  /// Direct child categories shown above a category's product grid.
  final List<ProductCategory> children;

  /// Store-only category refinements discovered from matching products.
  final List<ProductCategoryFilter> categoryFilters;

  /// Whether the current Store result set contains any sale-priced products.
  final bool canRefineOnSale;

  /// Number of currently matching sale-priced products.
  final int onSaleCount;

  /// Store-only label refinements discovered from matching products.
  final List<ProductLabelFilter> labelFilters;

  /// One-based page rendered by this state.
  final int currentPage;

  /// Currency used for product prices.
  final String currencyCode;

  /// Customer-facing category copy, empty when the source has none.
  final String description;

  /// Root-to-leaf ancestors rendered as category breadcrumbs.
  final List<ProductCategory> parents;

  /// Store-only refinement axes; empty on routes that hide the picker.
  final List<ProductOptionFilterView> optionFilters;

  /// Store-only price bounds discovered from matching products.
  final Option<ProductPriceBounds> priceBounds;

  /// Products on the requested page.
  final List<Product> products;

  /// Identifies the route/query combination that owns this state.
  final String requestKey;

  /// Stable option-value identifiers active in the browser query.
  final List<String> selectedOptionValueIds;

  /// Stable category handles active in the Store browser query.
  final List<String> selectedCategoryHandles;

  /// Stable label values active in the Store browser query.
  final List<String> selectedLabelValues;

  /// Active upper price bound in minor units.
  final Option<int> selectedMaxPrice;

  /// Active lower price bound in minor units.
  final Option<int> selectedMinPrice;

  /// Whether the Store route is narrowed to sale-priced products.
  final bool selectedOnSale;

  /// Free-text product search retained in the Store route query.
  final String searchQuery;

  /// Medusa-compatible sort query value.
  final String sortBy;

  /// Current request lifecycle.
  final ProductListingStatus status;

  /// Customer-facing collection/category/store title.
  final String title;

  /// Number of pages available at the source limit of twelve.
  final int totalPages;

  /// Whether a completed listing contains no products.
  bool get isEmpty => status == ProductListingStatus.ready && products.isEmpty;
}

import 'package:dust_dart/serde.dart';

import 'featured_product_rail.dart';

part 'catalog_state.g.dart';

/// Where the catalogue screen is in its loading lifecycle.
enum CatalogStatus {
  /// Nothing fetched yet.
  idle,

  /// A request is in flight.
  loading,

  /// Products arrived.
  ready,

  /// The request failed.
  failed,
}

/// Everything the catalogue screen renders.
///
/// The screen holds no state of its own. A widget that keeps something across
/// a frame is a second source of truth, and the two drift.
@Derive([ToString(), Eq(), CopyWith()])
final class CatalogState with _$CatalogState {
  /// Creates a [CatalogState].
  const CatalogState({
    this.status = CatalogStatus.idle,
    this.rails = const [],
    this.currencyCode = 'usd',
  });

  /// The currency prices are shown in.
  final String currencyCode;

  /// Source-ordered collection rails shown below the hero.
  final List<FeaturedProductRail> rails;

  /// Where the screen is in its lifecycle.
  final CatalogStatus status;

  /// Whether the screen has nothing to show and is not waiting.
  bool get isEmpty =>
      status == CatalogStatus.ready &&
      rails.every((rail) => rail.products.isEmpty);

  /// Whether a spinner belongs on screen.
  bool get isLoading => status == CatalogStatus.loading;
}

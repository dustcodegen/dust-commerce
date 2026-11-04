import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'store_shell_state.g.dart';

/// Loading lifecycle for taxonomy shared by the storefront shell.
enum StoreShellStatus {
  /// The shell has not requested its navigation data yet.
  idle,

  /// Collections and categories are loading concurrently.
  loading,

  /// Discovery finished; either list may legitimately be empty.
  ready,
}

/// Public taxonomy rendered by the shared Medusa-shaped footer.
@Derive([ToString(), Eq(), CopyWith()])
final class StoreShellState with _$StoreShellState {
  /// Creates immutable shell state.
  const StoreShellState({
    this.status = StoreShellStatus.idle,
    this.categories = const [],
    this.collections = const [],
    this.regions = const [],
    this.supportedLocales = const [],
    this.selectedCountryCode = const None(),
    this.selectedLocaleCode = const None(),
  });

  /// Active public category nodes, including direct children.
  final List<ProductCategory> categories;

  /// Active public collections in server display order.
  final List<ProductCollection> collections;

  /// Active selling regions used by the source-shaped country selector.
  final List<Region> regions;

  /// Selected ISO country code, absent when region discovery failed.
  final Option<String> selectedCountryCode;

  /// Explicit language choice, absent when the app default should be used.
  final Option<String> selectedLocaleCode;

  /// Locale codes compiled into the Dust i18n bundles.
  final List<String> supportedLocales;

  /// Current shared-navigation lifecycle.
  final StoreShellStatus status;

  /// Selling region that serves the selected country.
  Option<Region> get selectedRegion {
    for (final region in regions) {
      if (selectedCountryCode.match(
        some: region.serves,
        none: () => false,
      )) {
        return Some(region);
      }
    }
    return const None();
  }

  /// Currency used by product requests until a region is available.
  String get currencyCode => selectedRegion.match(
        some: (region) => region.currencyCode,
        none: () => 'usd',
      );

  /// Resolves the explicit language or [fallback] for the default option.
  String localeOr(String fallback) => selectedLocaleCode.match(
        some: (locale) => locale,
        none: () => fallback,
      );

  /// Finds the region serving [countryCode].
  Option<Region> regionForCountry(String countryCode) {
    for (final region in regions) {
      if (region.serves(countryCode)) return Some(region);
    }
    return const None();
  }
}

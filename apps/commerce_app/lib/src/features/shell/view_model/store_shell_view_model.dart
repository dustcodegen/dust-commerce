import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/core/storage/storage.dart';
import 'package:commerce_app/src/features/shell/model/store_shell_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/state.dart';

part 'store_shell_view_model.g.dart';

/// Dependencies for taxonomy shared by every main-store route.
final class StoreShellViewModelArgs extends ViewModelArgs {
  /// Creates shell dependencies.
  const StoreShellViewModelArgs({
    required this.api,
    required this.countries,
    required this.locales,
    required this.supportedLocales,
    super.observer,
  });

  /// Store API used for public navigation discovery.
  final CommerceApi api;

  /// Persisted storefront-country preference.
  final CountryPreferenceStore countries;

  /// Persisted storefront-language preference.
  final LocalePreferenceStore locales;

  /// Locale codes available in the generated Dust bundles.
  final List<String> supportedLocales;
}

/// Loads the footer taxonomy once without making page content depend on it.
@ViewModel(state: StoreShellState, args: StoreShellViewModelArgs)
class StoreShellViewModel extends $StoreShellViewModel {
  /// Creates the shared shell state machine.
  StoreShellViewModel(super.args);

  /// Loads independent collection and category inventories concurrently.
  Future<void> load() async {
    if (state.status == StoreShellStatus.loading) return;
    emit(state.copyWith(status: StoreShellStatus.loading));
    final collections = _collections();
    final categories = _categories();
    final regions = _regions();
    final preferred = _preferredCountry();
    final preferredLocale = _preferredLocale();
    final loadedRegions = await regions;
    emit(StoreShellState(
      status: StoreShellStatus.ready,
      collections: await collections,
      categories: await categories,
      regions: loadedRegions,
      supportedLocales: args.supportedLocales,
      selectedCountryCode: _initialCountry(
        loadedRegions,
        await preferred,
      ),
      selectedLocaleCode: _initialLocale(
        args.supportedLocales,
        await preferredLocale,
      ),
    ));
  }

  /// Selects and persists a country served by an active region.
  Future<bool> selectCountry(String countryCode) async {
    final normalized = countryCode.trim().toLowerCase();
    if (state.regionForCountry(normalized) case None()) return false;
    emit(state.copyWith(selectedCountryCode: Some(normalized)));
    try {
      await args.countries.write(normalized);
    } on Object {
      // A storage outage must not undo a successful cart and UI transition.
    }
    return true;
  }

  /// Selects a supported locale, or clears it to use the app default.
  Future<bool> selectLocale(Option<String> localeCode) async {
    final normalized = localeCode.match<Option<String>>(
      some: (locale) => Some(locale.trim().toLowerCase()),
      none: () => const None(),
    );
    if (normalized case Some(value: final locale)
        when !args.supportedLocales.contains(locale)) {
      return false;
    }
    emit(state.copyWith(selectedLocaleCode: normalized));
    try {
      await normalized.match(
        some: args.locales.write,
        none: args.locales.clear,
      );
    } on Object {
      // Language remains usable for this session when persistence is down.
    }
    return true;
  }

  /// Searches published products for the shared navigation drawer.
  Future<ProductPageView> searchProducts(
    String query, {
    required String currencyCode,
  }) =>
      args.api.products(
        currency: currencyCode,
        query: query.trim(),
        limit: 12,
      );

  Future<List<ProductCollection>> _collections() async {
    try {
      return (await args.api.collections(limit: 100)).collections;
    } on Exception {
      // Footer discovery never replaces working page content with an error.
      return const [];
    }
  }

  Future<List<ProductCategory>> _categories() async {
    try {
      return (await args.api.categories(limit: 100)).categories;
    } on Exception {
      // Each column fails independently, matching the optional source blocks.
      return const [];
    }
  }

  Future<List<Region>> _regions() async {
    try {
      return (await args.api.regions()).regions;
    } on Exception {
      return const [];
    }
  }

  Future<Option<String>> _preferredCountry() async {
    try {
      return await args.countries.read();
    } on Object {
      return const None();
    }
  }

  Future<Option<String>> _preferredLocale() async {
    try {
      return await args.locales.read();
    } on Object {
      return const None();
    }
  }

  static Option<String> _initialCountry(
    List<Region> regions,
    Option<String> preferred,
  ) {
    final saved = preferred.match(
      some: (country) => country,
      none: () => '',
    );
    if (saved.isNotEmpty && regions.any((region) => region.serves(saved))) {
      return Some(saved);
    }
    if (regions.any((region) => region.serves('dk'))) {
      return const Some('dk');
    }
    for (final region in regions) {
      if (region.countries.isNotEmpty) return Some(region.countries.first);
    }
    return const None();
  }

  static Option<String> _initialLocale(
    List<String> supportedLocales,
    Option<String> preferred,
  ) =>
      preferred.match(
        some: (locale) =>
            supportedLocales.contains(locale) ? Some(locale) : const None(),
        none: () => const None(),
      );
}

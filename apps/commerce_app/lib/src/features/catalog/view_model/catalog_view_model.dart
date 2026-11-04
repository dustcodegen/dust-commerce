import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/catalog/model/catalog_state.dart';
import 'package:commerce_app/src/features/catalog/model/featured_product_rail.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/state.dart';

part 'catalog_view_model.g.dart';

/// What the catalogue view model needs to do its job.
///
/// Dependencies arrive as typed args rather than being reached for. A view
/// model that constructs its own API client cannot be tested against a
/// different one.
final class CatalogViewModelArgs extends ViewModelArgs {
  /// Creates a [CatalogViewModelArgs].
  const CatalogViewModelArgs({required this.api, super.observer});

  /// The storefront API.
  final CommerceApi api;
}

/// Drives the catalogue screen.
///
/// Every transition it can make is a method here, and the screen only calls
/// them. Nothing about Flutter appears in this file — no widgets, no context —
/// which is what makes the state machine testable without pumping a frame.
@ViewModel(state: CatalogState, args: CatalogViewModelArgs)
class CatalogViewModel extends $CatalogViewModel {
  /// Creates a [CatalogViewModel].
  CatalogViewModel(super.args);

  /// Loads the first page of the catalogue.
  ///
  /// A failure sets [CatalogStatus.failed] rather than throwing into the view.
  /// A screen cannot render an exception, and a storefront that shows a blank
  /// page when the network drops has lost the customer either way.
  Future<void> load({String? currency}) async {
    final wanted = currency ?? state.currencyCode;
    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        currencyCode: wanted,
      ),
    );

    try {
      final collections = await args.api.collections(limit: 100);
      final rails = await Future.wait([
        for (final collection in collections.collections)
          _loadRail(collection, wanted),
      ]);
      emit(
        state.copyWith(
          status: CatalogStatus.ready,
          rails: rails,
        ),
      );
    } on Object {
      emit(
        state.copyWith(
          status: CatalogStatus.failed,
        ),
      );
    }
  }

  /// Reloads the catalogue in [currency].
  Future<void> changeCurrency(String currency) => load(currency: currency);

  Future<FeaturedProductRail> _loadRail(
    ProductCollection collection,
    String currency,
  ) async {
    final page = await args.api.products(
      currency: currency,
      collection: collection.handle,
      limit: 12,
    );
    return FeaturedProductRail(
      collection: collection,
      products: page.products,
    );
  }
}

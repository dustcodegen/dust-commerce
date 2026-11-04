import 'package:commerce_app/src/core/api/api.dart';
import 'package:commerce_app/src/features/product/model/product_state.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dio/dio.dart';
import 'package:dust_flutter/state.dart';

part 'product_view_model.g.dart';

/// Dependencies for product details.
final class ProductViewModelArgs extends ViewModelArgs {
  /// Creates product dependencies.
  const ProductViewModelArgs({required this.api, super.observer});

  /// The generated storefront client.
  final CommerceApi api;
}

/// Loads a product and resolves its selected option combination.
@ViewModel(state: ProductDetailState, args: ProductViewModelArgs)
class ProductViewModel extends $ProductViewModel {
  /// Creates the product view model.
  ProductViewModel(super.args);

  var _revision = 0;

  /// Loads the product addressed by [handle].
  Future<void> load(
    String handle, {
    String currency = 'usd',
    String? variantId,
  }) async {
    final revision = ++_revision;
    final currentSelection =
        state.product?.handle == handle && variantId == null
            ? state.selection
            : const <String, String>{};
    emit(
      ProductDetailState(
        status: ProductDetailStatus.loading,
        currencyCode: currency,
      ),
    );
    try {
      final product = await args.api.product(handle, currency: currency);
      if (revision != _revision) return;
      emit(
        ProductDetailState(
          status: ProductDetailStatus.ready,
          relatedStatus: RelatedProductsStatus.loading,
          product: product,
          currencyCode: currency,
          selection: product.variantById(variantId ?? '')?.optionValues ??
              currentSelection,
        ),
      );
      await _loadRelated(product, currency, revision);
    } on Object catch (error) {
      if (revision != _revision) return;
      final missing =
          error is DioException && error.response?.statusCode == 404;
      emit(
        missing
            ? ProductDetailState(
                status: ProductDetailStatus.missing,
                currencyCode: currency,
              )
            : ProductDetailState(
                status: ProductDetailStatus.failed,
                currencyCode: currency,
                message: 'Could not load this product. Please try again.',
              ),
      );
    }
  }

  /// Selects one value for a product option.
  void select(String optionId, String value) {
    if (!state.canSelect(optionId, value)) return;
    emit(state.copyWith(selection: {...state.selection, optionId: value}));
  }

  /// Retries recommendations without disrupting the usable main product.
  Future<void> loadRelated() async {
    final product = state.product;
    if (product == null) return;
    final revision = _revision;
    emit(
      state.copyWith(
        relatedStatus: RelatedProductsStatus.loading,
        relatedMessage: null,
      ),
    );
    await _loadRelated(product, state.currencyCode, revision);
  }

  Future<void> _loadRelated(
    Product product,
    String currency,
    int revision,
  ) async {
    try {
      final page = await args.api.products(currency: currency, limit: 5);
      if (revision != _revision) return;
      final related = page.products
          .where((candidate) => candidate.id != product.id)
          .take(4)
          .toList(growable: false);
      emit(
        state.copyWith(
          relatedStatus: RelatedProductsStatus.ready,
          relatedProducts: related,
          relatedMessage: null,
        ),
      );
    } on Object {
      if (revision != _revision) return;
      emit(
        state.copyWith(
          relatedStatus: RelatedProductsStatus.failed,
          relatedProducts: const [],
          relatedMessage: 'Could not load related products.',
        ),
      );
    }
  }
}

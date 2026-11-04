import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'product_state.g.dart';

/// The product request currently visible to the detail route.
enum ProductDetailStatus {
  /// No product request has started.
  idle,

  /// A product request is in flight.
  loading,

  /// The product is ready to render.
  ready,

  /// No published product exists at the requested handle.
  missing,

  /// The product request failed.
  failed,
}

/// Independent lifecycle for source-matched related-product discovery.
enum RelatedProductsStatus {
  /// No related request belongs to the current product yet.
  idle,

  /// Related products are being fetched.
  loading,

  /// Related products arrived, including a valid empty result.
  ready,

  /// The main product remains usable but recommendations failed.
  failed,
}

/// Product data and the option values selected by the customer.
@Derive([ToString(), Eq(), CopyWith()])
class ProductDetailState with _$ProductDetailState {
  /// Creates product detail state.
  const ProductDetailState({
    this.status = ProductDetailStatus.idle,
    this.relatedStatus = RelatedProductsStatus.idle,
    this.selection = const {},
    this.relatedProducts = const [],
    this.currencyCode = 'usd',
    this.product,
    this.message,
    this.relatedMessage,
  });

  /// Currency used for price labels throughout this product route.
  final String currencyCode;

  /// A display-safe request failure.
  final String? message;

  /// The product returned by the server.
  final Product? product;

  /// Published products suggested after the main product section.
  final List<Product> relatedProducts;

  /// Display-safe recommendation failure, independent from [message].
  final String? relatedMessage;

  /// Recommendation request lifecycle.
  final RelatedProductsStatus relatedStatus;

  /// Selected value keyed by product-option id.
  final Map<String, String> selection;

  /// The request lifecycle.
  final ProductDetailStatus status;

  /// The exact purchasable variant selected by all required options.
  ProductVariant? get selectedVariant {
    final current = product;
    if (current == null || current.variants.isEmpty) return null;
    if (current.variants.length == 1) return current.variants.single;
    if (selection.length != current.options.length) return null;
    return current.variantFor(selection);
  }

  /// Whether [value] is offered by the addressed product option.
  ///
  /// Medusa keeps every offered value selectable. A complete combination that
  /// has no matching variant is represented by [selectedVariant] being null.
  bool canSelect(String optionId, String value) {
    final current = product;
    if (current == null) return false;
    for (final option in current.options) {
      if (option.id == optionId) return option.offers(value);
    }
    return false;
  }
}

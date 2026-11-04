import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';

/// Store client that isolates recommendation failure from product loading.
final class RelatedFailureApi implements CommerceApi {
  /// Creates a recommendation-failing wrapper around [delegate].
  const RelatedFailureApi(this.delegate);

  /// Client used for the working product request.
  final CommerceApi delegate;

  @override
  Future<Product> product(String handle, {String? currency}) =>
      delegate.product(handle, currency: currency);

  @override
  Future<ProductPageView> products({
    String? currency,
    String? query,
    String? sortBy,
    String? collection,
    List<String> categoryHandles = const [],
    List<String> labels = const [],
    String? tag,
    int? minPrice,
    int? maxPrice,
    String? onSale,
    List<String> optionValueIds = const [],
    int? limit,
    int? offset,
  }) =>
      Future.error(StateError('recommendations unavailable'));

  @override
  Object? noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('unused API method');
}

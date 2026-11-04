import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/serde.dart';

part 'featured_product_rail.g.dart';

/// One source home rail: collection identity plus its priced products.
@Derive([ToString(), Eq()])
final class FeaturedProductRail with _$FeaturedProductRail {
  /// Creates an immutable collection rail.
  const FeaturedProductRail({
    required this.collection,
    required this.products,
  });

  /// Collection linked by the rail heading.
  final ProductCollection collection;

  /// Published products priced for the current storefront currency.
  final List<Product> products;
}

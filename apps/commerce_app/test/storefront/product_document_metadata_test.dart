import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('product metadata follows the source route contract', () {
    final product = Product.of(
      id: 'prod_1',
      title: 'T-Shirt',
      handle: 't-shirt',
      status: ProductStatus.published,
      description: '  A heavyweight cotton tee.  ',
      thumbnail: 'https://cdn.test/t-shirt.png',
    );

    final metadata = StoreDocumentMetadata.forProduct(
      product,
      Uri.parse('https://shop.test/dk/products/t-shirt?v_id=var_1#details'),
    );

    expect(metadata.title, 'T-Shirt | Morrow');
    expect(metadata.description, 'A heavyweight cotton tee.');
    expect(metadata.imageUrl, 'https://cdn.test/t-shirt.png');
    expect(metadata.canonicalUrl, 'https://shop.test/dk/products/t-shirt');
  });

  test('empty product descriptions fall back to the product title', () {
    final product = Product.of(
      id: 'prod_1',
      title: 'T-Shirt',
      handle: 't-shirt',
      status: ProductStatus.published,
      description: '   ',
    );

    expect(
      StoreDocumentMetadata.forProduct(product, Uri.base).description,
      'T-Shirt',
    );
  });
}

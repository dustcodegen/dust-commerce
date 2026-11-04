part of 'product_listing_view_model.dart';

extension on ProductListingViewModel {
  int _begin(_ListingMeta meta) {
    final revision = ++_revision;
    _setState(meta.toState(status: ProductListingStatus.loading));
    return revision;
  }

  bool _active(int revision) => revision == _revision;

  void _missing(_ListingMeta meta) =>
      _setState(meta.toState(status: ProductListingStatus.missing));

  void _fail(_ListingMeta meta, int revision) {
    if (!_active(revision)) return;
    _setState(meta.toState(status: ProductListingStatus.failed));
  }
}

List<ProductCategory> _parentsOf(
  ProductCategory category,
  List<ProductCategory> categories,
) {
  final byId = {for (final item in categories) item.id: item};
  final seen = <String>{category.id};
  final parents = <ProductCategory>[];
  var parentId = category.parentId;
  while (parentId != null && seen.add(parentId)) {
    final parent = byId[parentId];
    if (parent == null) break;
    parents.add(parent);
    parentId = parent.parentId;
  }
  return parents.reversed.toList(growable: false);
}

import 'package:commerce_shared/src/region.dart';
import 'package:dust_dart/serde.dart';

part 'region_view.g.dart';

/// Public active selling regions used by country selectors.
@Derive([ToString(), Eq(), Serialize(), Deserialize()])
@SerDe(renameAll: SerDeRename.snakeCase)
final class SellingRegionListView with _$SellingRegionListView {
  /// Creates a complete region listing.
  const SellingRegionListView({required this.regions, required this.count});

  /// Decodes a region listing returned by the store API.
  factory SellingRegionListView.fromJson(Map<String, Object?> json) =>
      _$SellingRegionListViewFromJson(json);

  /// Number of active regions returned.
  final int count;

  /// Public selling regions in stable display order.
  final List<Region> regions;
}

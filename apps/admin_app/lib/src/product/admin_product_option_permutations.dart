/// One option axis used to generate sellable product combinations.
typedef ProductOptionAxis = ({String title, List<String> values});

/// Trims, removes empty entries, and keeps the merchant's first value order.
List<String> parseProductOptionValues(String input) {
  final seen = <String>{};
  return [
    for (final part in input.split(','))
      if (part.trim().isNotEmpty && seen.add(part.trim())) part.trim(),
  ];
}

/// Builds the same left-to-right Cartesian product used by Medusa Admin.
List<Map<String, String>> buildProductOptionPermutations(
  List<ProductOptionAxis> axes,
) {
  final complete = [
    for (final axis in axes)
      if (axis.title.isNotEmpty && axis.values.isNotEmpty) axis,
  ];
  if (complete.isEmpty) return const [];
  return _permutations(complete);
}

List<Map<String, String>> _permutations(List<ProductOptionAxis> axes) {
  final first = axes.first;
  if (axes.length == 1) {
    return [
      for (final value in first.values) {first.title: value},
    ];
  }
  final rest = _permutations(axes.sublist(1));
  return [
    for (final value in first.values)
      for (final permutation in rest) {first.title: value, ...permutation},
  ];
}

/// Produces Medusa's default visible title for one generated combination.
String productOptionPermutationTitle(Map<String, String> permutation) =>
    permutation.values.join(' / ');

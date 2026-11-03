import 'dart:convert';

import 'package:commerce_shared/commerce_shared.dart';

const _maxBuyQuantity = 100;
final _itemPattern =
    RegExp(r'^([A-Za-z0-9._-]+|~[A-Za-z0-9_-]+):([1-9][0-9]*)$');

/// Parses Medusa's `/buy/{variant}:{quantity},...` permalink payload.
List<AddLineBody>? parseBuyItems(String raw) {
  try {
    final pairs = Uri.decodeComponent(raw).split(',');
    if (pairs.isEmpty) return null;
    final items = <AddLineBody>[];
    for (final pair in pairs) {
      final match = _itemPattern.firstMatch(pair);
      if (match == null) return null;
      final quantity = int.parse(match.group(2)!);
      if (quantity > _maxBuyQuantity) return null;
      final encodedId = match.group(1)!;
      final variantId = encodedId.startsWith('~')
          ? utf8.decode(
              base64Url.decode(base64Url.normalize(encodedId.substring(1))),
            )
          : encodedId;
      if (variantId.isEmpty) return null;
      items.add(AddLineBody(variantId: variantId, quantity: quantity));
    }
    return items;
  } on FormatException {
    return null;
  }
}

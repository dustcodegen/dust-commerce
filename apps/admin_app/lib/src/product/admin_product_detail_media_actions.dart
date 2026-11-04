import 'dart:async';

import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:admin_app/src/product/admin_product_image_variants_drawer.dart';
import 'package:admin_app/src/product/admin_product_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Explains a detail action whose backend slice is not implemented yet.
void showAdminUnavailable(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This action needs the next Admin API slice.'),
      ),
    );

/// Opens image associations and reports a successful saved result.
Future<bool> manageAdminProductImageVariants(
  BuildContext context,
  AdminProductDetail product,
  AdminProductImage image,
) async {
  final saved = await showAdminProductImageVariantsDrawer(
    context,
    product,
    image,
  );
  if (saved != true || !context.mounted) return false;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Associated variants updated.')),
  );
  return true;
}

/// Removes selected images and chooses a valid remaining thumbnail.
Future<bool> deleteAdminProductMedia(
  BuildContext context,
  AdminProductDetail product,
  Set<String> imageIds,
) async {
  final remaining = product.images
      .where((image) => !imageIds.contains(image.id))
      .toList(growable: false);
  final thumbnail = remaining.any((image) => image.url == product.thumbnail)
      ? product.thumbnail
      : remaining.firstOrNull?.url;
  final saved = await context.readAdminProductDetailViewModel().updateMedia(
        product.id,
        AdminUpdateProductMedia(media: [
          for (final image in remaining)
            AdminCreateProductMedia(
              id: image.id,
              url: image.url,
              isThumbnail: image.url == thumbnail,
            ),
        ]),
      );
  if (!saved || !context.mounted) return false;
  unawaited(context.readAdminProductViewModel().load());
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Product media updated.')),
  );
  return true;
}

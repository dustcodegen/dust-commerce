import 'package:commerce_app/src/core/store_document_metadata.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/widgets.dart';

/// Keeps browser metadata in sync with the product currently addressed.
class ProductDocumentMetadata extends StatefulWidget {
  /// Creates the route metadata synchronizer.
  const ProductDocumentMetadata({
    required this.product,
    required this.currencyCode,
    super.key,
  });

  /// Loaded product, or null while the route is loading or missing.
  final Product? product;

  /// Currency selected for the product route.
  final String currencyCode;

  @override
  State<ProductDocumentMetadata> createState() =>
      _ProductDocumentMetadataState();
}

class _ProductDocumentMetadataState extends State<ProductDocumentMetadata> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(ProductDocumentMetadata oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product != widget.product ||
        oldWidget.currencyCode != widget.currencyCode) {
      _sync();
    }
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void dispose() {
    resetStoreDocumentMetadata();
    super.dispose();
  }

  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final product = widget.product;
      if (product == null) {
        resetStoreDocumentMetadata();
      } else {
        applyStoreDocumentMetadata(
          StoreDocumentMetadata.forProduct(
            product,
            Uri.base,
            currencyCode: widget.currencyCode,
          ),
        );
      }
    });
  }
}

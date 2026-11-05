import 'package:commerce_app/src/core/store_document_metadata.dart';
import 'package:commerce_app/src/core/store_home_structured_data.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:flutter/widgets.dart';

/// Keeps home-route JSON-LD aligned with the loaded public regions.
final class HomeDocumentMetadata extends StatefulWidget {
  /// Creates the home metadata synchronizer.
  const HomeDocumentMetadata({required this.regions, super.key});

  /// Public regions whose validated policies may be published.
  final List<Region> regions;

  @override
  State<HomeDocumentMetadata> createState() => _HomeDocumentMetadataState();
}

final class _HomeDocumentMetadataState extends State<HomeDocumentMetadata> {
  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(HomeDocumentMetadata oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.regions != widget.regions) _sync();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void dispose() {
    resetStoreHomeStructuredData();
    super.dispose();
  }

  void _sync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      applyStoreHomeStructuredData(
        buildStoreHomeStructuredData(
          currentUri: Uri.base,
          regions: widget.regions,
        ),
      );
    });
  }
}

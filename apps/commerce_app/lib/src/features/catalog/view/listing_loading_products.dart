import 'package:commerce_app/src/core/store_theme.dart';
import 'package:flutter/material.dart';

import 'listing_search_box.dart';

/// StoreHits loading column translated from Medusa's SkeletonProductGrid.
class ListingLoadingProducts extends StatelessWidget {
  /// Creates the source-shaped Store loading content.
  const ListingLoadingProducts({
    required this.query,
    required this.onSearchChanged,
    super.key,
  });

  /// Current Store search query.
  final String query;

  /// Changes the Store free-text search query.
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListingSearchBox(query: query, onChanged: onSearchChanged),
          const _SkeletonPulse(child: _SkeletonProductGrid(count: 12)),
        ],
      );
}

final class _SkeletonProductGrid extends StatelessWidget {
  const _SkeletonProductGrid({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth <= 0) return const SizedBox.shrink();
          final viewportWidth = MediaQuery.sizeOf(context).width;
          final preferredColumns = viewportWidth >= 1280
              ? 4
              : viewportWidth >= 1024
                  ? 3
                  : 2;
          const spacing = 24.0;
          final columns = constraints.maxWidth < spacing ? 1 : preferredColumns;
          final cardWidth =
              (constraints.maxWidth - (columns - 1) * spacing) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: 32,
            children: [
              for (var index = 0; index < count; index++)
                SizedBox(width: cardWidth, child: const _SkeletonProduct()),
            ],
          );
        },
      );
}

final class _SkeletonProduct extends StatelessWidget {
  const _SkeletonProduct();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: StoreColors.subtle,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AspectRatio(aspectRatio: 9 / 16),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(flex: 2, child: _SkeletonBar()),
              Spacer(flex: 2),
              Expanded(child: _SkeletonBar()),
            ],
          ),
        ],
      );
}

final class _SkeletonPulse extends StatefulWidget {
  const _SkeletonPulse({required this.child});

  final Widget child;

  @override
  State<_SkeletonPulse> createState() => _SkeletonPulseState();
}

final class _SkeletonPulseState extends State<_SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: .55, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _opacity,
        child: widget.child,
      );
}

final class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar();

  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 24,
        child: ColoredBox(color: StoreColors.subtleHover),
      );
}

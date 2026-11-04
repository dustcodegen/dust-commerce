import 'package:flutter/material.dart';

/// Medusa-matched marker for the product image used across selling surfaces.
final class AdminProductThumbnailBadge extends StatelessWidget {
  /// Creates the compact blue thumbnail marker.
  const AdminProductThumbnailBadge({this.size = 24, super.key});

  /// Outer badge diameter.
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0xFF3B82F6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.photo_size_select_actual_outlined,
            color: Colors.white,
            size: 13,
          ),
        ),
      );
}

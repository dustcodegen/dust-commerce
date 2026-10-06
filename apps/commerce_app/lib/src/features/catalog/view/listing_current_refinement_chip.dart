import 'package:commerce_app/src/core/store_theme.dart';
import 'package:flutter/material.dart';

/// Source-shaped active refinement chip from Medusa CurrentRefinements.
class ListingCurrentRefinementChip extends StatelessWidget {
  /// Creates one removable active-filter chip.
  const ListingCurrentRefinementChip({
    required this.label,
    required this.onPressed,
    super.key,
  });

  /// Public chip label.
  final String label;

  /// Removes the single matching refinement.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Remove filter $label',
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          hoverColor: StoreColors.subtleHover,
          onTap: onPressed,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: StoreColors.interactive),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: _chipText),
                const SizedBox(width: 6),
                const Icon(
                  Icons.close,
                  color: StoreColors.foregroundMuted,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      );

  static const _chipText = TextStyle(
    color: StoreColors.foreground,
    fontSize: 12,
    height: 20 / 12,
  );
}

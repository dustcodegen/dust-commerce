import 'package:commerce_app/src/core/store_theme.dart';
import 'package:flutter/material.dart';

/// A Medusa-style equal-width product option control.
class ProductOptionButton extends StatefulWidget {
  /// Creates a selectable value button.
  const ProductOptionButton({
    required this.label,
    required this.selected,
    required this.onPressed,
    super.key,
  });

  /// Customer-facing option value.
  final String label;

  /// Invoked when this combination remains available.
  final VoidCallback? onPressed;

  /// Whether the value belongs to the selected variant.
  final bool selected;

  @override
  State<ProductOptionButton> createState() => _ProductOptionButtonState();
}

class _ProductOptionButtonState extends State<ProductOptionButton> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      selected: widget.selected,
      child: MouseRegion(
        onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
        onExit: enabled ? (_) => setState(() => _hovered = false) : null,
        child: AnimatedContainer(
          height: 40,
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: StoreColors.subtle,
            border: Border.all(
              color: widget.selected
                  ? StoreColors.interactive
                  : StoreColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered && !widget.selected
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(8),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: enabled
                              ? StoreColors.foreground
                              : StoreColors.foregroundDisabled,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

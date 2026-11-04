import 'package:commerce_app/src/core/store_theme.dart';
import 'package:flutter/material.dart';

/// Medusa DTC InteractiveLink with its directional hover motion.
class StoreInteractiveLink extends StatefulWidget {
  /// Creates a source-shaped inline navigation action.
  const StoreInteractiveLink({
    required this.onPressed,
    required this.child,
    super.key,
  });

  /// Visible link label.
  final Widget child;

  /// Opens the linked storefront route.
  final VoidCallback onPressed;

  @override
  State<StoreInteractiveLink> createState() => _StoreInteractiveLinkState();
}

class _StoreInteractiveLinkState extends State<StoreInteractiveLink> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) => Semantics(
        link: true,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: InkWell(
            onTap: widget.onPressed,
            child: IconTheme.merge(
              data: const IconThemeData(
                color: StoreColors.interactive,
                size: 16,
              ),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  color: StoreColors.interactive,
                  fontSize: 14,
                  height: 20 / 14,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.child,
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _hovered ? .125 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(Icons.arrow_outward),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}

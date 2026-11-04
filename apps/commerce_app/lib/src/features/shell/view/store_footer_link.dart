import 'package:commerce_app/src/core/store_theme.dart';
import 'package:flutter/material.dart';

/// Compact source-style footer link with a full semantic tap target.
class FooterTextLink extends StatelessWidget {
  /// Creates a footer link.
  const FooterTextLink({
    required this.label,
    required this.onPressed,
    this.emphasized = false,
    super.key,
  });

  /// Whether a parent category should use stronger text.
  final bool emphasized;

  /// Visible link label.
  final String label;

  /// Link destination action.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(44, 20),
          alignment: Alignment.centerLeft,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: StoreColors.foregroundSubtle,
          textStyle: TextStyle(
            fontSize: 14,
            fontWeight: emphasized ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
        child: Text(label),
      );
}

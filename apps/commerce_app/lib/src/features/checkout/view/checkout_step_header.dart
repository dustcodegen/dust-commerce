import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Shared title, completion mark, and edit action for a checkout step.
final class CheckoutStepHeader extends StatelessWidget {
  /// Creates a source-shaped checkout heading.
  const CheckoutStepHeader({
    required this.title,
    required this.open,
    required this.complete,
    this.onEdit,
    super.key,
  });

  /// Whether the step has enough information to continue.
  final bool complete;

  /// Returns to this completed step.
  final VoidCallback? onEdit;

  /// Whether this step's controls are expanded.
  final bool open;

  /// Customer-facing step title.
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: open || complete ? 24 : 0),
        child: Row(
          children: [
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: open || complete ? 1 : 0.5,
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 32,
                          height: 44 / 32,
                        ),
                      ),
                    ),
                    if (!open && complete) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: StoreColors.foreground,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (!open && complete && onEdit != null)
              TextButton(
                onPressed: onEdit,
                child: const TranslatedText(
                  'shop_checkout_edit',
                  defaultText: 'Edit',
                ),
              ),
          ],
        ),
      );
}

/// Divider and vertical rhythm shared by every checkout section.
final class CheckoutSectionDivider extends StatelessWidget {
  /// Creates the section divider.
  const CheckoutSectionDivider({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.only(top: 32),
        child: Divider(),
      );
}

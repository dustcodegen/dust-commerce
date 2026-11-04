import 'package:flutter/material.dart';

/// Shared Medusa-shaped card for one product detail section.
final class AdminProductDetailSection extends StatelessWidget {
  /// Creates a bordered detail section.
  const AdminProductDetailSection({
    required this.title,
    required this.child,
    this.action,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  /// Optional trailing section control.
  final Widget? action;

  /// Section body.
  final Widget child;

  /// Body padding after the divided header.
  final EdgeInsetsGeometry padding;

  /// Merchant-facing section heading.
  final String title;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x12000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (action case final value?) value,
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            Padding(padding: padding, child: child),
          ],
        ),
      );
}

/// One label/value row matching Medusa's compact detail sections.
final class AdminProductDetailRow extends StatelessWidget {
  /// Creates a divided detail row.
  const AdminProductDetailRow({
    required this.label,
    required this.value,
    this.trailing,
    super.key,
  });

  /// Left-hand merchant label.
  final String label;

  /// Optional row action.
  final Widget? trailing;

  /// Display-ready row value.
  final Widget value;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(child: value),
            if (trailing case final action?) action,
          ],
        ),
      );
}

/// Standard edit affordance for detail sections not yet mutable.
Widget adminSectionAction(VoidCallback onPressed) => IconButton(
      tooltip: 'Section actions',
      onPressed: onPressed,
      icon: const Icon(Icons.more_horiz_rounded, size: 18),
    );

/// Displays absent data without inventing merchant values.
Widget adminDetailText(BuildContext context, Object? value) {
  final text = value?.toString().trim() ?? '';
  return Text(
    text.isEmpty ? '—' : text,
    style: text.isEmpty
        ? TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)
        : null,
  );
}

import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

/// One independently expandable, source-shaped product detail row.
final class ProductTab extends StatefulWidget {
  /// Creates a product tab with its collapsed [title] and expanded [child].
  const ProductTab({required this.title, required this.child, super.key});

  /// Content revealed below the trigger.
  final Widget child;

  /// Customer-facing trigger label.
  final Widget title;

  @override
  State<ProductTab> createState() => _ProductTabState();
}

final class _ProductTabState extends State<ProductTab> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          collapsedIconColor: StoreColors.foregroundMuted,
          collapsedShape: const Border(),
          collapsedTextColor: StoreColors.foregroundSubtle,
          childrenPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 32,
          ),
          iconColor: StoreColors.foregroundMuted,
          onExpansionChanged: (expanded) =>
              setState(() => _expanded = expanded),
          shape: const Border(),
          textColor: StoreColors.foregroundSubtle,
          tilePadding: const EdgeInsets.symmetric(horizontal: 4),
          title: DefaultTextStyle.merge(
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: StoreColors.foregroundSubtle,
                ),
            child: widget.title,
          ),
          trailing: SizedBox.square(
            dimension: 32,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  _expanded ? Icons.remove : Icons.add,
                  key: ValueKey(_expanded),
                  size: 20,
                ),
              ),
            ),
          ),
          children: [widget.child],
        ),
      );
}

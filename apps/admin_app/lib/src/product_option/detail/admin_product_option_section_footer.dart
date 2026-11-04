import 'package:flutter/material.dart';

/// Compact one-page result summary shared by option detail tables.
final class AdminProductOptionSectionFooter extends StatelessWidget {
  /// Creates a disabled single-page footer for [count] loaded rows.
  const AdminProductOptionSectionFooter({required this.count, super.key});

  /// Number of rows after local filtering.
  final int count;

  @override
  Widget build(BuildContext context) => Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(children: [
          Text(count == 0 ? '0 of 0 results' : '1 — $count of $count results'),
          const Spacer(),
          const Text('1 of 1 pages'),
          const SizedBox(width: 18),
          const TextButton(onPressed: null, child: Text('Prev')),
          const TextButton(onPressed: null, child: Text('Next')),
        ]),
      );
}

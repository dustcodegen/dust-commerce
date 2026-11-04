import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Product dimensions and values matching Medusa's option section.
final class AdminProductOptionSection extends StatelessWidget {
  /// Creates the product option section.
  const AdminProductOptionSection({
    required this.options,
    required this.onOpen,
    required this.onUnavailable,
    super.key,
  });

  /// Ordered merchant options.
  final List<AdminProductOption> options;

  /// Opens the option's dedicated Medusa detail route.
  final ValueChanged<AdminProductOption> onOpen;

  /// Reports controls whose write API is not implemented yet.
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Options',
        action: adminSectionAction(onUnavailable),
        child: options.isEmpty
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No options')),
              )
            : Column(
                children: [
                  for (final option in options)
                    AdminProductDetailRow(
                      label: option.title,
                      value: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final value in option.values)
                            _OptionBadge(value: value),
                        ],
                      ),
                      trailing: IconButton(
                        tooltip: 'Go to product option',
                        onPressed: () => onOpen(option),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      ),
                    ),
                ],
              ),
      );
}

final class _OptionBadge extends StatelessWidget {
  const _OptionBadge({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(value, style: Theme.of(context).textTheme.bodySmall),
      );
}

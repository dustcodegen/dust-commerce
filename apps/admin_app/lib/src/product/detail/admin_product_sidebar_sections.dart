import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:admin_app/src/product/detail/admin_product_sales_channel_section.dart';
import 'package:admin_app/src/product/detail/admin_product_shipping_profile_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped product sidebar backed only by modeled product data.
final class AdminProductSidebarSections extends StatelessWidget {
  /// Creates product sidebar cards.
  const AdminProductSidebarSections({
    required this.product,
    required this.salesChannels,
    required this.totalSalesChannels,
    required this.onEditOrganization,
    required this.onEditSalesChannels,
    required this.onEditShippingProfile,
    required this.onOpenShippingProfile,
    required this.onUnavailable,
    super.key,
  });

  /// Complete admin product allowlist.
  final AdminProductDetail product;

  /// Channels through which this product is available.
  final List<AdminSalesChannel> salesChannels;

  /// Total configured channels, absent when the supporting request failed.
  final Option<int> totalSalesChannels;

  /// Opens the product-type organization editor.
  final VoidCallback onEditOrganization;

  /// Opens the product sales-channel focus editor.
  final VoidCallback onEditSalesChannels;

  /// Opens the scalar shipping-profile editor.
  final VoidCallback onEditShippingProfile;

  /// Opens one profile on its Settings detail route.
  final ValueChanged<String> onOpenShippingProfile;

  /// Reports controls whose domain is not implemented yet.
  final VoidCallback onUnavailable;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          AdminProductSalesChannelSection(
            channels: salesChannels,
            totalChannels: totalSalesChannels,
            onEdit: onEditSalesChannels,
          ),
          const SizedBox(height: 12),
          AdminProductShippingProfileSection(
            shippingProfile: product.shippingProfile,
            onEdit: onEditShippingProfile,
            onOpen: onOpenShippingProfile,
          ),
          const SizedBox(height: 12),
          AdminProductDetailSection(
            title: 'Organize',
            action: adminSectionAction(onEditOrganization),
            child: Column(
              children: [
                _BadgeRow(label: 'Tags', values: product.tags),
                _BadgeRow(label: 'Type', values: [product.productType ?? '']),
                _BadgeRow(
                  label: 'Collection',
                  values: [product.collectionTitle ?? ''],
                ),
                _BadgeRow(
                  label: 'Categories',
                  values: product.categories,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AdminProductDetailSection(
            title: 'Attributes',
            action: adminSectionAction(onUnavailable),
            child: Column(
              children: [
                _AttributeRow(label: 'Height', value: product.height),
                _AttributeRow(label: 'Width', value: product.width),
                _AttributeRow(label: 'Length', value: product.length),
                _AttributeRow(label: 'Weight', value: product.weight),
                _AttributeRow(
                  label: 'Country of Origin',
                  value: product.originCountry,
                ),
              ],
            ),
          ),
        ],
      );
}

final class _AttributeRow extends StatelessWidget {
  const _AttributeRow({required this.label, required this.value});

  final String label;
  final Object? value;

  @override
  Widget build(BuildContext context) => AdminProductDetailRow(
        label: label,
        value: adminDetailText(context, value),
      );
}

final class _BadgeRow extends StatelessWidget {
  const _BadgeRow({required this.label, required this.values});

  final String label;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final present = values.where((value) => value.trim().isNotEmpty).toList();
    return AdminProductDetailRow(
      label: label,
      value: present.isEmpty
          ? adminDetailText(context, null)
          : Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final value in present) _Badge(value: value)],
            ),
    );
  }
}

final class _Badge extends StatelessWidget {
  const _Badge({required this.value});

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

import 'package:admin_app/src/product/admin_product_table.dart';
import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:admin_app/src/product_option/detail/admin_product_option_section_footer.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Products using an option, rendered with Medusa's standard product columns.
final class AdminProductOptionProductsSection extends StatefulWidget {
  /// Creates the linked-products card.
  const AdminProductOptionProductsSection({
    required this.products,
    required this.onOpen,
    super.key,
  });

  /// Opens one linked product detail.
  final ValueChanged<String> onOpen;

  /// Allowlisted linked products.
  final List<AdminProduct> products;

  @override
  State<AdminProductOptionProductsSection> createState() =>
      _AdminProductOptionProductsSectionState();
}

final class _AdminProductOptionProductsSectionState
    extends State<AdminProductOptionProductsSection> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visible = widget.products
        .where((item) => item.title.toLowerCase().contains(_query))
        .toList();
    return AdminProductDetailSection(
      title: 'Products',
      action: SizedBox(
        width: 184,
        child: TextField(
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
          decoration: const InputDecoration(
            hintText: 'Search',
            prefixIcon: Icon(Icons.search_rounded, size: 17),
          ),
        ),
      ),
      child: widget.products.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('There are no products with this option.'),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 43 + 43 * visible.length.clamp(1, 10).toDouble(),
                  child: AdminProductTable(
                    products: visible,
                    onOpen: widget.onOpen,
                  ),
                ),
                AdminProductOptionSectionFooter(count: visible.length),
              ],
            ),
    );
  }
}

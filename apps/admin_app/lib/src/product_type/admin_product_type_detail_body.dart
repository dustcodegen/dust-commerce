import 'package:admin_app/src/product_type/admin_product_type_detail_state.dart';
import 'package:admin_app/src/product_type/detail/admin_product_type_data_sections.dart';
import 'package:admin_app/src/product_type/detail/admin_product_type_general_section.dart';
import 'package:admin_app/src/product_type/detail/admin_product_type_products_section.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Renders the loaded product-type detail sections.
final class AdminProductTypeDetailBody extends StatelessWidget {
  /// Creates the loaded detail body.
  const AdminProductTypeDetailBody({
    required this.state,
    required this.productType,
    required this.onEdit,
    required this.onDelete,
    required this.onOpenProduct,
    super.key,
  });

  /// Loaded detail state for linked products and paging.
  final AdminProductTypeDetailState state;

  /// Product type shown by the page.
  final AdminProductType productType;

  /// Opens the edit drawer.
  final VoidCallback onEdit;

  /// Opens the delete confirmation.
  final VoidCallback onDelete;

  /// Opens one linked product.
  final ValueChanged<String> onOpenProduct;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1600),
              child: Column(children: [
                AdminProductTypeGeneralSection(
                  productType: productType,
                  onEdit: onEdit,
                  onDelete: onDelete,
                ),
                const SizedBox(height: 12),
                AdminProductTypeProductsSection(
                  state: state,
                  onOpen: onOpenProduct,
                ),
                const SizedBox(height: 12),
                AdminProductTypeDataSections(productType: productType),
              ]),
            ),
          ),
        ],
      );
}

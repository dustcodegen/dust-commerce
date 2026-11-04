import 'package:admin_app/src/product/admin_product_actions.dart';
import 'package:admin_app/src/product/admin_product_sales_channel_cell.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

part 'admin_product_table_cells.dart';
part 'admin_product_table_header.dart';
part 'admin_product_table_row.dart';

/// Desktop-first product table with horizontal safety on narrow viewports.
final class AdminProductTable extends StatelessWidget {
  /// Creates the allowlisted merchant product table.
  const AdminProductTable({
    required this.products,
    required this.onOpen,
    this.onDelete,
    super.key,
  });

  /// Confirms and retires one product where the host route supports mutation.
  final ValueChanged<AdminProduct>? onDelete;

  /// Rows returned by the explicit admin product contract.
  final List<AdminProduct> products;

  /// Opens the complete detail for one product id.
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: constraints.maxWidth < 920 ? 920 : constraints.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _ProductHeader(),
                for (final product in products)
                  _ProductRow(
                    product: product,
                    onOpen: onOpen,
                    onDelete: onDelete,
                  ),
              ],
            ),
          ),
        ),
      );
}

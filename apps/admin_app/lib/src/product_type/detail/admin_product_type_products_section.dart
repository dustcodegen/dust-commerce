import 'package:admin_app/src/product/admin_product_table.dart';
import 'package:admin_app/src/product/detail/admin_product_detail_section.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_state.dart';
import 'package:admin_app/src/product_type/admin_product_type_detail_view_model.dart';
import 'package:admin_app/src/product_type/detail/admin_product_type_pagination.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Server-paged products assigned to one product type.
final class AdminProductTypeProductsSection extends StatefulWidget {
  /// Creates the linked-products card.
  const AdminProductTypeProductsSection({
    required this.state,
    required this.onOpen,
    super.key,
  });

  /// Opens one linked product route.
  final ValueChanged<String> onOpen;

  /// Current server-owned product page.
  final AdminProductTypeDetailState state;

  @override
  State<AdminProductTypeProductsSection> createState() =>
      _AdminProductTypeProductsSectionState();
}

final class _AdminProductTypeProductsSectionState
    extends State<AdminProductTypeProductsSection> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AdminProductDetailSection(
        title: 'Products',
        child: Column(children: [
          _toolbar(context),
          if (widget.state.products.isEmpty)
            const SizedBox(
              height: 96,
              child: Center(child: Text('No records')),
            )
          else
            AdminProductTable(
              products: widget.state.products,
              onOpen: widget.onOpen,
            ),
          AdminProductTypePagination(state: widget.state),
          if (widget.state.status == AdminProductTypeDetailStatus.loading)
            const LinearProgressIndicator(minHeight: 2),
        ]),
      );

  Widget _toolbar(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _query,
              onSubmitted: context.readAdminProductTypeDetailViewModel().search,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search_rounded, size: 17),
              ),
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<AdminProductOrder>(
            tooltip: 'Sort products',
            initialValue: widget.state.order,
            onSelected: context.readAdminProductTypeDetailViewModel().orderBy,
            itemBuilder: (context) => [
              for (final order in _orders)
                PopupMenuItem(
                  value: order.$1,
                  child: Text(order.$2),
                ),
            ],
            icon: const Icon(Icons.swap_vert_rounded, size: 18),
          ),
        ]),
      );
}

const List<(AdminProductOrder, String)> _orders = [
  (AdminProductOrder.titleAsc, 'Title: A to Z'),
  (AdminProductOrder.titleDesc, 'Title: Z to A'),
  (AdminProductOrder.createdAtAsc, 'Created: oldest first'),
  (AdminProductOrder.createdAtDesc, 'Created: newest first'),
  (AdminProductOrder.updatedAtAsc, 'Updated: oldest first'),
  (AdminProductOrder.updatedAtDesc, 'Updated: newest first'),
];

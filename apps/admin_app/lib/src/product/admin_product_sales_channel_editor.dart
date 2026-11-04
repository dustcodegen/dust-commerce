import 'dart:async';

import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

part 'admin_product_sales_channel_editor_chrome.dart';
part 'admin_product_sales_channel_editor_actions.dart';
part 'admin_product_sales_channel_table.dart';
part 'admin_product_sales_channel_table_controls.dart';

/// Loads and opens Medusa's full-screen product channel assignment surface.
Future<bool?> showAdminProductSalesChannelEditor(
  BuildContext context,
  AdminProductDetail product,
  List<AdminSalesChannel> assigned,
) async {
  final viewModel = context.readAdminProductDetailViewModel();
  viewModel.clearFailure();
  final result = await viewModel.salesChannelChoices();
  if (!context.mounted) return null;
  switch (result) {
    case Some(value: final page):
      return showGeneralDialog<bool>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'Close sales-channel editor',
        transitionDuration: const Duration(milliseconds: 160),
        pageBuilder: (_, __, ___) => _SalesChannelEditor(
          product: product,
          assigned: assigned,
          initialPage: page,
        ),
      );
    case None():
      final failure = switch (viewModel.state.failure) {
        Some(:final value) => value,
        None() => 'Unable to load sales channels. Try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure)),
      );
      return null;
  }
}

final class _SalesChannelEditor extends StatefulWidget {
  const _SalesChannelEditor({
    required this.product,
    required this.assigned,
    required this.initialPage,
  });

  final List<AdminSalesChannel> assigned;
  final AdminSalesChannelDetailList initialPage;
  final AdminProductDetail product;

  @override
  State<_SalesChannelEditor> createState() => _SalesChannelEditorState();
}

final class _SalesChannelEditorState extends State<_SalesChannelEditor>
    with _SalesChannelEditorActions {
  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductDetailViewModel().value;
    final busy = state.isSaving || _loading;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(children: [
          _EditorHeader(
            busy: busy,
            onClose: () => Navigator.of(context).pop(false),
          ),
          Expanded(
            child: _EditorBody(
              busy: busy,
              loading: _loading,
              page: _page,
              selected: _selected,
              failure: _failure,
              search: _search,
              horizontal: _horizontal,
              onSearchChanged: _searchChanged,
              onToggle: _toggle,
              onTogglePage: _togglePage,
              onPage: _load,
            ),
          ),
          _EditorFooter(
            busy: busy,
            onCancel: () => Navigator.of(context).pop(false),
            onSave: _save,
          ),
        ]),
      ),
    );
  }
}

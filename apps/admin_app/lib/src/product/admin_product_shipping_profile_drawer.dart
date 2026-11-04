import 'dart:async';

import 'package:admin_app/src/product/admin_product_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_product_shipping_profile_drawer_actions.dart';
part 'admin_product_shipping_profile_drawer_body.dart';
part 'admin_product_shipping_profile_drawer_chrome.dart';
part 'admin_product_shipping_profile_combobox.dart';

/// Loads choices and opens Medusa's right-side shipping-profile editor.
Future<bool?> showAdminProductShippingProfileDrawer(
  BuildContext context,
  AdminProductDetail product,
) async {
  final viewModel = context.readAdminProductDetailViewModel();
  viewModel.clearFailure();
  final result = await viewModel.shippingProfileChoices();
  if (!context.mounted) return null;
  return switch (result) {
    Some(value: final page) => showGeneralDialog<bool>(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Close shipping-profile editor',
        barrierColor: Colors.black.withValues(alpha: 0.24),
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (context, _, __) => Padding(
          padding: const EdgeInsets.all(8),
          child: Align(
            alignment: Alignment.centerRight,
            child: _ShippingProfileDrawer(
              product: product,
              initialPage: page,
            ),
          ),
        ),
        transitionBuilder: (context, animation, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        ),
      ),
    None() => _showProfileLoadFailure(context, viewModel.state.failure),
  };
}

Future<bool?> _showProfileLoadFailure(
  BuildContext context,
  Option<String> failure,
) async {
  final message = switch (failure) {
    Some(:final value) => value,
    None() => 'Unable to load shipping profiles. Try again.',
  };
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  return null;
}

final class _ShippingProfileDrawer extends StatefulWidget {
  const _ShippingProfileDrawer({
    required this.product,
    required this.initialPage,
  });

  final AdminShippingProfileList initialPage;
  final AdminProductDetail product;

  @override
  State<_ShippingProfileDrawer> createState() => _ShippingProfileDrawerState();
}

final class _ShippingProfileDrawerState extends State<_ShippingProfileDrawer>
    with _ShippingProfileDrawerActions {
  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminProductDetailViewModel().value;
    final busy = state.isSaving || _loading;
    return _ShippingProfileDrawerFrame(
      page: _page,
      selected: _selected,
      search: _search,
      failure: _failure,
      busy: busy,
      loading: _loading,
      onClose: () => Navigator.of(context).pop(false),
      onSearchChanged: _searchChanged,
      onSelect: _select,
      onLoadMore: _loadMore,
      onSave: _save,
    );
  }
}

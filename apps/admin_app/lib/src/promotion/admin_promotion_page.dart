import 'package:admin_app/src/promotion/admin_promotion_page_header.dart';
import 'package:admin_app/src/promotion/admin_promotion_pagination.dart';
import 'package:admin_app/src/promotion/admin_promotion_query_bar.dart';
import 'package:admin_app/src/promotion/admin_promotion_table_body.dart';
import 'package:admin_app/src/promotion/admin_promotion_view_model.dart';
import 'package:flutter/material.dart';

/// Medusa's promotions list backed by the protected API.
final class AdminPromotionPage extends StatefulWidget {
  /// Creates the promotions route.
  const AdminPromotionPage({
    required this.searchFocus,
    required this.onOpen,
    super.key,
  });

  /// Opens one promotion detail route.
  final ValueChanged<String> onOpen;

  /// Focus target shared with the sidebar search action.
  final FocusNode searchFocus;

  @override
  State<AdminPromotionPage> createState() => _AdminPromotionPageState();
}

final class _AdminPromotionPageState extends State<AdminPromotionPage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminPromotionViewModel().value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            shadowColor: const Color(0x16000000),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const AdminPromotionPageHeader(),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              AdminPromotionQueryBar(
                state: state,
                searchFocus: widget.searchFocus,
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              AdminPromotionTableBody(
                state: state,
                onOpen: widget.onOpen,
                onRetry: context.readAdminPromotionViewModel().load,
              ),
              AdminPromotionPagination(state: state),
            ]),
          ),
        ),
      ),
    );
  }
}

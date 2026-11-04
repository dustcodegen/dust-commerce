import 'package:admin_app/src/shipping_profile/admin_shipping_profile_create_page.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_delete.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_page_header.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_pagination.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_query_bar.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_table_body.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Medusa's shipping-profile settings list backed by the protected API.
final class AdminShippingProfilePage extends StatefulWidget {
  /// Creates the shipping-profile route.
  const AdminShippingProfilePage({
    required this.searchFocus,
    required this.onOpen,
    super.key,
  });

  /// Opens one profile detail route.
  final ValueChanged<String> onOpen;

  /// Focus target shared with the sidebar search action.
  final FocusNode searchFocus;

  @override
  State<AdminShippingProfilePage> createState() =>
      _AdminShippingProfilePageState();
}

final class _AdminShippingProfilePageState
    extends State<AdminShippingProfilePage> {
  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminShippingProfileViewModel().value;
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
              AdminShippingProfilePageHeader(onCreate: _create),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              AdminShippingProfileQueryBar(
                state: state,
                searchFocus: widget.searchFocus,
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              AdminShippingProfileTableBody(
                state: state,
                onOpen: widget.onOpen,
                onDelete: _delete,
                onRetry: context.readAdminShippingProfileViewModel().load,
              ),
              AdminShippingProfilePagination(state: state),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    final created = await showAdminShippingProfileCreatePage(context);
    if (!mounted || created == null) return;
    widget.onOpen(created.id);
  }

  Future<void> _delete(AdminShippingProfile profile) async {
    if (!await confirmAdminShippingProfileDelete(context, profile.name) ||
        !mounted) {
      return;
    }
    final outcome =
        await context.readAdminShippingProfileViewModel().delete(profile.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(adminShippingProfileDeleteMessage(outcome, profile.name)),
    ));
  }
}

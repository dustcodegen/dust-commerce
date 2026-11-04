import 'package:admin_app/src/customer_group/admin_customer_group_edit_frame.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_edit_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's right-side customer-group editor.
Future<AdminCustomerGroupDetail?> showAdminCustomerGroupEditDrawer(
  BuildContext context,
  AdminCustomerGroupDetail customerGroup,
) =>
    showGeneralDialog<AdminCustomerGroupDetail>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close customer group editor',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: _AdminCustomerGroupEditDrawer(
            customerGroup: customerGroup,
          ),
        ),
      ),
      transitionBuilder: (context, animation, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: child,
      ),
    );

final class _AdminCustomerGroupEditDrawer extends StatefulWidget {
  const _AdminCustomerGroupEditDrawer({required this.customerGroup});

  final AdminCustomerGroupDetail customerGroup;

  @override
  State<_AdminCustomerGroupEditDrawer> createState() =>
      _AdminCustomerGroupEditDrawerState();
}

final class _AdminCustomerGroupEditDrawerState
    extends State<_AdminCustomerGroupEditDrawer> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.customerGroup.name);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.readAdminCustomerGroupEditViewModel().clearFailure();
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerGroupEditViewModel().value;
    final navigator = Navigator.of(context);
    return PopScope(
      canPop: !state.isBusy,
      child: AdminCustomerGroupEditFrame(
        busy: state.isBusy,
        failure: state.failure,
        formKey: _form,
        name: _name,
        onCancel: navigator.pop,
        onSave: _save,
      ),
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final updated = await context.readAdminCustomerGroupEditViewModel().update(
          widget.customerGroup.id,
          AdminUpdateCustomerGroup(name: _name.text),
        );
    if (!mounted) return;
    if (updated case Some(:final value)) Navigator.of(context).pop(value);
  }
}

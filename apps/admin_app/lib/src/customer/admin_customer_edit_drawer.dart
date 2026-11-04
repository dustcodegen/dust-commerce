import 'package:admin_app/src/customer/admin_customer_edit_frame.dart';
import 'package:admin_app/src/customer/admin_customer_edit_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's right-side customer editor.
Future<AdminCustomerDetail?> showAdminCustomerEditDrawer(
  BuildContext context,
  AdminCustomerDetail customer,
) =>
    showGeneralDialog<AdminCustomerDetail>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close customer editor',
      barrierColor: Colors.black.withValues(alpha: 0.24),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, _, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: Align(
          alignment: Alignment.centerRight,
          child: _AdminCustomerEditDrawer(customer: customer),
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

final class _AdminCustomerEditDrawer extends StatefulWidget {
  const _AdminCustomerEditDrawer({required this.customer});

  final AdminCustomerDetail customer;

  @override
  State<_AdminCustomerEditDrawer> createState() =>
      _AdminCustomerEditDrawerState();
}

final class _AdminCustomerEditDrawerState
    extends State<_AdminCustomerEditDrawer> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _company;
  late final TextEditingController _email;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final customer = widget.customer;
    _company = TextEditingController(text: customer.companyNameValue ?? '');
    _email = TextEditingController(text: customer.emailValue ?? '');
    _firstName = TextEditingController(text: customer.firstNameValue ?? '');
    _lastName = TextEditingController(text: customer.lastNameValue ?? '');
    _phone = TextEditingController(text: customer.phoneValue ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminCustomerEditViewModel().clearFailure();
    });
  }

  @override
  void dispose() {
    _company.dispose();
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerEditViewModel().value;
    return PopScope(
      canPop: !state.isBusy,
      child: AdminCustomerEditFrame(
        busy: state.isBusy,
        company: _company,
        email: _email,
        emailEnabled: !widget.customer.hasAccount,
        failure: state.failure,
        firstName: _firstName,
        formKey: _form,
        lastName: _lastName,
        onCancel: Navigator.of(context).pop,
        onSave: _save,
        phone: _phone,
      ),
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final updated = await context.readAdminCustomerEditViewModel().update(
          widget.customer.id,
          AdminUpdateCustomer(
            emailValue: widget.customer.hasAccount ? null : _email.text,
            companyNameValue: _optional(_company.text),
            firstNameValue: _optional(_firstName.text),
            lastNameValue: _optional(_lastName.text),
            phoneValue: _optional(_phone.text),
          ),
        );
    if (!mounted) return;
    if (updated case Some(:final value)) Navigator.of(context).pop(value);
  }
}

String? _optional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

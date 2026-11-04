import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_info_editor.dart';
import 'profile_editor_field.dart';

/// Editable customer phone translated from Medusa ProfilePhone.
final class ProfilePhoneEditor extends StatefulWidget {
  /// Creates the phone editor for [customer].
  const ProfilePhoneEditor({required this.customer, super.key});

  /// Current public customer profile.
  final Customer customer;

  @override
  State<ProfilePhoneEditor> createState() => _ProfilePhoneEditorState();
}

class _ProfilePhoneEditorState extends State<ProfilePhoneEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    _phone = TextEditingController(text: widget.customer.phone ?? '');
  }

  @override
  void didUpdateWidget(covariant ProfilePhoneEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customer == widget.customer) return;
    _phone.text = widget.customer.phone ?? '';
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAccountViewModel().value;
    final updating = state.operation == AccountOperation.updateProfile;
    return AccountInfoEditor(
      label: context.tr('shop_account_phone', defaultText: 'Phone'),
      currentInfo: Text(
        widget.customer.phone?.isNotEmpty ?? false
            ? widget.customer.phone!
            : context.tr('shop_account_not_set', defaultText: 'Not set'),
      ),
      busy: updating && state.isBusy,
      error: updating && state.status == AccountStatus.failed
          ? state.message
          : null,
      onSave: _save,
      editor: Form(
        key: _formKey,
        child: ProfileEditorField(
          controller: _phone,
          label: context.tr('shop_account_phone', defaultText: 'Phone'),
          autofillHints: const [AutofillHints.telephoneNumber],
          validator: (value) => _required(context, value),
        ),
      ),
    );
  }

  String? _required(BuildContext context, String? value) =>
      value == null || value.trim().isEmpty
          ? context.tr(
              'shop_account_required',
              defaultText: 'This field is required.',
            )
          : null;

  Future<bool> _save() async {
    if (!_formKey.currentState!.validate()) return false;
    return context.readAccountViewModel().updateProfile(
          firstName: widget.customer.firstName ?? '',
          lastName: widget.customer.lastName ?? '',
          phone: _phone.text,
        );
  }
}

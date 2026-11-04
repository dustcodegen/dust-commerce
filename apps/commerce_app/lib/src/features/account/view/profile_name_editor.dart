import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_info_editor.dart';
import 'profile_editor_field.dart';

/// Editable customer name translated from Medusa ProfileName.
final class ProfileNameEditor extends StatefulWidget {
  /// Creates the name editor for [customer].
  const ProfileNameEditor({required this.customer, super.key});

  /// Current public customer profile.
  final Customer customer;

  @override
  State<ProfileNameEditor> createState() => _ProfileNameEditorState();
}

class _ProfileNameEditorState extends State<ProfileNameEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;

  @override
  void initState() {
    super.initState();
    _firstName = TextEditingController(text: widget.customer.firstName ?? '');
    _lastName = TextEditingController(text: widget.customer.lastName ?? '');
  }

  @override
  void didUpdateWidget(covariant ProfileNameEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.customer == widget.customer) return;
    _firstName.text = widget.customer.firstName ?? '';
    _lastName.text = widget.customer.lastName ?? '';
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAccountViewModel().value;
    final updating = state.operation == AccountOperation.updateProfile;
    return AccountInfoEditor(
      label: context.tr('shop_account_name', defaultText: 'Name'),
      currentInfo: Text(widget.customer.displayName),
      busy: updating && state.isBusy,
      error: updating && state.status == AccountStatus.failed
          ? state.message
          : null,
      onSave: _save,
      editor: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ProfileEditorField(
                controller: _firstName,
                label: context.tr(
                  'shop_account_first_name',
                  defaultText: 'First name',
                ),
                autofillHints: const [AutofillHints.givenName],
                validator: (value) => _required(context, value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ProfileEditorField(
                controller: _lastName,
                label: context.tr(
                  'shop_account_last_name',
                  defaultText: 'Last name',
                ),
                autofillHints: const [AutofillHints.familyName],
                validator: (value) => _required(context, value),
              ),
            ),
          ],
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
          firstName: _firstName.text,
          lastName: _lastName.text,
          phone: widget.customer.phone,
        );
  }
}

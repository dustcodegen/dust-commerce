import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_info_editor.dart';
import 'profile_editor_field.dart';

/// Working password editor for the TODO present in the Medusa source.
final class ProfilePasswordEditor extends StatefulWidget {
  /// Creates the authenticated password editor.
  const ProfilePasswordEditor({super.key});

  @override
  State<ProfilePasswordEditor> createState() => _ProfilePasswordEditorState();
}

final class _ProfilePasswordEditorState extends State<ProfilePasswordEditor> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAccountViewModel().value;
    final updating = state.operation == AccountOperation.changePassword;
    return AccountInfoEditor(
      label: context.tr('shop_account_password', defaultText: 'Password'),
      currentInfo: const TranslatedText(
        'shop_account_password_hidden',
        defaultText: 'The password is not shown for security reasons',
      ),
      busy: updating && state.isBusy,
      error: _error(context, state, updating),
      onCancel: _clear,
      onSave: _save,
      editor: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 16
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                ProfileEditorField(
                  width: width,
                  controller: _oldPassword,
                  label: context.tr(
                    'shop_account_old_password',
                    defaultText: 'Old password',
                  ),
                  autofillHints: const [AutofillHints.password],
                  obscureText: true,
                  validator: _validateOld,
                ),
                ProfileEditorField(
                  width: width,
                  controller: _newPassword,
                  label: context.tr(
                    'shop_account_new_password',
                    defaultText: 'New password',
                  ),
                  autofillHints: const [AutofillHints.newPassword],
                  obscureText: true,
                  validator: _validateNew,
                ),
                ProfileEditorField(
                  width: width,
                  controller: _confirmPassword,
                  label: context.tr(
                    'shop_account_confirm_password',
                    defaultText: 'Confirm password',
                  ),
                  autofillHints: const [AutofillHints.newPassword],
                  obscureText: true,
                  validator: _validateConfirmation,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String? _validateOld(String? value) => _passwordLength(value);

  String? _validateNew(String? value) {
    final invalid = _passwordLength(value);
    if (invalid != null) return invalid;
    if (value == _oldPassword.text) {
      return context.tr(
        'shop_account_password_same',
        defaultText: 'Use a different password.',
      );
    }
    return null;
  }

  String? _validateConfirmation(String? value) => value == _newPassword.text
      ? null
      : context.tr(
          'shop_account_password_mismatch',
          defaultText: 'Passwords do not match.',
        );

  String? _passwordLength(String? value) =>
      value != null && value.length >= 12 && value.length <= 1024
          ? null
          : context.tr(
              'shop_account_password_length',
              defaultText: 'Use 12 to 1024 characters.',
            );

  String? _error(
    BuildContext context,
    AccountState state,
    bool updating,
  ) {
    if (!updating || state.status != AccountStatus.failed) return null;
    if (state.message == 'Current password is incorrect') {
      return context.tr(
        'shop_account_current_password_incorrect',
        defaultText: 'Current password is incorrect.',
      );
    }
    return context.tr(
      'shop_account_password_update_failed',
      defaultText: 'We could not change your password. Please try again.',
    );
  }

  void _clear() {
    _oldPassword.clear();
    _newPassword.clear();
    _confirmPassword.clear();
  }

  Future<bool> _save() async {
    if (!_formKey.currentState!.validate()) return false;
    final changed = await context.readAccountViewModel().changePassword(
          oldPassword: _oldPassword.text,
          newPassword: _newPassword.text,
        );
    if (changed && mounted) _clear();
    return changed;
  }
}

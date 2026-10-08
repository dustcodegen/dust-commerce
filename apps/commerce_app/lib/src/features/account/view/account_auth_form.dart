import 'package:commerce_app/commerce_app.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'account_auth_layout.dart';
import 'account_auth_field.dart';
import 'account_verification_notice.dart';

part 'account_form_actions.dart';
part 'account_form_fields.dart';

enum _AccountFormView { signIn, register }

/// Source-shaped sign-in and registration forms sharing the `/account` route.
class AccountAuthForm extends StatefulWidget {
  /// Creates the account forms.
  const AccountAuthForm({super.key});

  @override
  State<AccountAuthForm> createState() => _AccountAuthFormState();
}

class _AccountAuthFormState extends State<AccountAuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  _AccountFormView _view = _AccountFormView.signIn;
  var _showPassword = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAccountViewModel().value;
    final registering = _view == _AccountFormView.register;
    final title = registering
        ? context.tr(
            'shop_account_register_title',
            defaultText: 'Become a Morrow Member',
          )
        : context.tr(
            'shop_account_welcome_back',
            defaultText: 'Welcome back',
          );
    final matchingFailure = state.status == AccountStatus.failed &&
        state.operation ==
            (registering ? AccountOperation.register : AccountOperation.signIn);
    final verificationEmail =
        state.status == AccountStatus.verificationRequired &&
                state.operation ==
                    (registering
                        ? AccountOperation.register
                        : AccountOperation.signIn)
            ? state.verificationEmail
            : const None<String>();
    return AccountAuthLayout(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    registering
                        ? context.tr(
                            'shop_account_register_body',
                            defaultText:
                                'Create your Morrow Member profile, and get '
                                'access to an enhanced shopping experience.',
                          )
                        : context.tr(
                            'shop_account_sign_in_body',
                            defaultText:
                                'Sign in to access an enhanced shopping experience.',
                          ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: registering ? 16 : 32),
                  verificationEmail.match(
                    some: (email) => AccountVerificationNotice(
                      email: email,
                      bottomMargin: registering ? 16 : 24,
                    ),
                    none: SizedBox.shrink,
                  ),
                  _AccountFormFields(
                    registering: registering,
                    email: _email,
                    password: _password,
                    firstName: _firstName,
                    lastName: _lastName,
                    phone: _phone,
                    showPassword: _showPassword,
                    onTogglePassword: () => setState(
                      () => _showPassword = !_showPassword,
                    ),
                  ),
                  _AccountFormActions(
                    registering: registering,
                    busy: state.isBusy,
                    error: matchingFailure ? state.message : null,
                    onSubmit: _submit,
                    onToggle: _toggle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggle() {
    _formKey.currentState?.reset();
    setState(() {
      _view = _view == _AccountFormView.signIn
          ? _AccountFormView.register
          : _AccountFormView.signIn;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final account = context.readAccountViewModel();
    if (_view == _AccountFormView.signIn) {
      await account.signIn(email: _email.text, password: _password.text);
      return;
    }
    await account.register(
      email: _email.text,
      password: _password.text,
      firstName: _firstName.text,
      lastName: _lastName.text,
      phone: _phone.text,
    );
  }
}

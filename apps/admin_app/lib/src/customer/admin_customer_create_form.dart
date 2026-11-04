import 'package:admin_app/src/core/admin_route_focus_chrome.dart';
import 'package:admin_app/src/customer/admin_customer_create_fields.dart';
import 'package:admin_app/src/customer/admin_customer_create_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Full-screen customer form matching Medusa's route-focus source.
final class AdminCustomerCreateForm extends StatefulWidget {
  /// Creates the focused customer form.
  const AdminCustomerCreateForm({super.key});

  @override
  State<AdminCustomerCreateForm> createState() =>
      _AdminCustomerCreateFormState();
}

final class _AdminCustomerCreateFormState
    extends State<AdminCustomerCreateForm> {
  final _form = GlobalKey<FormState>();
  final _company = TextEditingController();
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();

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
    final state = context.watchAdminCustomerCreateViewModel().value;
    final navigator = Navigator.of(context);
    return AdminRouteFocusKeyboard(
      enabled: !state.isBusy,
      onClose: navigator.pop,
      child: PopScope(
        canPop: !state.isBusy,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AdminRouteFocusHeader(
                    onClose: state.isBusy ? null : navigator.pop,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 64),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: Form(
                            key: _form,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Create customer',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add a new customer to your store.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                ),
                                const SizedBox(height: 32),
                                AdminCustomerCreateFields(
                                  company: _company,
                                  email: _email,
                                  firstName: _firstName,
                                  lastName: _lastName,
                                  phone: _phone,
                                  enabled: !state.isBusy,
                                ),
                                AdminRouteFocusFailure(failure: state.failure),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AdminRouteFocusFooter(
                    busy: state.isBusy,
                    onCancel: navigator.pop,
                    onSubmit: _submit,
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final created = await context.readAdminCustomerCreateViewModel().create(
          AdminCreateCustomer(
            email: _email.text,
            companyNameValue: _optional(_company.text),
            firstNameValue: _optional(_firstName.text),
            lastNameValue: _optional(_lastName.text),
            phoneValue: _optional(_phone.text),
          ),
        );
    if (!mounted) return;
    if (created case Some(:final value)) Navigator.of(context).pop(value);
  }
}

String? _optional(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

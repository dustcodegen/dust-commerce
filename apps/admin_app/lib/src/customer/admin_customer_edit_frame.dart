import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_customer_edit_fields.dart';
part 'admin_customer_edit_footer.dart';

/// Medusa-shaped frame for customer contact editing.
final class AdminCustomerEditFrame extends StatelessWidget {
  /// Creates the drawer frame and sticky actions.
  const AdminCustomerEditFrame({
    required bool busy,
    required TextEditingController company,
    required TextEditingController email,
    required bool emailEnabled,
    required Option<String> failure,
    required TextEditingController firstName,
    required GlobalKey<FormState> formKey,
    required TextEditingController lastName,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    required TextEditingController phone,
    super.key,
  })  : _busy = busy,
        _company = company,
        _email = email,
        _emailEnabled = emailEnabled,
        _failure = failure,
        _firstName = firstName,
        _formKey = formKey,
        _lastName = lastName,
        _onCancel = onCancel,
        _onSave = onSave,
        _phone = phone;

  final bool _busy;
  final TextEditingController _company;
  final TextEditingController _email;
  final bool _emailEnabled;
  final Option<String> _failure;
  final TextEditingController _firstName;
  final GlobalKey<FormState> _formKey;
  final TextEditingController _lastName;
  final VoidCallback _onCancel;
  final VoidCallback _onSave;
  final TextEditingController _phone;

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 16,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
          height: double.infinity,
          child: SafeArea(
            child: Column(children: [
              _AdminCustomerEditHeader(busy: _busy, onClose: _onCancel),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _AdminCustomerEditField(
                        controller: _email,
                        enabled: _emailEnabled && !_busy,
                        label: 'Email',
                        tooltip: _emailEnabled
                            ? null
                            : 'The email of a registered customer cannot be changed.',
                        validator: _emailError,
                      ),
                      _AdminCustomerEditField(
                        controller: _firstName,
                        enabled: !_busy,
                        label: 'First name',
                      ),
                      _AdminCustomerEditField(
                        controller: _lastName,
                        enabled: !_busy,
                        label: 'Last name',
                      ),
                      _AdminCustomerEditField(
                        controller: _company,
                        enabled: !_busy,
                        label: 'Company',
                      ),
                      _AdminCustomerEditField(
                        controller: _phone,
                        enabled: !_busy,
                        label: 'Phone',
                      ),
                      _AdminCustomerEditFailure(failure: _failure),
                    ],
                  ),
                ),
              ),
              _AdminCustomerEditFooter(
                busy: _busy,
                onCancel: _onCancel,
                onSave: _onSave,
              ),
            ]),
          ),
        ),
      );
}

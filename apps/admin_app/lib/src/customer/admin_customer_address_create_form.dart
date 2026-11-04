import 'package:admin_app/src/core/admin_country.dart';
import 'package:admin_app/src/customer/admin_customer_address_create_view_model.dart';
import 'package:admin_app/src/core/admin_route_focus_chrome.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_customer_address_controllers.dart';
part 'admin_customer_address_country_field.dart';
part 'admin_customer_address_create_fields.dart';

/// Full-screen address form matching Medusa's route-focus source.
final class AdminCustomerAddressCreateForm extends StatefulWidget {
  /// Creates the focused form beneath [customerId].
  const AdminCustomerAddressCreateForm({required this.customerId, super.key});

  /// Stable parent customer identifier.
  final String customerId;

  @override
  State<AdminCustomerAddressCreateForm> createState() =>
      _AdminCustomerAddressCreateFormState();
}

final class _AdminCustomerAddressCreateFormState
    extends State<AdminCustomerAddressCreateForm> {
  final _form = GlobalKey<FormState>();
  final _fields = _AdminCustomerAddressControllers();
  String? _countryCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.readAdminCustomerAddressCreateViewModel().clearFailure();
      }
    });
  }

  @override
  void dispose() {
    _fields.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerAddressCreateViewModel().value;
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
                        horizontal: 24,
                        vertical: 64,
                      ),
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
                                  'Create Address',
                                  style:
                                      Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Create a new address for the customer.',
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
                                _AdminCustomerAddressCreateFields(
                                  controllers: _fields,
                                  enabled: !state.isBusy,
                                  onCountrySelected: _selectCountry,
                                  onCountryTyped: _typeCountry,
                                  selectedCountryCode: _countryCode,
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
                    submitLabel: 'Save',
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  void _selectCountry(AdminCountry country) => setState(() {
        _countryCode = country.code;
        _fields.country.text = country.name;
      });

  void _typeCountry(String value) {
    if (value != adminCountryName(_countryCode)) {
      setState(() => _countryCode = null);
    }
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final created =
        await context.readAdminCustomerAddressCreateViewModel().create(
              widget.customerId,
              AdminCreateCustomerAddress(
                addressName: _fields.addressName.text,
                line1: _fields.line1.text,
                countryCode: _countryCode!,
                companyValue: _optionalAddress(_fields.company.text),
                firstNameValue: null,
                lastNameValue: null,
                line2Value: _optionalAddress(_fields.line2.text),
                cityValue: _optionalAddress(_fields.city.text),
                provinceValue: _optionalAddress(_fields.province.text),
                postalCodeValue: _optionalAddress(_fields.postalCode.text),
                phoneValue: _optionalAddress(_fields.phone.text),
              ),
            );
    if (!mounted) return;
    if (created case Some(:final value)) Navigator.of(context).pop(value);
  }
}

String? _optionalAddress(String value) {
  final text = value.trim();
  return text.isEmpty ? null : text;
}

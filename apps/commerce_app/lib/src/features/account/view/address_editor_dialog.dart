import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'customer_address_controllers.dart';
import 'customer_address_form.dart';

/// Add/edit dialog translated from Medusa's customer address modal.
final class AddressEditorDialog extends StatefulWidget {
  /// Creates a customer-address dialog.
  const AddressEditorDialog({
    required this.countries,
    required this.hasDefaultShipping,
    this.address,
    super.key,
  });

  /// Existing address when editing.
  final CustomerAddressView? address;

  /// Active server-provided country codes.
  final List<String> countries;

  /// Whether another address is already the default shipping destination.
  final bool hasDefaultShipping;

  @override
  State<AddressEditorDialog> createState() => _AddressEditorDialogState();
}

class _AddressEditorDialogState extends State<AddressEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final CustomerAddressControllers _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.address == null
        ? CustomerAddressControllers.forNewAddress()
        : CustomerAddressControllers.fromAddress(widget.address!);
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAddressBookViewModel().value;
    final error = state.status == AddressBookStatus.failed
        ? switch (state.message) {
            Some(:final value) => value,
            None() => null,
          }
        : null;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.address == null
                      ? context.tr(
                          'shop_account_add_address',
                          defaultText: 'Add address',
                        )
                      : context.tr(
                          'shop_account_edit_address',
                          defaultText: 'Edit address',
                        ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                CustomerAddressForm(
                  controllers: _controllers,
                  countries: widget.countries,
                ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    style: const TextStyle(color: Color(0xffe11d48)),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: state.isBusy
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: TranslatedText(
                        'shop_cancel',
                        defaultText: 'Cancel',
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: state.isBusy ? null : _save,
                      child: state.isBusy
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TranslatedText(
                              'shop_save',
                              defaultText: 'Save',
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final address = widget.address;
    final input = _controllers.input(
      isDefaultShipping:
          address?.isDefaultShipping ?? !widget.hasDefaultShipping,
      isDefaultBilling: address?.isDefaultBilling ?? false,
    );
    final model = context.readAddressBookViewModel();
    final saved = address == null
        ? await model.create(input)
        : await model.update(address.id, input);
    if (mounted && saved) Navigator.of(context).pop();
  }
}

import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'customer_service_form.dart';
import 'customer_service_success.dart';

/// Source-shaped support page backed by the real Store API.
final class CustomerServiceContent extends StatefulWidget {
  /// Creates the form with an optional order-reference prefill.
  const CustomerServiceContent({this.orderReference = '', super.key});

  /// Human-facing order number carried from an order screen.
  final String orderReference;

  @override
  State<CustomerServiceContent> createState() => _CustomerServiceContentState();
}

final class _CustomerServiceContentState extends State<CustomerServiceContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _subject;
  late final TextEditingController _message;
  late final TextEditingController _orderReference;
  var _identityPrefilled = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _email = TextEditingController();
    _subject = TextEditingController();
    _message = TextEditingController();
    _orderReference = TextEditingController(text: widget.orderReference.trim());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readCustomerServiceViewModel().reset();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_identityPrefilled) return;
    _identityPrefilled = true;
    final customer = context.readAccountViewModel().state.customer;
    if (customer == null) return;
    _name.text = customer.displayName;
    _email.text = customer.email;
  }

  @override
  void didUpdateWidget(CustomerServiceContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderReference == widget.orderReference) return;
    _orderReference.text = widget.orderReference.trim();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _subject.dispose();
    _message.dispose();
    _orderReference.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    unawaited(context.readCustomerServiceViewModel().submit(
          CustomerServiceRequestBody(
            name: _name.text.trim(),
            email: _email.text.trim(),
            subject: _subject.text.trim(),
            message: _message.text.trim(),
            orderReferenceValue: _orderReference.text.trim().isEmpty
                ? null
                : _orderReference.text.trim(),
          ),
        ));
  }

  void _another() {
    _subject.clear();
    _message.clear();
    _orderReference.clear();
    context.readCustomerServiceViewModel().reset();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchCustomerServiceViewModel().value;
    return SingleChildScrollView(
      child: Column(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 896),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const TranslatedText(
                      'shop_customer_service_title',
                      defaultText: 'Customer Service',
                      style: TextStyle(fontSize: 30, height: 1.35),
                    ),
                    const SizedBox(height: 8),
                    const TranslatedText(
                      'shop_customer_service_intro',
                      defaultText:
                          'Tell us what you need help with. Include an order number for order or return questions.',
                      style: TextStyle(color: StoreColors.foregroundSubtle),
                    ),
                    const SizedBox(height: 32),
                    if (state.submission case Some(:final value))
                      CustomerServiceSuccess(
                        submission: value,
                        onAnother: _another,
                      )
                    else
                      CustomerServiceForm(
                        formKey: _formKey,
                        name: _name,
                        email: _email,
                        orderReference: _orderReference,
                        subject: _subject,
                        message: _message,
                        state: state,
                        onSubmit: _submit,
                      ),
                  ],
                ),
              ),
            ),
          ),
          const StoreFooter(),
        ],
      ),
    );
  }
}

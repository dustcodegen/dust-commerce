import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

import 'customer_service_failure.dart';
import 'customer_service_field.dart';
import 'customer_service_validation.dart';

/// Customer-service fields and submission action.
final class CustomerServiceForm extends StatelessWidget {
  /// Creates the form from state-owned controllers.
  const CustomerServiceForm({
    required this.formKey,
    required this.name,
    required this.email,
    required this.orderReference,
    required this.subject,
    required this.message,
    required this.state,
    required this.onSubmit,
    super.key,
  });

  /// Parent-owned form validation key.
  final GlobalKey<FormState> formKey;

  /// Contact name controller.
  final TextEditingController name;

  /// Reply email controller.
  final TextEditingController email;

  /// Optional related order controller.
  final TextEditingController orderReference;

  /// Request subject controller.
  final TextEditingController subject;

  /// Request message controller.
  final TextEditingController message;

  /// Current submission state.
  final CustomerServiceState state;

  /// Validates and submits the form.
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) => AutofillGroup(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomerServiceField(
                controller: name,
                label: context.tr(
                  'shop_customer_service_name',
                  defaultText: 'Name',
                ),
                enabled: !state.isBusy,
                autofillHints: const [AutofillHints.name],
                maxLength: 120,
                textInputAction: TextInputAction.next,
                validator: (value) => customerServiceRequired(
                  context,
                  value,
                  maximum: 120,
                ),
              ),
              const SizedBox(height: 16),
              CustomerServiceField(
                controller: email,
                label: context.tr(
                  'shop_customer_service_email',
                  defaultText: 'Email',
                ),
                enabled: !state.isBusy,
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                maxLength: 254,
                textInputAction: TextInputAction.next,
                validator: (value) => customerServiceEmail(context, value),
              ),
              const SizedBox(height: 16),
              CustomerServiceField(
                controller: orderReference,
                label: context.tr(
                  'shop_customer_service_order',
                  defaultText: 'Order number (optional)',
                ),
                enabled: !state.isBusy,
                maxLength: 255,
                textInputAction: TextInputAction.next,
                validator: (value) => customerServiceOptional(
                  context,
                  value,
                  maximum: 255,
                ),
              ),
              const SizedBox(height: 16),
              CustomerServiceField(
                controller: subject,
                label: context.tr(
                  'shop_customer_service_subject',
                  defaultText: 'Subject',
                ),
                enabled: !state.isBusy,
                maxLength: 160,
                textInputAction: TextInputAction.next,
                validator: (value) => customerServiceRequired(
                  context,
                  value,
                  maximum: 160,
                ),
              ),
              const SizedBox(height: 16),
              CustomerServiceField(
                controller: message,
                label: context.tr(
                  'shop_customer_service_message',
                  defaultText: 'Message',
                ),
                enabled: !state.isBusy,
                maxLength: 5000,
                minLines: 6,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                validator: (value) => customerServiceRequired(
                  context,
                  value,
                  maximum: 5000,
                ),
              ),
              if (state.status == CustomerServiceStatus.failed) ...[
                const SizedBox(height: 8),
                CustomerServiceFailureText(failure: state.failure),
              ],
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: state.isBusy ? null : onSubmit,
                  child: state.isBusy
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const TranslatedText(
                          'shop_customer_service_send',
                          defaultText: 'Send message',
                        ),
                ),
              ),
            ],
          ),
        ),
      );
}

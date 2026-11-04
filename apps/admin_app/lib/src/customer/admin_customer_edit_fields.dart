part of 'admin_customer_edit_frame.dart';

final class _AdminCustomerEditHeader extends StatelessWidget {
  const _AdminCustomerEditHeader({
    required this.busy,
    required this.onClose,
  });

  final bool busy;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
        padding: const EdgeInsets.only(left: 24, right: 12),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(children: [
          Expanded(
            child: Text(
              'Edit customer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: busy ? null : onClose,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ]),
      );
}

final class _AdminCustomerEditField extends StatelessWidget {
  const _AdminCustomerEditField({
    required this.controller,
    required this.enabled,
    required this.label,
    this.tooltip,
    this.validator,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String? tooltip;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Tooltip(
            message: tooltip ?? '',
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              validator: validator,
              keyboardType:
                  label == 'Email' ? TextInputType.emailAddress : null,
              autofillHints: const [],
            ),
          ),
        ]),
      );
}

String? _emailError(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty || !email.contains('@') || email.endsWith('@')) {
    return 'Enter a valid email';
  }
  return null;
}

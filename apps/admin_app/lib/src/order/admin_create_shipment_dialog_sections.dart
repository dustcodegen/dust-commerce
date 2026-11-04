part of 'admin_create_shipment_dialog.dart';

/// Responsive three-field carrier-label row from Medusa's shipment form.
final class AdminShipmentTrackingRow extends StatelessWidget {
  /// Creates one editable tracking row.
  const AdminShipmentTrackingRow({
    required this.controllers,
    required this.showDesktopLabels,
    required this.enabled,
    super.key,
  });

  /// Controllers owned by the parent form.
  final AdminShipmentLabelControllers controllers;

  /// Whether fields accept edits.
  final bool enabled;

  /// Medusa hides repeated labels only in the desktop three-column layout.
  final bool showDesktopLabels;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 640;
          final fields = [
            _AdminShipmentTextField(
              label: 'Tracking number',
              hint: '123-456-789',
              controller: controllers.trackingNumber,
              enabled: enabled,
              showLabel: compact || showDesktopLabels,
            ),
            _AdminShipmentTextField(
              label: 'Tracking URL',
              hint: 'https://example.com/tracking/123',
              controller: controllers.trackingUrl,
              enabled: enabled,
              showLabel: compact || showDesktopLabels,
            ),
            _AdminShipmentTextField(
              label: 'Label URL',
              hint: 'https://example.com/label/123',
              controller: controllers.labelUrl,
              enabled: enabled,
              showLabel: compact || showDesktopLabels,
            ),
          ];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: compact
                ? Column(children: fields)
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var index = 0; index < fields.length; index++) ...[
                        Expanded(child: fields[index]),
                        if (index < fields.length - 1)
                          const SizedBox(width: 16),
                      ],
                    ],
                  ),
          );
        },
      );
}

final class _AdminShipmentTextField extends StatelessWidget {
  const _AdminShipmentTextField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.enabled,
    required this.showLabel,
  });

  final TextEditingController controller;
  final bool enabled;
  final String hint;
  final String label;
  final bool showLabel;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            labelText: showLabel ? label : null,
            hintText: hint,
          ),
        ),
      );
}

final class _AdminShipmentNotificationField extends StatelessWidget {
  const _AdminShipmentNotificationField();

  @override
  Widget build(BuildContext context) => SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Send notification'),
        subtitle: const Text(
          'Unavailable until a customer notification provider is configured.',
        ),
        value: false,
        onChanged: null,
      );
}

final class _AdminShipmentFormMessage extends StatelessWidget {
  const _AdminShipmentFormMessage({
    required this.validation,
    required this.saveFailure,
  });

  final Option<String> saveFailure;
  final String validation;

  @override
  Widget build(BuildContext context) {
    final message = validation.isNotEmpty
        ? validation
        : switch (saveFailure) {
            Some(:final value) => value,
            None() => '',
          };
    return message.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
  }
}

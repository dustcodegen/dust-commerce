import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped frame for customer-group name editing.
final class AdminCustomerGroupEditFrame extends StatelessWidget {
  /// Creates the drawer frame with one name field and sticky actions.
  const AdminCustomerGroupEditFrame({
    required this.busy,
    required this.failure,
    required this.formKey,
    required this.name,
    required this.onCancel,
    required this.onSave,
    super.key,
  });

  /// Whether the update request is active.
  final bool busy;

  /// Display-safe request failure.
  final Option<String> failure;

  /// Name form validation boundary.
  final GlobalKey<FormState> formKey;

  /// Current merchant-facing name.
  final TextEditingController name;

  /// Closes the drawer without updating.
  final VoidCallback onCancel;

  /// Submits the validated name.
  final VoidCallback onSave;

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
              _CustomerGroupEditHeader(busy: busy, onClose: onCancel),
              Expanded(
                child: Form(
                  key: formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text('Name',
                          style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: name,
                        autofocus: true,
                        enabled: !busy,
                        validator: _validateCustomerGroupName,
                        onFieldSubmitted: (_) => onSave(),
                      ),
                      _CustomerGroupEditFailure(failure: failure),
                    ],
                  ),
                ),
              ),
              _CustomerGroupEditFooter(
                busy: busy,
                onCancel: onCancel,
                onSave: onSave,
              ),
            ]),
          ),
        ),
      );
}

final class _CustomerGroupEditHeader extends StatelessWidget {
  const _CustomerGroupEditHeader({
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
              'Edit Customer Group',
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

final class _CustomerGroupEditFailure extends StatelessWidget {
  const _CustomerGroupEditFailure({required this.failure});

  final Option<String> failure;

  @override
  Widget build(BuildContext context) => switch (failure) {
        Some(:final value) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        None() => const SizedBox.shrink(),
      };
}

final class _CustomerGroupEditFooter extends StatelessWidget {
  const _CustomerGroupEditFooter({
    required this.busy,
    required this.onCancel,
    required this.onSave,
  });

  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          OutlinedButton(
            onPressed: busy ? null : onCancel,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: busy ? null : onSave,
            child: busy
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ]),
      );
}

String? _validateCustomerGroupName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Name is required';
  if (name.length > 255) return 'Use at most 255 characters';
  return null;
}

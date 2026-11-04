import 'package:admin_app/src/core/admin_route_focus_chrome.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_create_fields.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_create_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Full-screen customer-group form matching Medusa's route-focus source.
final class AdminCustomerGroupCreateForm extends StatefulWidget {
  /// Creates the focused customer-group form.
  const AdminCustomerGroupCreateForm({super.key});

  @override
  State<AdminCustomerGroupCreateForm> createState() =>
      _AdminCustomerGroupCreateFormState();
}

final class _AdminCustomerGroupCreateFormState
    extends State<AdminCustomerGroupCreateForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.readAdminCustomerGroupCreateViewModel().clearFailure();
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminCustomerGroupCreateViewModel().value;
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
                    padding: const EdgeInsets.fromLTRB(24, 72, 24, 24),
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
                                'Create Customer Group',
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Create a new customer group to segment your customers.',
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
                              AdminCustomerGroupCreateFields(
                                name: _name,
                                enabled: !state.isBusy,
                                onSubmit: _submit,
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final created =
        await context.readAdminCustomerGroupCreateViewModel().create(
              AdminCreateCustomerGroup(
                name: _name.text,
                metadataValue: null,
              ),
            );
    if (!mounted) return;
    if (created case Some(:final value)) Navigator.of(context).pop(value);
  }
}

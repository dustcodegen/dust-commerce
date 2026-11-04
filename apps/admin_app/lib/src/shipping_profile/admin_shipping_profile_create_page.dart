import 'package:admin_app/src/shipping_profile/admin_shipping_profile_create_chrome.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_create_fields.dart';
import 'package:admin_app/src/shipping_profile/admin_shipping_profile_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's full-screen shipping-profile creation surface.
Future<AdminShippingProfile?> showAdminShippingProfileCreatePage(
  BuildContext context,
) =>
    showGeneralDialog<AdminShippingProfile>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Create shipping profile',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) => const AdminShippingProfileCreateForm(),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

/// Owns profile input and submission without hiding UI in methods.
final class AdminShippingProfileCreateForm extends StatefulWidget {
  /// Creates an empty profile form.
  const AdminShippingProfileCreateForm({super.key});

  @override
  State<AdminShippingProfileCreateForm> createState() =>
      _AdminShippingProfileCreateFormState();
}

final class _AdminShippingProfileCreateFormState
    extends State<AdminShippingProfileCreateForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _type = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminShippingProfileViewModel().clearFailure();
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _type.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminShippingProfileViewModel().value;
    return AdminShippingProfileCreateFrame(
      busy: _busy,
      onCancel: Navigator.of(context).pop,
      onSave: _save,
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
          children: [
            Center(
              child: SizedBox(
                width: 720,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Shipping Profile',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create a new shipping profile to group products with '
                      'similar shipping requirements.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 32),
                    AdminShippingProfileCreateFields(
                      name: _name,
                      type: _type,
                      busy: _busy,
                      validator: _validate,
                      onSubmitted: _save,
                    ),
                    if (state.failure case Some(:final value)) ...[
                      const SizedBox(height: 16),
                      Text(
                        value,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validate(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'This field is required';
    if (input.length > 255) return 'Use at most 255 characters';
    return null;
  }

  Future<void> _save() async {
    if (_busy || !(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final created = await context.readAdminShippingProfileViewModel().create(
          AdminCreateShippingProfile(name: _name.text, type: _type.text),
        );
    if (!mounted) return;
    switch (created) {
      case Some(:final value):
        Navigator.of(context).pop(value);
      case None():
        setState(() => _busy = false);
    }
  }
}

import 'package:admin_app/src/promotion/admin_promotion_create_chrome.dart';
import 'package:admin_app/src/promotion/admin_promotion_create_fields.dart';
import 'package:admin_app/src/promotion/admin_promotion_create_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens Medusa's focused promotion creation surface.
Future<AdminPromotion?> showAdminPromotionCreatePage(BuildContext context) =>
    showGeneralDialog<AdminPromotion>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Create promotion',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) => const AdminPromotionCreatePage(),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

/// Standalone Admin promotion form.
final class AdminPromotionCreatePage extends StatefulWidget {
  /// Creates the focused form route.
  const AdminPromotionCreatePage({super.key});

  @override
  State<AdminPromotionCreatePage> createState() =>
      _AdminPromotionCreatePageState();
}

final class _AdminPromotionCreatePageState
    extends State<AdminPromotionCreatePage> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _value = TextEditingController();
  final _currency = TextEditingController();
  final _usageLimit = TextEditingController();
  String _type = 'percentage';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.readAdminPromotionCreateViewModel().clearFailure();
    });
  }

  @override
  void dispose() {
    _code.dispose();
    _value.dispose();
    _currency.dispose();
    _usageLimit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminPromotionCreateViewModel().value;
    return PopScope(
      canPop: !state.isBusy,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdminPromotionCreateHeader(busy: state.isBusy),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: 768,
                    child: Form(
                      key: _form,
                      child: ListView(
                        padding: const EdgeInsets.all(40),
                        children: [
                          Text(
                            'Create Promotion',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                              'Add a discount code for storefront carts.'),
                          const SizedBox(height: 32),
                          AdminPromotionCreateFields(
                            busy: state.isBusy,
                            code: _code,
                            currency: _currency,
                            type: _type,
                            usageLimit: _usageLimit,
                            value: _value,
                            onTypeChanged: (value) =>
                                setState(() => _type = value),
                          ),
                          if (state.failure
                              case Some(value: final message)) ...[
                            const SizedBox(height: 16),
                            Text(
                              message,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              AdminPromotionCreateFooter(
                busy: state.isBusy,
                onCancel: Navigator.of(context).pop,
                onCreate: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final usageText = _usageLimit.text.trim();
    final created = await context.readAdminPromotionCreateViewModel().create(
          AdminCreatePromotion(
            code: _code.text,
            type: _type,
            value: int.parse(_value.text.trim()),
            currencyCodeValue: _type == 'fixed' ? _currency.text : null,
            startsAtValue: null,
            endsAtValue: null,
            usageLimitValue: usageText.isEmpty ? null : int.parse(usageText),
          ),
        );
    if (!mounted) return;
    if (created case Some(value: final promotion)) {
      Navigator.of(context).pop(promotion);
    }
  }
}

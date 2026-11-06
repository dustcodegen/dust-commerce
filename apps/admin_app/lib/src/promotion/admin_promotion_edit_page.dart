import 'package:admin_app/src/promotion/admin_promotion_create_chrome.dart';
import 'package:admin_app/src/promotion/admin_promotion_create_fields.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_state.dart';
import 'package:admin_app/src/promotion/admin_promotion_detail_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Opens the focused Admin promotion editor.
Future<AdminPromotion?> showAdminPromotionEditPage(
  BuildContext context,
  AdminPromotion promotion,
) =>
    showGeneralDialog<AdminPromotion>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'Edit promotion',
      transitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) =>
          AdminPromotionEditPage(promotion: promotion),
      transitionBuilder: (context, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

/// Standalone Admin promotion edit form.
final class AdminPromotionEditPage extends StatefulWidget {
  /// Creates the focused editor.
  const AdminPromotionEditPage({required this.promotion, super.key});

  /// Existing server-owned promotion values.
  final AdminPromotion promotion;

  @override
  State<AdminPromotionEditPage> createState() => _AdminPromotionEditPageState();
}

final class _AdminPromotionEditPageState extends State<AdminPromotionEditPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _code;
  late final TextEditingController _value;
  late final TextEditingController _currency;
  late final TextEditingController _usageLimit;
  late String _type;

  @override
  void initState() {
    super.initState();
    final promotion = widget.promotion;
    _code = TextEditingController(text: promotion.code);
    _value = TextEditingController(text: '${promotion.value}');
    _currency = TextEditingController(
      text: promotion.currencyCodeValue?.toUpperCase() ?? '',
    );
    _usageLimit = TextEditingController(
      text: promotion.usageLimitValue?.toString() ?? '',
    );
    _type = promotion.type;
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
    final state = context.watchAdminPromotionDetailViewModel().value;
    final busy = state.status == AdminPromotionDetailStatus.updating;
    return PopScope(
      canPop: !busy,
      child: Material(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdminPromotionCreateHeader(
                busy: busy,
                title: 'Edit Promotion',
              ),
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
                            'Edit Promotion',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                              'Update the discount used by storefront carts.'),
                          const SizedBox(height: 32),
                          AdminPromotionCreateFields(
                            busy: busy,
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
                busy: busy,
                actionLabel: 'Save',
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
    final updated = await context.readAdminPromotionDetailViewModel().update(
          widget.promotion.id,
          AdminUpdatePromotion(
            code: _code.text,
            type: _type,
            value: int.parse(_value.text.trim()),
            currencyCodeValue: _type == 'fixed' ? _currency.text : null,
            startsAtValue: widget.promotion.startsAtValue,
            endsAtValue: widget.promotion.endsAtValue,
            usageLimitValue: usageText.isEmpty ? null : int.parse(usageText),
          ),
        );
    if (!mounted) return;
    if (updated case Some(value: final promotion)) {
      Navigator.of(context).pop(promotion);
    }
  }
}

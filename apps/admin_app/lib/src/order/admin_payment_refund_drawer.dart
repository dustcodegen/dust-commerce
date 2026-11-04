import 'package:admin_app/src/core/admin_money.dart';
import 'package:admin_app/src/order/admin_order_detail_view_model.dart';
import 'package:admin_app/src/order/admin_payment_refund_fields.dart';
import 'package:admin_app/src/order/admin_payment_refund_state.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

part 'admin_payment_refund_drawer_chrome.dart';

/// Opens Medusa's right-side refund decision flow for one captured payment.
Future<bool?> showAdminPaymentRefundDrawer(
  BuildContext context,
  AdminOrderDetail order,
) async {
  await context.readAdminOrderDetailViewModel().loadRefundReasons();
  if (!context.mounted) return null;
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close refund payment',
    barrierColor: Colors.black.withValues(alpha: 0.24),
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (context, _, __) => Padding(
      padding: const EdgeInsets.all(8),
      child: Align(
        alignment: Alignment.centerRight,
        child: _AdminPaymentRefundDrawer(order: order),
      ),
    ),
    transitionBuilder: (context, animation, _, child) => SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      )),
      child: child,
    ),
  );
}

final class _AdminPaymentRefundDrawer extends StatefulWidget {
  const _AdminPaymentRefundDrawer({required this.order});

  final AdminOrderDetail order;

  @override
  State<_AdminPaymentRefundDrawer> createState() =>
      _AdminPaymentRefundDrawerState();
}

final class _AdminPaymentRefundDrawerState
    extends State<_AdminPaymentRefundDrawer> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _amount;
  final _note = TextEditingController();
  Option<String> _reasonId = const None();

  int get _refundable => switch (widget.order.paymentAmount) {
        Some(:final value) => value - widget.order.paymentRefundedAmount,
        None() => 0,
      };

  @override
  void initState() {
    super.initState();
    _amount = TextEditingController(
      text: formatMinorUnits(_refundable, widget.order.currencyCode),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  String? _validateAmount(String? value) {
    final parsed = parseMinorUnits(value ?? '', widget.order.currencyCode);
    if (parsed == null || parsed <= 0) return 'Enter a positive amount';
    if (parsed > _refundable) return 'Amount exceeds refundable balance';
    return null;
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final paymentId = switch (widget.order.paymentId) {
      Some(:final value) => value,
      None() => null,
    };
    if (paymentId == null) return;
    final note = _note.text.trim();
    final saved = await context.readAdminOrderDetailViewModel().refundPayment(
          widget.order.id,
          paymentId,
          AdminRefundPayment(
            amountValue:
                parseMinorUnits(_amount.text, widget.order.currencyCode),
            refundReasonIdValue: switch (_reasonId) {
              Some(:final value) => value,
              None() => null,
            },
            noteValue: note.isEmpty ? null : note,
          ),
        );
    if (!saved || !mounted) return;
    Navigator.pop(context, true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment refunded successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final refund = context.watchAdminOrderDetailViewModel().value.refund;
    final busy = refund.status == AdminPaymentRefundStatus.saving;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 16,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width.clamp(0, 560).toDouble(),
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AdminPaymentRefundHeader(
              busy: busy,
              onClose: Navigator.of(context).pop,
            ),
            Expanded(
              child: Form(
                key: _form,
                child: AdminPaymentRefundFields(
                  amount: _amount,
                  note: _note,
                  currencyCode: widget.order.currencyCode,
                  refundableAmount: _refundable,
                  refund: refund,
                  selectedReasonId: _reasonId,
                  busy: busy,
                  validateAmount: _validateAmount,
                  onReasonChanged: (value) => setState(() {
                    _reasonId = value == null ? const None() : Some(value);
                  }),
                ),
              ),
            ),
            _AdminPaymentRefundFooter(
              busy: busy,
              onCancel: Navigator.of(context).pop,
              onSave: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

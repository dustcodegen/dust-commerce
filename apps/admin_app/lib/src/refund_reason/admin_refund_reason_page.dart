import 'package:admin_app/src/refund_reason/admin_refund_reason_dialog.dart';
import 'package:admin_app/src/refund_reason/admin_refund_reason_rows.dart';
import 'package:admin_app/src/refund_reason/admin_refund_reason_view_model.dart';
import 'package:admin_app/src/refund_reason/admin_refund_reason_widgets.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:flutter/material.dart';

/// Protected merchant settings route for refund reasons.
final class AdminRefundReasonPage extends StatefulWidget {
  /// Creates the refund-reason route.
  const AdminRefundReasonPage({required this.searchFocus, super.key});

  /// Focus target shared with the Admin search command.
  final FocusNode searchFocus;

  @override
  State<AdminRefundReasonPage> createState() => _AdminRefundReasonPageState();
}

final class _AdminRefundReasonPageState extends State<AdminRefundReasonPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchAdminRefundReasonViewModel().value;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            shadowColor: const Color(0x16000000),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminRefundReasonHeader(onCreate: _create),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                AdminRefundReasonToolbar(
                  controller: _search,
                  focusNode: widget.searchFocus,
                  onChanged: (value) =>
                      context.readAdminRefundReasonViewModel().load(
                            query: value,
                            offset: 0,
                          ),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                AdminRefundReasonTable(
                  state: state,
                  onEdit: _edit,
                  onRetire: _retire,
                  onRetry: context.readAdminRefundReasonViewModel().load,
                ),
                AdminRefundReasonPagination(
                  state: state,
                  onPrevious: context.readAdminRefundReasonViewModel().previous,
                  onNext: context.readAdminRefundReasonViewModel().next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _create() async {
    final result = await showDialog<AdminRefundReasonFormResult>(
      context: context,
      builder: (context) => const AdminRefundReasonDialog(),
    );
    if (result == null || !mounted) return;
    await context.readAdminRefundReasonViewModel().save(
          label: result.label,
          code: result.code,
          description: result.description,
        );
  }

  Future<void> _edit(AdminRefundReason reason) async {
    final result = await showDialog<AdminRefundReasonFormResult>(
      context: context,
      builder: (context) => AdminRefundReasonDialog(reason: reason),
    );
    if (result == null || !mounted) return;
    await context.readAdminRefundReasonViewModel().save(
          id: reason.id,
          label: result.label,
          code: result.code,
          description: result.description,
        );
  }

  Future<void> _retire(AdminRefundReason reason) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retire refund reason?'),
        content: Text('"${reason.label}" will disappear from new refunds.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Retire'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.readAdminRefundReasonViewModel().retire(reason.id);
    }
  }
}

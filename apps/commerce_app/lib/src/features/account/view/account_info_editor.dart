import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

const _sourceTextSmall = TextStyle(fontSize: 12, height: 20 / 12);

/// Expandable account-information editor translated from Medusa AccountInfo.
final class AccountInfoEditor extends StatefulWidget {
  /// Creates one editable account-information row.
  const AccountInfoEditor({
    required this.label,
    required this.currentInfo,
    required this.editor,
    required this.onSave,
    this.onCancel,
    this.busy = false,
    this.enabled = true,
    this.error,
    super.key,
  });

  /// Current value rendered while collapsed.
  final Widget currentInfo;

  /// Form fields rendered while expanded.
  final Widget editor;

  /// Whether the edit control is usable.
  final bool enabled;

  /// Display-safe save failure.
  final String? error;

  /// Public field label.
  final String label;

  /// Saves the editor and reports whether the server accepted it.
  final Future<bool> Function() onSave;

  /// Clears sensitive or draft-only values when editing is cancelled.
  final VoidCallback? onCancel;

  /// Whether this editor's request is running.
  final bool busy;

  @override
  State<AccountInfoEditor> createState() => _AccountInfoEditorState();
}

class _AccountInfoEditorState extends State<AccountInfoEditor> {
  var _open = false;
  var _success = false;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label.toUpperCase(),
                      style: _sourceTextSmall,
                    ),
                    DefaultTextStyle.merge(
                      style: _sourceTextSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      child: widget.currentInfo,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 100,
                child: OutlinedButton(
                  onPressed: widget.enabled && !widget.busy ? _toggle : null,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(100, 25),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    textStyle: _sourceTextSmall,
                  ),
                  child: Text(
                    _open
                        ? context.tr('shop_cancel', defaultText: 'Cancel')
                        : context.tr('shop_edit', defaultText: 'Edit'),
                  ),
                ),
              ),
            ],
          ),
          if (_success)
            _StatusBadge(
              message: context.tr(
                'shop_account_updated',
                defaultText: '{label} updated succesfully',
                args: {'label': widget.label},
              ),
              success: true,
            ),
          if (_open && widget.error != null)
            _StatusBadge(message: widget.error!, success: false),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        widget.editor,
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) => Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: MediaQuery.sizeOf(context).width < 640
                                  ? constraints.maxWidth
                                  : 140,
                              child: FilledButton(
                                onPressed: widget.busy ? null : _save,
                                style: FilledButton.styleFrom(
                                  textStyle: _sourceTextSmall.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                child: widget.busy
                                    ? const SizedBox.square(
                                        dimension: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : TranslatedText(
                                        'shop_save_changes',
                                        defaultText: 'Save changes',
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      );

  void _toggle() {
    final cancelling = _open;
    setState(() {
      _open = !_open;
      _success = false;
    });
    if (cancelling) widget.onCancel?.call();
  }

  Future<void> _save() async {
    final saved = await widget.onSave();
    if (!mounted || !saved) return;
    setState(() {
      _open = false;
      _success = true;
    });
  }
}

final class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.message, required this.success});

  final String message;
  final bool success;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: success ? const Color(0xfff0fdf4) : const Color(0xfffff1f2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: success ? const Color(0xff166534) : const Color(0xffbe123c),
            fontSize: 12,
            height: 20 / 12,
          ),
        ),
      );
}

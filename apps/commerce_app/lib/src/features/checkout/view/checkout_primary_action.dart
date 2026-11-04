import 'package:commerce_app/src/core/store_theme.dart';
import 'package:flutter/material.dart';

/// Shared Medusa large action used to progress through checkout.
final class CheckoutPrimaryAction extends StatelessWidget {
  /// Creates one localized checkout progression action.
  const CheckoutPrimaryAction({
    required this.label,
    required this.onPressed,
    this.busy = false,
    super.key,
  });

  /// Whether the action should show bounded progress instead of its label.
  final bool busy;

  /// Localized customer-facing action copy.
  final String label;

  /// Runs the step mutation, or disables the action when absent.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !busy;
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: enabled ? StoreColors.buttonPrimary : const Color(0xff808080),
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: BorderRadius.circular(6),
            hoverColor: StoreColors.buttonPrimaryHover,
            child: SizedBox(
              height: 48,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (busy)
                      const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          color: StoreColors.base,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Text(
                        label,
                        style: TextStyle(
                          color: enabled
                              ? StoreColors.base
                              : const Color(0xffbfbfbf),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

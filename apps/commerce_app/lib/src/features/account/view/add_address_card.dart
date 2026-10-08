import 'package:commerce_app/commerce_app.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-shaped card that opens a new-address dialog.
final class AddAddressCard extends StatelessWidget {
  /// Creates the new-address action.
  const AddAddressCard({required this.onTap, required this.enabled, super.key});

  /// Whether region-backed country options are ready.
  final bool enabled;

  /// Opens the address dialog.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color =
        enabled ? StoreColors.foreground : StoreColors.foregroundMuted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 220),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(color: StoreColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TranslatedText(
                'shop_account_new_address',
                defaultText: 'New address',
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  height: 24 / 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.add, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

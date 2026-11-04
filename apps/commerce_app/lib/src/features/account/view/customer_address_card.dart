import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_shared/commerce_shared.dart';
import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';

/// Source-shaped saved-address card with live edit and remove actions.
final class CustomerAddressCard extends StatelessWidget {
  /// Creates a card for [address].
  const CustomerAddressCard({
    required this.address,
    required this.onEdit,
    required this.busy,
    super.key,
  });

  /// Saved customer address.
  final CustomerAddressView address;

  /// Whether another address mutation is running.
  final bool busy;

  /// Opens the matching edit dialog.
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) => Container(
        height: 220,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: StoreColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${address.firstName} ${address.lastName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (address.company case final company?)
              Text(company, style: _companyStyle),
            const SizedBox(height: 8),
            Text('${address.line1}${_line2(address.line2)}'),
            Text('${address.postalCode}, ${address.city}'),
            Text(
                '${_province(address.province)}${address.countryCode.toUpperCase()}'),
            const Spacer(),
            Row(
              children: [
                _AddressCardAction(
                  onPressed: busy ? null : onEdit,
                  icon: const Icon(Icons.edit_square, size: 16),
                  label: TranslatedText(
                    'shop_edit',
                    defaultText: 'Edit',
                  ),
                ),
                const SizedBox(width: 16),
                _AddressCardAction(
                  onPressed: busy
                      ? null
                      : () =>
                          context.readAddressBookViewModel().delete(address.id),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: TranslatedText(
                    'shop_remove',
                    defaultText: 'Remove',
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  static String _line2(String? value) => value == null ? '' : ', $value';

  static String _province(String? value) => value == null ? '' : '$value, ';
}

final class _AddressCardAction extends StatelessWidget {
  const _AddressCardAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final Widget icon;
  final Widget label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final color =
        enabled ? StoreColors.foreground : StoreColors.foregroundMuted;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        iconColor: color,
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 12, height: 20 / 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconTheme.merge(data: IconThemeData(color: color), child: icon),
          const SizedBox(width: 8),
          label,
        ],
      ),
    );
  }
}

const _companyStyle = TextStyle(
  color: StoreColors.foreground,
  fontSize: 13,
  height: 20 / 13,
);

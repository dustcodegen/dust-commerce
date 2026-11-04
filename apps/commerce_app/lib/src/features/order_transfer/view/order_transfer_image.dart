import 'package:dust_flutter/i18n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Exact transfer illustration from the pinned MIT-licensed DTC source.
final class OrderTransferImage extends StatelessWidget {
  /// Creates the source illustration at its authored dimensions.
  const OrderTransferImage({super.key});

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        'assets/images/order-transfer.svg',
        width: 280,
        height: 181,
        semanticsLabel: context.tr(
          'shop_order_transfer_illustration',
          defaultText: 'Order ownership transfer',
        ),
      );
}

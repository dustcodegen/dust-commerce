import 'package:commerce_app/commerce_app.dart';
import 'package:commerce_app/route.dart';
import 'package:flutter/material.dart';

import 'order_transfer_content.dart';

/// Public Medusa-compatible order-transfer decision route.
@AppRoute('/order/:id/transfer/:token', name: 'orderTransfer', guards: [])
final class OrderTransferPage extends StatefulWidget {
  /// Creates the neutral decision page from an emailed capability URL.
  const OrderTransferPage({
    required this.id,
    required this.token,
    super.key,
  });

  /// Order identifier named by the transfer link.
  final String id;

  /// Single-use capability passed only to a deliberate decision action.
  final String token;

  @override
  State<OrderTransferPage> createState() => _OrderTransferPageState();
}

final class _OrderTransferPageState extends State<OrderTransferPage> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    _resetAfterFrame();
  }

  void _resetAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.readOrderTransferViewModel().reset();
      setState(() => _ready = true);
    });
  }

  @override
  void didUpdateWidget(OrderTransferPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id == widget.id && oldWidget.token == widget.token) return;
    _ready = false;
    _resetAfterFrame();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchOrderTransferViewModel().value;
    return StoreScaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) => Center(
                child: FractionallySizedBox(
                  widthFactor: constraints.maxWidth >= 640 ? 0.4 : 1,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      constraints.maxWidth >= 640 ? 0 : 24,
                      40,
                      constraints.maxWidth >= 640 ? 0 : 24,
                      80,
                    ),
                    child: _ready
                        ? OrderTransferContent(
                            orderId: widget.id,
                            token: widget.token,
                            state: state,
                          )
                        : const SizedBox(height: 500),
                  ),
                ),
              ),
            ),
            const StoreFooter(),
          ],
        ),
      ),
    );
  }
}

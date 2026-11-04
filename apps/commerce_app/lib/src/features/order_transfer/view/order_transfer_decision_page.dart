import 'dart:async';

import 'package:commerce_app/commerce_app.dart';
import 'package:flutter/material.dart';

import 'order_transfer_decision_result.dart';

/// Shared automatic decision view for transfer capability routes.
final class OrderTransferDecisionView extends StatefulWidget {
  /// Creates a capability decision view.
  const OrderTransferDecisionView({
    required this.action,
    required this.id,
    required this.token,
    super.key,
  });

  /// Decision sent to the transfer endpoint.
  final OrderTransferAction action;

  /// Order identifier named by the capability URL.
  final String id;

  /// Single-use capability sent only to the decision endpoint.
  final String token;

  @override
  State<OrderTransferDecisionView> createState() =>
      _OrderTransferDecisionViewState();
}

final class _OrderTransferDecisionViewState
    extends State<OrderTransferDecisionView> {
  var _started = false;
  var _timedOut = false;
  Timer? _timeout;

  @override
  void initState() {
    super.initState();
    _armTimeout();
    _submitAfterFrame();
  }

  @override
  void didUpdateWidget(OrderTransferDecisionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.id == widget.id &&
        oldWidget.token == widget.token &&
        oldWidget.action == widget.action) {
      return;
    }
    _started = false;
    _timedOut = false;
    _timeout?.cancel();
    _armTimeout();
    _submitAfterFrame();
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watchOrderTransferViewModel().value;
    final pending = !_timedOut &&
        (!_started ||
            state.status == OrderTransferActionStatus.idle ||
            state.status == OrderTransferActionStatus.pending);
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OrderTransferImage(),
                        const SizedBox(height: 16),
                        if (pending)
                          const Center(child: CircularProgressIndicator())
                        else if (state.status ==
                            OrderTransferActionStatus.succeeded)
                          OrderTransferDecisionSuccess(
                            action: widget.action,
                            orderId: widget.id,
                          )
                        else
                          OrderTransferDecisionFailure(
                            action: widget.action,
                            failure: state.failure,
                          ),
                      ],
                    ),
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

  void _submitAfterFrame() {
    scheduleMicrotask(() {
      if (!mounted || _started) return;
      final viewModel = context.readOrderTransferViewModel();
      viewModel.reset();
      setState(() => _started = true);
      final request = widget.action == OrderTransferAction.accept
          ? viewModel.accept(widget.id, widget.token)
          : viewModel.decline(widget.id, widget.token);
      unawaited(
        request.whenComplete(() {
          _timeout?.cancel();
          if (mounted) setState(() {});
        }),
      );
    });
  }

  /// Fails closed when a dead capability request never resolves.
  void _armTimeout() {
    _timeout = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _timedOut = true);
    });
  }
}

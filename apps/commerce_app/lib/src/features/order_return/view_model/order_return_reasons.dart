part of 'order_return_view_model.dart';

/// Optional return-reason discovery and selection operations.
extension OrderReturnReasons on OrderReturnViewModel {
  /// Selects or clears one active reason for an already-selected item.
  void setReason(String itemId, Option<String> reasonId) {
    if (state.status == OrderReturnRequestStatus.submitting ||
        !state.quantities.containsKey(itemId)) {
      return;
    }
    final reasons = {...state.reasonIds};
    switch (reasonId) {
      case Some(:final value)
          when state.reasons.any((reason) => reason.id == value):
        reasons[itemId] = value;
      case None():
        reasons.remove(itemId);
      case Some():
        return;
    }
    _edit(reasonIds: reasons);
  }

  /// Loads every bounded page of active Store return reasons.
  Future<void> loadReasons() async {
    if (state.orderId case None()) return;
    if (state.reasonStatus == OrderReturnReasonStatus.loading) return;
    final generation = _generation;
    _set(state.copyWith(reasonStatus: OrderReturnReasonStatus.loading));
    try {
      final reasons = <ReturnReasonView>[];
      final ids = <String>{};
      var offset = 0;
      var count = 1;
      while (offset < count) {
        final page = await args.api.returnReasons(limit: 100, offset: offset);
        if (generation != _generation) return;
        if (page.offset != offset ||
            (page.returnReasons.isEmpty && offset < page.count)) {
          throw StateError('Invalid return-reason page');
        }
        for (final reason in page.returnReasons) {
          if (!ids.add(reason.id)) {
            throw StateError('Duplicate return reason');
          }
          reasons.add(reason);
        }
        offset += page.returnReasons.length;
        count = page.count;
      }
      _set(state.copyWith(
        reasons: reasons,
        reasonIds: const {},
        reasonStatus: OrderReturnReasonStatus.loaded,
      ));
    } on Object {
      if (generation != _generation) return;
      _set(state.copyWith(
        reasons: const [],
        reasonIds: const {},
        reasonStatus: OrderReturnReasonStatus.failed,
      ));
    }
  }
}

import 'package:admin_app/src/core/admin_route_focus_chrome.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_candidate_content.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_candidate_view_model.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_membership_view_model.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Full-screen candidate selector matching Medusa's Add Customers route.
final class AdminCustomerGroupAddForm extends StatefulWidget {
  /// Creates a selector for one active customer group.
  const AdminCustomerGroupAddForm({
    required this.customerGroupId,
    required this.existingCustomerIds,
    super.key,
  });

  /// Stable group receiving the selected customers.
  final String customerGroupId;

  /// Active members shown checked and disabled in the candidate table.
  final Set<String> existingCustomerIds;

  @override
  State<AdminCustomerGroupAddForm> createState() =>
      _AdminCustomerGroupAddFormState();
}

final class _AdminCustomerGroupAddFormState
    extends State<AdminCustomerGroupAddForm> {
  final TextEditingController _search = TextEditingController();
  final Set<String> _selected = {};
  Option<String> _selectionFailure = const None();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.readAdminCustomerGroupMembershipViewModel().reset();
      context.readAdminCustomerGroupCandidateViewModel().load(offset: 0);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidates =
        context.watchAdminCustomerGroupCandidateViewModel().value;
    final membership =
        context.watchAdminCustomerGroupMembershipViewModel().value;
    final navigator = Navigator.of(context);
    final failure = switch (_selectionFailure) {
      Some() => _selectionFailure,
      None() => membership.failure,
    };
    return AdminRouteFocusKeyboard(
      enabled: !membership.isBusy,
      onClose: navigator.pop,
      child: PopScope(
        canPop: !membership.isBusy,
        child: Material(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            child: Column(children: [
              AdminRouteFocusHeader(
                onClose: membership.isBusy ? null : navigator.pop,
                trailing: _CandidateFailureHint(failure: failure),
              ),
              Expanded(
                child: AdminCustomerGroupCandidateContent(
                  state: candidates,
                  search: _search,
                  selected: _selected,
                  existing: widget.existingCustomerIds,
                  busy: membership.isBusy,
                  onSearch: _searchCandidates,
                  onAccount: (value) => context
                      .readAdminCustomerGroupCandidateViewModel()
                      .load(hasAccount: value, offset: 0),
                  onOrder: (value) => context
                      .readAdminCustomerGroupCandidateViewModel()
                      .load(order: value, offset: 0),
                  onToggle: _toggle,
                  onTogglePage: _togglePage,
                  onPrevious: context
                      .readAdminCustomerGroupCandidateViewModel()
                      .previous,
                  onNext:
                      context.readAdminCustomerGroupCandidateViewModel().next,
                  onRetry:
                      context.readAdminCustomerGroupCandidateViewModel().load,
                ),
              ),
              AdminRouteFocusFooter(
                busy: membership.isBusy,
                onCancel: navigator.pop,
                onSubmit: _submit,
                submitLabel: 'Save',
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _searchCandidates(String value) =>
      context.readAdminCustomerGroupCandidateViewModel().search(value);

  void _toggle(String id) => setState(() {
        _selectionFailure = const None();
        if (!_selected.add(id)) _selected.remove(id);
      });

  void _togglePage(bool checked) {
    final state = context.readAdminCustomerGroupCandidateViewModel().state;
    final ids = state.customers
        .where((customer) => !widget.existingCustomerIds.contains(customer.id))
        .map((customer) => customer.id);
    setState(() {
      _selectionFailure = const None();
      checked ? _selected.addAll(ids) : _selected.removeAll(ids);
    });
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      setState(() =>
          _selectionFailure = const Some('Select at least one customer.'));
      return;
    }
    final added = _selected.toList(growable: false);
    final result = await context
        .readAdminCustomerGroupMembershipViewModel()
        .update(widget.customerGroupId, add: added);
    if (!mounted) return;
    switch (result) {
      case Some():
        Navigator.of(context).pop(added.length);
      case None():
        break;
    }
  }
}

final class _CandidateFailureHint extends StatelessWidget {
  const _CandidateFailureHint({required this.failure});

  final Option<String> failure;

  @override
  Widget build(BuildContext context) => switch (failure) {
        Some(:final value) => Text(
            value,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        None() => const SizedBox.shrink(),
      };
}

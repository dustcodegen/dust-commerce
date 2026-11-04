import 'package:admin_app/src/customer_group/admin_customer_group_customer_body.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_customer_controls.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_customer_pagination.dart';
import 'package:admin_app/src/customer_group/admin_customer_group_detail_state.dart';
import 'package:flutter/material.dart';

/// Medusa-shaped searchable customer table for one group.
final class AdminCustomerGroupCustomerSection extends StatefulWidget {
  /// Creates the group-owned customer table.
  const AdminCustomerGroupCustomerSection({
    required this.state,
    required this.onOpenCustomer,
    required this.onAdd,
    required this.onRemove,
    required this.busy,
    super.key,
  });

  /// Opens the full-screen customer candidate selector.
  final VoidCallback onAdd;

  /// Blocks membership controls while a command is active.
  final bool busy;

  /// Opens one complete customer route.
  final ValueChanged<String> onOpenCustomer;

  /// Confirms and removes selected customer memberships.
  final Future<bool> Function(List<String>) onRemove;

  /// Current group customer state.
  final AdminCustomerGroupDetailState state;

  @override
  State<AdminCustomerGroupCustomerSection> createState() =>
      _AdminCustomerGroupCustomerSectionState();
}

final class _AdminCustomerGroupCustomerSectionState
    extends State<AdminCustomerGroupCustomerSection> {
  late final TextEditingController _search;
  final Set<String> _selected = {};

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.state.customerQuery);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AdminCustomerGroupCustomerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.customerGroupId != widget.state.customerGroupId) {
      _selected.clear();
    }
  }

  @override
  Widget build(BuildContext context) => Material(
        color: Theme.of(context).colorScheme.surface,
        elevation: 1,
        shadowColor: const Color(0x12000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          _CustomerSectionHeader(onAdd: widget.onAdd, busy: widget.busy),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: AdminCustomerGroupCustomerControls(
              search: _search,
              state: widget.state,
              selectedCount: _selected.length,
              busy: widget.busy,
              onRemove: _removeSelected,
            ),
          ),
          Divider(height: 1, color: Theme.of(context).dividerColor),
          AdminCustomerGroupCustomerBody(
            state: widget.state,
            onOpen: widget.onOpenCustomer,
            selected: _selected,
            busy: widget.busy,
            onToggle: _toggle,
            onTogglePage: _togglePage,
            onRemove: _removeOne,
          ),
          AdminCustomerGroupCustomerPagination(state: widget.state),
        ]),
      );

  void _toggle(String id) => setState(() {
        if (!_selected.add(id)) _selected.remove(id);
      });

  void _togglePage(bool checked) => setState(() {
        final ids = widget.state.customers.map((customer) => customer.id);
        checked ? _selected.addAll(ids) : _selected.removeAll(ids);
      });

  Future<void> _removeOne(String id) => _remove(<String>[id]);

  Future<void> _removeSelected() => _remove(_selected.toList(growable: false));

  Future<void> _remove(List<String> ids) async {
    if (ids.isEmpty || widget.busy) return;
    if (await widget.onRemove(ids) && mounted) {
      setState(() => _selected.removeAll(ids));
    }
  }
}

final class _CustomerSectionHeader extends StatelessWidget {
  const _CustomerSectionHeader({required this.onAdd, required this.busy});

  final bool busy;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          Expanded(
            child: Text(
              'Customers',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          OutlinedButton(
            onPressed: busy ? null : onAdd,
            child: const Text('Add'),
          ),
        ]),
      );
}

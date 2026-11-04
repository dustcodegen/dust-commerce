import 'package:flutter/material.dart';

/// Customer-group list heading shaped after Medusa's source table header.
final class AdminCustomerGroupPageHeader extends StatelessWidget {
  /// Creates the heading and customer-group creation action.
  const AdminCustomerGroupPageHeader({required this.onCreate, super.key});

  /// Opens the focused create surface.
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          Text(
            'Customer Groups',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const Spacer(),
          OutlinedButton(onPressed: onCreate, child: const Text('Create')),
        ]),
      );
}

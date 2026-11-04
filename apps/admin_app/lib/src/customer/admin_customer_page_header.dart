import 'package:flutter/material.dart';

/// Customer list heading shaped after Medusa's source container header.
final class AdminCustomerPageHeader extends StatelessWidget {
  /// Creates the heading and customer creation action.
  const AdminCustomerPageHeader({required this.onCreate, super.key});

  /// Opens the focused create surface.
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(children: [
          Text('Customers', style: Theme.of(context).textTheme.headlineSmall),
          const Spacer(),
          OutlinedButton(onPressed: onCreate, child: const Text('Create')),
        ]),
      );
}

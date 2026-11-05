import 'package:admin_app/src/inventory/admin_stock_location_state.dart';
import 'package:admin_app/src/inventory/admin_stock_location_view_model.dart';
import 'package:commerce_admin_shared/commerce_admin_shared.dart';
import 'package:dust_dart/fp.dart';
import 'package:flutter/material.dart';

/// Renders loading, failure, empty and ready location states.
final class AdminStockLocationTableBody extends StatelessWidget {
  /// Creates the location table body.
  const AdminStockLocationTableBody({required this.state, super.key});

  /// Current location state.
  final AdminStockLocationState state;

  @override
  Widget build(BuildContext context) => switch (state) {
        AdminStockLocationState(
          status: AdminStockLocationStatus.loading,
          stockLocations: final rows,
        )
            when rows.isEmpty =>
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        AdminStockLocationState(failure: Some(value: final message)) =>
          SizedBox(
            height: 120,
            child: Center(
              child: OutlinedButton(
                onPressed: context.readAdminStockLocationViewModel().load,
                child: Text('$message Retry'),
              ),
            ),
          ),
        AdminStockLocationState(stockLocations: final rows) when rows.isEmpty =>
          const SizedBox(
              height: 120, child: Center(child: Text('No locations'))),
        _ => Stack(
            children: [
              AdminStockLocationTable(rows: state.stockLocations),
              if (state.status == AdminStockLocationStatus.loading)
                const LinearProgressIndicator(minHeight: 2),
            ],
          ),
      };
}

/// Visible location rows from the explicit Admin response allowlist.
final class AdminStockLocationTable extends StatelessWidget {
  /// Creates a location table.
  const AdminStockLocationTable({required this.rows, super.key});

  /// Rows returned by the server.
  final List<AdminStockLocation> rows;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _AdminStockLocationHeader(),
          for (final row in rows) _AdminStockLocationRow(row: row),
        ],
      );
}

final class _AdminStockLocationHeader extends StatelessWidget {
  const _AdminStockLocationHeader();

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: const Row(
          children: [
            Expanded(flex: 5, child: Text('Name')),
            Expanded(flex: 5, child: Text('Address')),
          ],
        ),
      );
}

final class _AdminStockLocationRow extends StatelessWidget {
  const _AdminStockLocationRow({required this.row});

  final AdminStockLocation row;

  @override
  Widget build(BuildContext context) => Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(flex: 5, child: Text(row.name)),
            Expanded(flex: 5, child: Text(_address)),
          ],
        ),
      );

  String get _address {
    final parts = [
      row.address1,
      row.city,
      row.province,
      row.postalCode,
      row.countryCode?.toUpperCase(),
    ].whereType<String>().where((part) => part.trim().isNotEmpty);
    return parts.isEmpty ? '—' : parts.join(', ');
  }
}

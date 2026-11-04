part of 'admin_sidebar.dart';

final class _StoreHeader extends StatelessWidget {
  const _StoreHeader({required this.user});

  final AdminUser user;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 30,
        child: Row(
          children: [
            const AdminAvatar(label: 'M'),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Morrow', overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              tooltip: 'Store actions',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              onPressed: () {},
              icon: const Icon(Icons.more_horiz_rounded, size: 17),
            ),
          ],
        ),
      );
}

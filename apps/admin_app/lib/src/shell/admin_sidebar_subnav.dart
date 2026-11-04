part of 'admin_sidebar.dart';

final class _NavRow extends StatelessWidget {
  const _NavRow({
    required this.icon,
    required this.label,
    this.selected = false,
    this.shortcut,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool selected;
  final String? shortcut;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Material(
          color: selected
              ? Theme.of(context).colorScheme.surface
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: selected
                ? BorderSide(color: Theme.of(context).dividerColor)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: switch (onTap) {
              final callback? => () => _navigate(context, callback),
              null => null,
            },
            child: SizedBox(
              height: 30,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(icon, size: 16),
                  const SizedBox(width: 9),
                  Expanded(child: Text(label)),
                  if (shortcut case final value?)
                    Text(value, style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      );
}

final class _SubNav extends StatelessWidget {
  const _SubNav({
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) => Material(
        color: selected
            ? Theme.of(context).colorScheme.surface
            : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: selected
              ? BorderSide(color: Theme.of(context).dividerColor)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: switch (onTap) {
            final callback? => () => _navigate(context, callback),
            null => null,
          },
          child: SizedBox(
            height: 28,
            child: Padding(
              padding: const EdgeInsets.only(left: 41),
              child: Align(alignment: Alignment.centerLeft, child: Text(label)),
            ),
          ),
        ),
      );
}

void _navigate(BuildContext context, VoidCallback callback) {
  Scaffold.maybeOf(context)?.closeDrawer();
  callback();
}

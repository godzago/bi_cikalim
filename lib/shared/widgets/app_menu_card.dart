import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';
import 'app_pressable_scale.dart';

class AppMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const AppMenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return AppPressableScale(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(layout.cardRadius),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: ListTile(
          onTap: onTap,
          minTileHeight: AppLayout.minTouchTarget,
          contentPadding: EdgeInsets.symmetric(
            horizontal: layout.cardPadding,
            vertical: 4,
          ),
          leading: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: BiCikalimTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(layout.controlRadius),
            ),
            child: Icon(icon, color: BiCikalimTheme.primary, size: 19),
          ),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: layout.cardTitleSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: BiCikalimTheme.textSecondary,
            ),
          ),
          trailing:
              trailing ??
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: BiCikalimTheme.textLight,
              ),
        ),
      ),
    );
  }
}

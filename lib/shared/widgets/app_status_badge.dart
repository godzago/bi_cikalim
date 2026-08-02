import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

class AppStatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final String? semanticLabel;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.icon,
    this.color = BiCikalimTheme.primary,
    this.filled = false,
    this.semanticLabel,
  });

  const AppStatusBadge.available({
    super.key,
    this.label = 'Mevcut',
    this.semanticLabel,
  }) : icon = Icons.check_circle_outline,
       color = BiCikalimTheme.success,
       filled = false;

  const AppStatusBadge.verified({
    super.key,
    this.label = 'Doğrulanmış',
    this.semanticLabel,
  }) : icon = Icons.verified_outlined,
       color = BiCikalimTheme.success,
       filled = false;

  const AppStatusBadge.price({
    super.key,
    required this.label,
    this.semanticLabel,
  }) : icon = Icons.payments_outlined,
       color = BiCikalimTheme.primary,
       filled = false;

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? Colors.white : color;
    return Semantics(
      label: semanticLabel ?? label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: filled ? color : color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

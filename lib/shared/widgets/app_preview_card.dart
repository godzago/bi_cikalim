import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';

class AppPreviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;
  final String? secondaryText;

  const AppPreviewCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(layout.cardRadius),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(layout.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(layout.controlRadius),
              ),
              child: Icon(icon, color: BiCikalimTheme.primary, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: layout.cardTitleSize,
                fontWeight: FontWeight.bold,
                color: BiCikalimTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: BiCikalimTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton(
                  onPressed: onPrimaryAction,
                  style: TextButton.styleFrom(
                    foregroundColor: BiCikalimTheme.primary,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    primaryActionLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (secondaryText != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      secondaryText!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: BiCikalimTheme.textLight,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

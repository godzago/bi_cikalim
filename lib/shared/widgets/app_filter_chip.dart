import 'package:flutter/material.dart';

import '../../core/theme/responsive.dart';
import 'app_filter_controls.dart';

class AppFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppLayout.minTouchTarget),
        child: AppFilterChoiceChip(
          label: label,
          selected: isSelected,
          onTap: onTap,
        ),
      ),
    );
  }
}

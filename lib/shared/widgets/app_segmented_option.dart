import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';

class AppSegmentedOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const AppSegmentedOption({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          constraints: const BoxConstraints(
            minWidth: 72,
            minHeight: AppLayout.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? BiCikalimTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? BiCikalimTheme.primary : Colors.grey.shade200,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : BiCikalimTheme.textSecondary,
              fontSize: context.layout.bodySize,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

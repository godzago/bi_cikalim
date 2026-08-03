import 'package:flutter/material.dart';

import '../../core/theme/app_density.dart';
import '../../core/theme/theme.dart';

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
          constraints: BoxConstraints(
            minWidth: AppDensity.value(
              context,
              compact: 76,
              standard: 84,
              wide: 88,
            ),
            minHeight: 44,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDensity.value(
              context,
              compact: 12,
              standard: 14,
              wide: 14,
            ),
            vertical: 8,
          ),
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
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

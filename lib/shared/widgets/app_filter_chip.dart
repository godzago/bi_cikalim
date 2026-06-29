import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

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
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: BiCikalimTheme.primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(
          color: isSelected
              ? BiCikalimTheme.primary
              : BiCikalimTheme.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? BiCikalimTheme.primary : Colors.grey.shade200,
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}

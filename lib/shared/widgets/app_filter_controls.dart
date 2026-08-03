import 'package:flutter/material.dart';

import '../../core/theme/responsive.dart';
import '../../core/theme/theme.dart';

/// Uygulamadaki filtre girişlerinin ortak görünümü.
class AppFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int activeCount;
  final bool iconOnly;

  const AppFilterButton({
    super.key,
    required this.onPressed,
    this.activeCount = 0,
    this.iconOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (iconOnly) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            tooltip: activeCount > 0
                ? '$activeCount filtre seçili'
                : 'Filtrele',
            onPressed: onPressed,
            icon: const Icon(Icons.tune_rounded),
          ),
          if (activeCount > 0)
            Positioned(
              right: 4,
              top: 4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: BiCikalimTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$activeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.tune_rounded, size: 18),
      label: Text(activeCount > 0 ? 'Filtrele ($activeCount)' : 'Filtrele'),
      style: OutlinedButton.styleFrom(
        foregroundColor: BiCikalimTheme.primary,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: activeCount > 0
              ? BiCikalimTheme.primary
              : BiCikalimTheme.primary.withValues(alpha: .22),
        ),
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(0, AppLayout.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: 13),
        shape: const StadiumBorder(),
      ),
    );
  }
}

/// Filtre bottom-sheet'lerinin ortak iskeleti ve sabit aksiyon alanı.
class AppFilterSheet extends StatelessWidget {
  final Widget child;
  final VoidCallback onClear;
  final VoidCallback onApply;
  final String title;
  final String subtitle;
  final bool clearEnabled;

  const AppFilterSheet({
    super.key,
    required this.child,
    required this.onClear,
    required this.onApply,
    this.title = 'Filtreler',
    this.subtitle = 'Sonuçları sana göre daralt.',
    this.clearEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .84,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              context.layout.screenPadding,
              0,
              context.layout.screenPadding,
              context.layout.sectionGap,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: 20,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                Flexible(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: child,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: clearEnabled ? onClear : null,
                        child: const Text('Temizle'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onApply,
                        child: const Text('Uygula'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppFilterSectionTitle extends StatelessWidget {
  final String label;

  const AppFilterSectionTitle(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: BiCikalimTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class AppFilterChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AppFilterChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppLayout.minTouchTarget),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.padded,
        selectedColor: BiCikalimTheme.primary,
        backgroundColor: BiCikalimTheme.primary.withValues(alpha: .06),
        side: BorderSide(
          color: selected
              ? BiCikalimTheme.primary
              : BiCikalimTheme.primary.withValues(alpha: .14),
        ),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: selected ? Colors.white : BiCikalimTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

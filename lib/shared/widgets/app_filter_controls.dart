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
    final screenPadding = context.layout.screenPadding;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .88,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(screenPadding, 4, 10, 0),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: BiCikalimTheme.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: BiCikalimTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: BiCikalimTheme.textPrimary,
                              fontSize: 20,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: BiCikalimTheme.textSecondary,
                              fontSize: 12,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kapat',
                      onPressed: () => Navigator.maybePop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Divider(
                height: 1,
                color: BiCikalimTheme.primary.withValues(alpha: .09),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    screenPadding,
                    16,
                    screenPadding,
                    18,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: child,
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  screenPadding,
                  12,
                  screenPadding,
                  8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: BiCikalimTheme.primary.withValues(alpha: .08),
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 18,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final textScale = MediaQuery.textScalerOf(context).scale(1);
                    final stackActions =
                        constraints.maxWidth < 350 && textScale > 1.2;
                    final clearButton = OutlinedButton.icon(
                      onPressed: clearEnabled ? onClear : null,
                      icon: const Icon(Icons.restart_alt_rounded, size: 19),
                      label: const Text('Temizle'),
                    );
                    final applyButton = FilledButton.icon(
                      onPressed: onApply,
                      icon: const Icon(Icons.check_rounded, size: 19),
                      label: const Text('Filtreleri Uygula'),
                    );

                    if (stackActions) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          clearButton,
                          const SizedBox(height: 8),
                          applyButton,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: clearButton),
                        const SizedBox(width: 12),
                        Expanded(flex: 2, child: applyButton),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Birbiriyle ilişkili filtre alanlarını tek bir görsel grupta toplar.
class AppFilterGroup extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const AppFilterGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BiCikalimTheme.primary.withValues(alpha: .1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: BiCikalimTheme.primary, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: BiCikalimTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: BiCikalimTheme.textSecondary,
                            fontSize: 11,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

/// Boolean filtreler için açıklamalı, dokunulabilir seçim kartı.
class AppFilterToggleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AppFilterToggleTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      button: true,
      child: Material(
        color: value
            ? BiCikalimTheme.primary.withValues(alpha: .075)
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onChanged(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.fromLTRB(13, 10, 8, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: value
                    ? BiCikalimTheme.primary.withValues(alpha: .32)
                    : BiCikalimTheme.primary.withValues(alpha: .09),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: value
                        ? BiCikalimTheme.primary
                        : BiCikalimTheme.primary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: value ? Colors.white : BiCikalimTheme.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BiCikalimTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: 10.5,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  activeTrackColor: BiCikalimTheme.primary,
                  onChanged: onChanged,
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

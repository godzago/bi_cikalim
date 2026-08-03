import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';
import 'app_pressable_scale.dart';

/// Uygulamanın genel primary butonu.
/// Loading state ve disabled state destekler.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? prefixIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (isLoading) {
      child = const SizedBox(
        key: ValueKey('loading'),
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (prefixIcon != null) {
      child = Row(
        key: const ValueKey('label-with-icon'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(prefixIcon, size: 18),
          const SizedBox(width: 6),
          Flexible(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      );
    } else {
      child = Text(label, key: const ValueKey('label'));
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: child,
      ),
    );

    final sizedButton = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppLayout.minTouchTarget),
      child: isFullWidth
          ? SizedBox(width: double.infinity, child: button)
          : button,
    );

    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: isLoading ? '$label, işlem devam ediyor' : label,
      child: AppPressableScale(
        enabled: onPressed != null && !isLoading,
        child: sizedButton,
      ),
    );
  }
}

/// İkincil (outline) buton.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? prefixIcon;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = prefixIcon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(prefixIcon, size: 18, color: BiCikalimTheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          )
        : Text(label);

    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: label,
      child: AppPressableScale(
        enabled: onPressed != null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppLayout.minTouchTarget,
          ),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: BiCikalimTheme.primary,
                side: const BorderSide(color: BiCikalimTheme.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    context.layout.controlRadius,
                  ),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

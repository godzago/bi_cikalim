import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';

class AppIconActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final String? semanticLabel;

  const AppIconActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.foregroundColor,
    this.backgroundColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveForeground = foregroundColor ?? BiCikalimTheme.primary;
    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: semanticLabel ?? label,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: AppLayout.minTouchTarget,
          minWidth: AppLayout.minTouchTarget,
        ),
        child: FilledButton.tonalIcon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: effectiveForeground,
                  ),
                )
              : Icon(icon, size: 18),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          style: FilledButton.styleFrom(
            foregroundColor: effectiveForeground,
            backgroundColor:
                backgroundColor ?? effectiveForeground.withValues(alpha: .08),
            minimumSize: const Size(
              AppLayout.minTouchTarget,
              AppLayout.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            textStyle: TextStyle(
              fontSize: context.layout.bodySize,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class AppRoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;

  const AppRoundIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isLoading = false,
    this.color = BiCikalimTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppLayout.minTouchTarget,
            minHeight: AppLayout.minTouchTarget,
          ),
          child: IconButton(
            onPressed: isLoading ? null : onPressed,
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: color,
                    ),
                  )
                : Icon(icon, color: color),
          ),
        ),
      ),
    );
  }
}

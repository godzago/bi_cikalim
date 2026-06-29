import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

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
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (prefixIcon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(prefixIcon, size: 20),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    } else {
      child = Text(label);
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: child,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, height: 52, child: button);
    }
    return SizedBox(height: 52, child: button);
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
              Icon(prefixIcon, size: 20, color: BiCikalimTheme.primary),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Text(label);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: BiCikalimTheme.primary,
          side: const BorderSide(color: BiCikalimTheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            
          ),
        ),
        child: child,
      ),
    );
  }
}

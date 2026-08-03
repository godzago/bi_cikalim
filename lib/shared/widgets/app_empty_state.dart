import 'package:flutter/material.dart';

import '../../core/theme/responsive.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String message;
  final EdgeInsetsGeometry padding;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final String? semanticLabel;

  const AppEmptyState({
    super.key,
    required this.icon,
    this.title,
    required this.message,
    this.padding = const EdgeInsets.all(24),
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        child: Semantics(
          label:
              semanticLabel ?? [title, message].whereType<String>().join('. '),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.grey.shade500),
              if (title != null && title!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade900,
                    height: 1.22,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppLayout.minTouchTarget,
                  ),
                  child: FilledButton(
                    onPressed: onAction,
                    child: Text(actionLabel!),
                  ),
                ),
              ],
              if (secondaryActionLabel != null &&
                  onSecondaryAction != null) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onSecondaryAction,
                  child: Text(secondaryActionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return content;
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Scroll içermeyen loading, error ve empty durumlarında da pull-to-refresh
/// hareketinin çalışmasını sağlar.
class AppRefreshableContent extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppRefreshableContent({
    super.key,
    required this.onRefresh,
    required this.child,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RefreshIndicator(
          color: BiCikalimTheme.primary,
          onRefresh: onRefresh,
          notificationPredicate: (_) => true,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double compact = 360;
  static const double wide = 420;
  static const double tablet = 600;
}

class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
}

class AppRadius {
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
}

class AppDensity {
  static double widthOf(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static bool isCompact(BuildContext context) =>
      widthOf(context) < AppBreakpoints.compact;

  static bool isWide(BuildContext context) =>
      widthOf(context) >= AppBreakpoints.wide;

  static double value(
    BuildContext context, {
    required double compact,
    required double standard,
    required double wide,
  }) {
    final width = widthOf(context);
    if (width < AppBreakpoints.compact) return compact;
    if (width >= AppBreakpoints.wide) return wide;
    return standard;
  }

  static double clamp(
    BuildContext context, {
    required double factor,
    required double min,
    required double max,
  }) {
    final raw = widthOf(context) * factor;
    return raw.clamp(min, max).toDouble();
  }

  static double screenPadding(BuildContext context) {
    return value(context, compact: 12, standard: 16, wide: 20);
  }

  static EdgeInsets screenInsets(
    BuildContext context, {
    double top = 0,
    double bottom = 0,
  }) {
    final horizontal = screenPadding(context);
    return EdgeInsets.fromLTRB(horizontal, top, horizontal, bottom);
  }

  static double sectionGap(BuildContext context) {
    return value(context, compact: 14, standard: 16, wide: 18);
  }

  static double cardRadius(BuildContext context) {
    return value(
      context,
      compact: AppRadius.sm,
      standard: AppRadius.md,
      wide: AppRadius.lg,
    );
  }

  static double searchHeight(BuildContext context) {
    return value(context, compact: 46, standard: 48, wide: 50);
  }

  static double chipHeight(BuildContext context) {
    return value(context, compact: 32, standard: 34, wide: 36);
  }
}

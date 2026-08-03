import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Width-aware layout tokens for phone layouts.
///
/// Values are selected per component instead of scaling an entire page. This
/// keeps spacing, type, imagery and hit targets independently controllable.
enum AppWindowClass { compact, standard, wide }

@immutable
class AppLayout {
  static const double compactMax = 359;
  static const double standardMax = 419;
  static const double wideMax = 599;
  static const double minTouchTarget = 44;

  final double width;

  const AppLayout(this.width);

  factory AppLayout.of(BuildContext context) {
    return AppLayout(MediaQuery.sizeOf(context).width);
  }

  AppWindowClass get windowClass {
    if (width <= compactMax) return AppWindowClass.compact;
    if (width <= standardMax) return AppWindowClass.standard;
    return AppWindowClass.wide;
  }

  bool get isCompact => windowClass == AppWindowClass.compact;
  bool get isStandard => windowClass == AppWindowClass.standard;
  bool get isWide => windowClass == AppWindowClass.wide;

  /// Interpolates between phone reference widths and clamps at both ends.
  double fluid(double at320, double at390, double at599) {
    final safeWidth = width.clamp(320.0, 599.0);
    if (safeWidth <= 390) {
      return _lerp(at320, at390, (safeWidth - 320) / 70);
    }
    return _lerp(at390, at599, (safeWidth - 390) / 209);
  }

  double _lerp(double a, double b, double t) => a + ((b - a) * t);

  double get screenPadding => fluid(14, 15, 16);
  double get sectionGap => fluid(18, 19, 20);
  double get cardGap => fluid(8, 9, 10);
  double get cardPadding => fluid(8, 10, 12);
  double get cardRadius => fluid(10, 12, 14);
  double get controlRadius => fluid(10, 11, 12);

  double get headerHeight => fluid(46, 48, 50);
  double get searchHeight => fluid(42, 43, 44);
  double get chipHeight => fluid(28, 30, 32);
  double get bottomNavigationHeight => fluid(54, 56, 58);
  double get compactControlHeight => fluid(38, 40, 42);

  double get pageTitleSize => fluid(23, 23.5, 24);
  double get sectionTitleSize => fluid(16, 17, 18);
  double get cardTitleSize => fluid(14, 14.5, 15);
  double get bodySize => fluid(13, 13.5, 14);
  double get metadataSize => fluid(11.5, 11.75, 12);

  double get venueHeroHeight => fluid(136, 144, 152);
  double get collapsedMapSheetHeight => fluid(126, 136, 148);

  double carouselCardWidth({
    required double visibleItems,
    required double min,
    required double max,
  }) {
    assert(visibleItems > 1);
    final contentWidth = width - (screenPadding * 2);
    final visibleGaps = visibleItems - 1;
    return ((contentWidth - (cardGap * visibleGaps)) / visibleItems)
        .clamp(min, max)
        .toDouble();
  }

  /// Content-safe grid count. Compact screens remain single-column unless a
  /// caller explicitly supplies a smaller minimum card width.
  int columnsFor({double minItemWidth = 176, int maxColumns = 2}) {
    final available = width - (screenPadding * 2) + cardGap;
    return math.max(
      1,
      math.min(maxColumns, available ~/ (minItemWidth + cardGap)),
    );
  }
}

extension AppResponsiveContext on BuildContext {
  AppLayout get layout => AppLayout.of(this);
}

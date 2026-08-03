import 'package:flutter/material.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../shared/widgets/app_pressable_scale.dart';

class ActivityRecommendationCard extends StatelessWidget {
  final TonightActivityRecommendation recommendation;
  final VoidCallback onTap;
  final bool compact;

  const ActivityRecommendationCard({
    super.key,
    required this.recommendation,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final activity = recommendation.activity;
    final venues = recommendation.venues;
    final venueCount = venues.total > 0 ? venues.total : venues.items.length;
    final previewVenues = venues.items
        .take(2)
        .map((venue) => venue.name)
        .where((name) => name.trim().isNotEmpty)
        .join(', ');

    return Semantics(
      button: true,
      label:
          '${activity.name}, $venueCount mekânda yapılabilir. Mekânları gör.',
      child: AppPressableScale(
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(layout.cardRadius),
            side: const BorderSide(color: Color(0xFFF0EDE9)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(layout.cardRadius),
            child: Padding(
              padding: EdgeInsets.all(compact ? 8 : layout.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: compact ? 32 : 40,
                        height: compact ? 32 : 40,
                        decoration: BoxDecoration(
                          color: BiCikalimTheme.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(
                            layout.controlRadius,
                          ),
                        ),
                        child: Icon(
                          activity.iconData,
                          color: BiCikalimTheme.primary,
                        ),
                      ),
                      SizedBox(width: compact ? 6 : layout.cardGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!compact) ...[
                              const _ActivityBadge(),
                              const SizedBox(height: 7),
                            ],
                            Text(
                              activity.name,
                              maxLines: compact ? 3 : 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: BiCikalimTheme.textPrimary,
                                fontSize: compact ? 14 : layout.cardTitleSize,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    venueCount > 0
                        ? '$venueCount mekânda yapabilirsin'
                        : 'Mekânları kontrol et',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BiCikalimTheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!compact && previewVenues.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      previewVenues,
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BiCikalimTheme.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else if (!compact &&
                      (activity.description?.trim().isNotEmpty ?? false)) ...[
                    const SizedBox(height: 5),
                    Text(
                      activity.description!.trim(),
                      maxLines: compact ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BiCikalimTheme.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 8,
                            ),
                            textStyle: TextStyle(
                              fontSize: compact ? 11 : layout.bodySize,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: const Text('Mekânları Gör'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityBadge extends StatelessWidget {
  const _ActivityBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: BiCikalimTheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Aktivite',
        style: TextStyle(
          color: BiCikalimTheme.primary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
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
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF0EDE9)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: EdgeInsets.all(compact ? 14 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: compact ? 42 : 48,
                        height: compact ? 42 : 48,
                        decoration: BoxDecoration(
                          color: BiCikalimTheme.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          activity.iconData,
                          color: BiCikalimTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _ActivityBadge(),
                            const SizedBox(height: 7),
                            Text(
                              activity.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: BiCikalimTheme.textPrimary,
                                fontSize: compact ? 15 : 17,
                                height: 1.15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  if (previewVenues.isNotEmpty) ...[
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
                  ] else if (activity.description?.trim().isNotEmpty ??
                      false) ...[
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
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: onTap,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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

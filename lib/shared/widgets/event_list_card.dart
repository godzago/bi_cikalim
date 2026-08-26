import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';
import 'app_network_image.dart';
import 'app_pressable_scale.dart';

class EventListCard extends StatelessWidget {
  final ApiEvent event;
  final ApiVenue? venue;
  final VoidCallback onTap;

  const EventListCard({
    super.key,
    required this.event,
    this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final venueName = venue?.name ?? event.venue?.name;
    final location = [
      if (venue?.districtName.isNotEmpty ?? false) venue!.districtName,
      if (event.city.name.isNotEmpty) event.city.name,
    ].join(', ');
    final dateStr = '${event.startDate.day} / ${event.startDate.month}';
    final timeStr =
        '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';
    final showPrice = event.hasPublicPriceInfo;

    return AppPressableScale(
      child: Card(
        margin: EdgeInsets.only(bottom: layout.cardGap * 0.72),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(layout.cardRadius),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(layout.cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(layout.cardRadius),
                    ),
                    child: AppNetworkImage(
                      imageUrl: event.imageUrl,
                      height: layout.fluid(88, 96, 108),
                      width: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dateStr,
                            style: const TextStyle(
                              color: BiCikalimTheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              color: BiCikalimTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bookmark_border,
                        color: BiCikalimTheme.primary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(layout.cardPadding * 0.78),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: BiCikalimTheme.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                event.category,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: BiCikalimTheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (showPrice) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              event.priceInfo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                color: BiCikalimTheme.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: layout.cardTitleSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if ((event.description ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.description ?? '',
                        style: TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: layout.metadataSize,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 6),
                    if (venueName != null || location.isNotEmpty)
                      Row(
                        children: [
                          if (venue?.coverImageUrl.isNotEmpty ?? false) ...[
                            AppNetworkImage(
                              imageUrl: venue!.coverImageUrl,
                              width: 28,
                              height: 28,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (venueName != null && venueName.isNotEmpty)
                                  Text(
                                    venueName,
                                    style: TextStyle(
                                      color: BiCikalimTheme.textPrimary,
                                      fontSize: layout.metadataSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (location.isNotEmpty)
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      color: BiCikalimTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

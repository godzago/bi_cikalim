import 'package:flutter/material.dart';

import '../models/api_models.dart';
import '../../core/theme/theme.dart';
import '../../core/theme/responsive.dart';
import 'app_network_image.dart';
import 'app_pressable_scale.dart';

class EventPreviewCard extends StatelessWidget {
  final ApiEvent event;
  final VoidCallback onTap;

  const EventPreviewCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final metadata = [
      if (event.venue?.name.isNotEmpty ?? false) event.venue!.name,
      if (event.hasPublicPriceInfo) event.priceInfo,
    ].join(' • ');

    return AppPressableScale(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: layout.fluid(214, 226, 244),
          margin: EdgeInsets.only(right: layout.cardGap),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(layout.cardRadius),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(imageUrl: event.imageUrl),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(layout.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BiCikalimTheme.warning,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.category.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: layout.cardTitleSize,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (metadata.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.store,
                              color: Colors.white70,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                metadata,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: layout.metadataSize,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
      ),
    );
  }
}

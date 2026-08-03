import 'package:flutter/material.dart';
import '../models/api_models.dart';
import '../../core/theme/app_density.dart';
import '../../core/theme/theme.dart';
import 'app_pressable_scale.dart';
import 'app_network_image.dart';
import 'app_status_badge.dart';

class VenueCard extends StatelessWidget {
  final ApiVenue venue;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool dense;

  const VenueCard({
    super.key,
    required this.venue,
    required this.onTap,
    this.onFavoriteTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = AppDensity.cardRadius(context);
    final semanticLocation = [
      if (venue.districtName.isNotEmpty) venue.districtName,
      if (venue.cityName.isNotEmpty) venue.cityName,
    ].join(', ');

    return Semantics(
      button: true,
      label:
          '${venue.name}${semanticLocation.isEmpty ? '' : ', $semanticLocation'}. Burada ne yapılır bilgilerini gör.',
      child: AppPressableScale(
        child: Card(
          margin: EdgeInsets.only(
            bottom: dense
                ? AppDensity.value(context, compact: 8, standard: 10, wide: 10)
                : AppDensity.value(
                    context,
                    compact: 10,
                    standard: 12,
                    wide: 14,
                  ),
          ),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: dense
                ? _buildDenseCard(context)
                : _buildDefaultCard(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultCard(BuildContext context) {
    final radius = AppDensity.cardRadius(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
              child: AspectRatio(
                aspectRatio: 1.72,
                child: AppNetworkImage(
                  imageUrl: venue.coverImageUrl,
                  width: double.infinity,
                  semanticLabel: '${venue.name} mekan görseli',
                ),
              ),
            ),
            if (onFavoriteTap != null) _buildBookmarkButton(top: 12, right: 12),
            if (venue.verificationStatus == 'verified')
              _buildVerifiedBadge(top: 12, left: 12),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(
            AppDensity.value(context, compact: 10, standard: 12, wide: 14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(fontSize: 16, showRating: true),
              const SizedBox(height: 4),
              _buildLocationRow(),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: venue.activityTags.take(3).map(_buildTag).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDenseCard(BuildContext context) {
    final activityCount = venue.activitySummary.length;
    final imageSize = AppDensity.value(
      context,
      compact: 76,
      standard: 82,
      wide: 88,
    );

    return Padding(
      padding: EdgeInsets.all(
        AppDensity.value(context, compact: 8, standard: 10, wide: 10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(
              imageUrl: venue.coverImageUrl,
              width: imageSize,
              height: imageSize,
              semanticLabel: '${venue.name} mekan görseli',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildHeader(fontSize: 14, showRating: false),
                    ),
                    const SizedBox(width: 8),
                    if (venue.verificationStatus == 'verified')
                      const Tooltip(
                        message: 'Doğrulanmış mekan',
                        child: Icon(
                          Icons.verified,
                          size: 18,
                          color: BiCikalimTheme.success,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildLocationRow(fontSize: 11),
                const SizedBox(height: 4),
                Text(
                  '$activityCount aktivite - ${venue.reviewCount} yorum',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: venue.activityTags
                      .take(2)
                      .map(_buildDenseTag)
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRatingPill(),
              SizedBox(height: AppDensity.isCompact(context) ? 14 : 20),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({required double fontSize, required bool showRating}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            venue.name,
            style: TextStyle(
              color: BiCikalimTheme.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        if (showRating) _buildRatingPill(),
      ],
    );
  }

  Widget _buildRatingPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: BiCikalimTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: BiCikalimTheme.primary, size: 14),
          const SizedBox(width: 2),
          Text(
            '${venue.averageRating}',
            style: const TextStyle(
              color: BiCikalimTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({double fontSize = 12}) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, color: Colors.grey.shade400, size: 14),
        const SizedBox(width: 2),
        Expanded(
          child: Text(
            [
              if (venue.districtName.isNotEmpty) venue.districtName,
              if (venue.cityName.isNotEmpty) venue.cityName,
            ].join(', '),
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: fontSize,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDenseTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBookmarkButton({required double top, required double right}) {
    return Positioned(
      top: top,
      right: right,
      child: Semantics(
        button: true,
        label: venue.isFavorite
            ? '${venue.name}, favorilerden çıkar'
            : '${venue.name}, favorilere ekle',
        child: Tooltip(
          message: venue.isFavorite ? 'Favoriden çıkar' : 'Favoriye ekle',
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onFavoriteTap,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  venue.isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border,
                  color: BiCikalimTheme.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge({required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: const AppStatusBadge.verified(
        label: 'Doğrulanmış',
        semanticLabel: 'Doğrulanmış mekan',
      ),
    );
  }
}

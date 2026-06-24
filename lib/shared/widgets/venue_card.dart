import 'package:flutter/material.dart';

import '../../core/services/mock_data.dart';
import '../../core/theme/theme.dart';
import 'app_network_image.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;
  final bool dense;

  const VenueCard({
    super.key,
    required this.venue,
    required this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.only(bottom: dense ? 10 : 14),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        child: dense ? _buildDenseCard() : _buildDefaultCard(),
      ),
    );
  }

  Widget _buildDefaultCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AppNetworkImage(
                imageUrl: venue.coverImageUrl,
                height: 136,
                width: double.infinity,
              ),
            ),
            _buildBookmarkButton(top: 12, right: 12),
            if (venue.verificationStatus == 'verified')
              _buildVerifiedBadge(top: 12, left: 12),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(fontSize: 16, showRating: true),
              const SizedBox(height: 4),
              _buildLocationRow(),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: venue.activityTags.map(_buildTag).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDenseCard() {
    final activityCount = MockDatabase.getActivitiesForVenue(venue.id).length;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(
              imageUrl: venue.coverImageUrl,
              width: 88,
              height: 88,
            ),
          ),
          const SizedBox(width: 12),
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
                      const Icon(
                        Icons.verified,
                        size: 16,
                        color: BiCikalimTheme.success,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _buildLocationRow(fontSize: 11),
                const SizedBox(height: 6),
                Text(
                  '$activityCount aktivite · ${venue.reviewCount} yorum',
                  style: const TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildRatingPill(),
              const SizedBox(height: 22),
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
              fontFamily: 'Outfit',
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: BiCikalimTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
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
            '${venue.district}, ${venue.city}',
            style: TextStyle(color: Colors.grey.shade600, fontSize: fontSize),
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
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 10,
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
        style: TextStyle(
          color: Colors.grey.shade800,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildBookmarkButton({required double top, required double right}) {
    return Positioned(
      top: top,
      right: right,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.bookmark_border,
          color: BiCikalimTheme.primary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildVerifiedBadge({required double top, required double left}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: BiCikalimTheme.success,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified, color: Colors.white, size: 10),
            SizedBox(width: 4),
            Text(
              'ONAYLI MEKAN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

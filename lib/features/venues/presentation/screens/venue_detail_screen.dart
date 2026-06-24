import 'package:flutter/material.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/event_list_card.dart';

class VenueDetailScreen extends StatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Venue _venue;
  late List<VenueActivity> _activities;
  late List<Event> _events;
  late List<Review> _reviews;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _venue = MockDatabase.venues.firstWhere(
      (venue) => venue.id == widget.venueId,
      orElse: () => MockDatabase.venues.first,
    );
    _activities = MockDatabase.getVenueActivities(_venue.id);
    _events = MockDatabase.events
        .where((event) => event.venueId == _venue.id)
        .toList();
    _reviews = MockDatabase.reviews
        .where((review) => review.venueId == _venue.id)
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: BiCikalimTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: AppNetworkImage(imageUrl: _venue.coverImageUrl),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _venue.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _venue.verificationStatus == 'verified'
                              ? BiCikalimTheme.success.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _venue.verificationStatus == 'verified'
                                  ? Icons.verified
                                  : Icons.help_outline,
                              color: _venue.verificationStatus == 'verified'
                                  ? BiCikalimTheme.success
                                  : Colors.grey,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _venue.verificationStatus == 'verified'
                                  ? 'Onayli Mekan'
                                  : 'Dogrulanmamis',
                              style: TextStyle(
                                color: _venue.verificationStatus == 'verified'
                                    ? BiCikalimTheme.success
                                    : Colors.grey.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: BiCikalimTheme.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _venue.address,
                          style: const TextStyle(
                            color: BiCikalimTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildQuickAction(Icons.directions, 'Yol Tarifi', () {}),
                      _buildQuickAction(Icons.phone, 'Ara', () {}),
                      _buildQuickAction(Icons.camera_alt, 'Instagram', () {}),
                      _buildQuickAction(Icons.bookmark_border, 'Kaydet', () {}),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: BiCikalimTheme.primary,
              unselectedLabelColor: BiCikalimTheme.textSecondary,
              indicatorColor: BiCikalimTheme.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Outfit',
              ),
              tabs: const [
                Tab(text: 'Genel'),
                Tab(text: 'Aktiviteler'),
                Tab(text: 'Etkinlikler'),
                Tab(text: 'Yorumlar'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneralTab(),
                  _buildActivitiesTab(),
                  _buildEventsTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: BiCikalimTheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BiCikalimTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hakkinda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _venue.description,
            style: const TextStyle(
              color: BiCikalimTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Calisma Saatleri',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Hafta Ici', '09:00 - 23:00'),
          _buildInfoRow('Hafta Sonu', '10:00 - 01:00'),
          const SizedBox(height: 24),
          const Text(
            'Mekan Notlari',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureChip('Grup dostu'),
              _buildFeatureChip('Rezervasyon uygun'),
              _buildFeatureChip('Aksam saatleri hareketli'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BiCikalimTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      backgroundColor: Colors.grey.shade50,
      side: BorderSide(color: Colors.grey.shade200),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: BiCikalimTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildActivitiesTab() {
    if (_activities.isEmpty) {
      return const AppEmptyState(
        icon: Icons.notes,
        message: 'Bu mekana ait aktivite envanteri henuz eklenmemis.',
        padding: EdgeInsets.all(32),
      );
    }

    final grouped = <String, List<_InventoryItem>>{};
    for (final venueActivity in _activities) {
      final activity = MockDatabase.getActivityById(venueActivity.activityId);
      grouped.putIfAbsent(activity.categoryId, () => []);
      grouped[activity.categoryId]!.add(
        _InventoryItem(activity: activity, venueActivity: venueActivity),
      );
    }

    final orderedCategoryIds = grouped.keys.toList()
      ..sort((a, b) {
        final left = MockDatabase.getCategoryById(a).order;
        final right = MockDatabase.getCategoryById(b).order;
        return left.compareTo(right);
      });

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ...orderedCategoryIds.map((categoryId) {
          final category = MockDatabase.getCategoryById(categoryId);
          final inventory = grouped[categoryId]!;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: Colors.grey.shade100),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          color: BiCikalimTheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          category.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      Text(
                        '${inventory.length} kalem',
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...inventory.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        _buildCompactInventoryRow(item),
                        if (index != inventory.length - 1)
                          Divider(height: 16, color: Colors.grey.shade100),
                      ],
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCompactInventoryRow(_InventoryItem item) {
    final subcategory = MockDatabase.getSubcategoryById(
      item.activity.subcategoryId,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: BiCikalimTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            item.activity.icon,
            size: 18,
            color: BiCikalimTheme.primary,
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
                    child: Text(
                      item.activity.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: BiCikalimTheme.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.venueActivity.priceInfo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: item.venueActivity.isFree
                          ? BiCikalimTheme.success
                          : BiCikalimTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                [
                  if (subcategory != null) subcategory.name,
                  '${item.activity.minPeople}-${item.activity.maxPeople} kisi',
                  item.venueActivity.note,
                ].join(' - '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.35,
                  color: BiCikalimTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventsTab() {
    if (_events.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_busy,
        message: 'Yakin zamanda planlanmis etkinlik bulunmuyor.',
        padding: EdgeInsets.all(32),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return EventListCard(event: event, venue: _venue, onTap: () {});
      },
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '${_venue.averageRating}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: BiCikalimTheme.primary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < _venue.averageRating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: BiCikalimTheme.primary,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_venue.reviewCount} yorum',
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(5, 0.8),
                    _buildRatingBar(4, 0.15),
                    _buildRatingBar(3, 0.05),
                    _buildRatingBar(2, 0.0),
                    _buildRatingBar(1, 0.0),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kullanici Yorumlari',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.rate_review,
                  size: 16,
                  color: BiCikalimTheme.primary,
                ),
                label: const Text(
                  'Yorum Yaz',
                  style: TextStyle(color: BiCikalimTheme.primary),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        Expanded(
          child: _reviews.isEmpty
              ? const AppEmptyState(
                  icon: Icons.rate_review_outlined,
                  message: 'Bu mekan icin henuz yorum yapilmamis.',
                  padding: EdgeInsets.all(32),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: BiCikalimTheme.primary
                                    .withValues(alpha: 0.08),
                                radius: 18,
                                child: Text(
                                  review.userDisplayName[0],
                                  style: const TextStyle(
                                    color: BiCikalimTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.userDisplayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < review.rating
                                                  ? Icons.star
                                                  : Icons.star_border,
                                              color: BiCikalimTheme.primary,
                                              size: 12,
                                            );
                                          }),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            review.visitedActivityName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.grey.shade700,
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.comment,
                            style: const TextStyle(
                              color: BiCikalimTheme.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: Colors.grey.shade100),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double ratio) {
    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(
            fontSize: 11,
            color: BiCikalimTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                BiCikalimTheme.primary,
              ),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

class _InventoryItem {
  final Activity activity;
  final VenueActivity venueActivity;

  const _InventoryItem({required this.activity, required this.venueActivity});
}

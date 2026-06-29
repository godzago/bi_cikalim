import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_filter_chip.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../../shared/widgets/category_card.dart';
import '../../../../shared/widgets/event_preview_card.dart';
import '../../../../shared/widgets/venue_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedFilter = 'Tumu';
  late List<Venue> _displayedVenues;

  @override
  void initState() {
    super.initState();
    _displayedVenues = List.from(MockDatabase.venues);
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'Tumu' || filter == 'Bugun Acik') {
        _displayedVenues = List.from(MockDatabase.venues);
      } else if (filter == 'Bu Aksam') {
        final tonight = DateTime.now().add(const Duration(hours: 12));
        final venueIds = MockDatabase.events
            .where((event) => event.startDate.isBefore(tonight))
            .map((event) => event.venueId)
            .toSet();
        _displayedVenues = MockDatabase.venues
            .where((venue) => venueIds.contains(venue.id))
            .toList();
      } else if (filter == '4 Kisi') {
        _displayedVenues = MockDatabase.venues.where((venue) {
          final activities = MockDatabase.getActivitiesForVenue(venue.id);
          return activities.any(
            (activity) => activity.maxPeople <= 6 && activity.minPeople <= 4,
          );
        }).toList();
      } else if (filter == 'Yeni Eklenen') {
        _displayedVenues = MockDatabase.venues.reversed.take(10).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final featuredVenues = _displayedVenues.take(8).toList();
    final recommendedVenues = _buildRecommendedVenues();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'BiCikalim',
                            style: TextStyle(
                              color: BiCikalimTheme.primary,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bu aksam cikmak icin en hizli rota',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: BiCikalimTheme.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Eskisehir',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: BiCikalimTheme.primary,
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        size: 28,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        BiCikalimTheme.primary.withValues(alpha: 0.04),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => context.push('/discover/search'),
                    borderRadius: BorderRadius.circular(18),
                    child: IgnorePointer(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Mekan, kategori veya aktivite ara...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: BiCikalimTheme.primary,
                          ),
                          suffixIcon: const Icon(
                            Icons.tune,
                            color: BiCikalimTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFilterChip('Tumu'),
                      _buildFilterChip('Bugun Acik'),
                      _buildFilterChip('Bu Aksam'),
                      _buildFilterChip('4 Kisi'),
                      _buildFilterChip('Yeni Eklenen'),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AppSectionHeader(
                  title: 'Aktivite Kategorileri',
                  actionLabel: 'Tum Kategoriler',
                  onActionTap: () => context.push('/discover/catalog'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  height: 124,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: MockDatabase.categories.length,
                    itemBuilder: (context, index) {
                      final category = MockDatabase.categories[index];
                      return CategoryCard(
                        category: category,
                        onTap: () {
                          context.push(
                            Uri(
                              path: '/discover/results',
                              queryParameters: {
                                'categoryId': category.id,
                                'title': category.name,
                              },
                            ).toString(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AppSectionHeader(
                  title: 'Bu Aksam Ne Var?',
                  actionLabel: 'Tumunu Gor',
                  onActionTap: () => context.go('/events'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: SizedBox(
                  height: 188,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: MockDatabase.events.length,
                    itemBuilder: (context, index) {
                      final event = MockDatabase.events[index];
                      final venue = MockDatabase.getVenueById(event.venueId);
                      return EventPreviewCard(
                        event: event,
                        venue: venue,
                        onTap: () => context.push('/venues/${venue.id}'),
                      );
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AppSectionHeader(
                  title: 'One Cikan Mekanlar',
                  actionLabel: 'Tumunu Gor',
                  onActionTap: () => context.push(
                    Uri(
                      path: '/discover/results',
                      queryParameters: {'title': 'Tum Mekanlar'},
                    ).toString(),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 144,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  itemCount: featuredVenues.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final venue = featuredVenues[index];
                    return _FeaturedVenueRailCard(
                      venue: venue,
                      onTap: () => context.push('/venues/${venue.id}'),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AppSectionHeader(
                  title: 'Senin Icin',
                  actionLabel: 'Tumunu Gor',
                  onActionTap: () => context.push(
                    Uri(
                      path: '/discover/results',
                      queryParameters: {'title': 'Senin Icin'},
                    ).toString(),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 176,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  itemCount: recommendedVenues.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = recommendedVenues[index];
                    return _RecommendedVenueCard(
                      venue: item.venue,
                      reason: item.reason,
                      onTap: () => context.push('/venues/${item.venue.id}'),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AppSectionHeader(
                  title: 'Daha Fazla Mekan',
                  actionLabel: '${_displayedVenues.length} sonuc',
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final venue = _displayedVenues[index];
                  return VenueCard(
                    venue: venue,
                    onTap: () => context.push('/venues/${venue.id}'),
                  );
                }, childCount: _displayedVenues.length),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<_RecommendedVenueItem> _buildRecommendedVenues() {
    final pool = _displayedVenues.take(6).toList();
    final reasons = [
      'Kucuk grup planlari icin uygun',
      'Bu aksam etkinlik akisina yakin',
      'Masaustu ve sosyal deneyim dengeli',
      'Hafta ici rahat rezervasyon bulunur',
      'Etkinlik ve mekan akisi birlikte guclu',
      'Yeni denemelik bir rota olabilir',
    ];

    return List.generate(pool.length, (index) {
      return _RecommendedVenueItem(
        venue: pool[index],
        reason: reasons[index % reasons.length],
      );
    });
  }

  Widget _buildFilterChip(String label) {
    return AppFilterChip(
      label: label,
      isSelected: _selectedFilter == label,
      onTap: () => _applyFilter(label),
    );
  }
}

class _FeaturedVenueRailCard extends StatelessWidget {
  final Venue venue;
  final VoidCallback onTap;

  const _FeaturedVenueRailCard({required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: VenueCard(venue: venue, dense: true, onTap: onTap),
    );
  }
}

class _RecommendedVenueItem {
  final Venue venue;
  final String reason;

  const _RecommendedVenueItem({required this.venue, required this.reason});
}

class _RecommendedVenueCard extends StatelessWidget {
  final Venue venue;
  final String reason;
  final VoidCallback onTap;

  const _RecommendedVenueCard({
    required this.venue,
    required this.reason,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              BiCikalimTheme.primary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                venue.coverImageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: BiCikalimTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    venue.activityTags.take(2).join(' - '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BiCikalimTheme.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: BiCikalimTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${venue.averageRating} · ${venue.district}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: BiCikalimTheme.textSecondary,
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
    );
  }
}

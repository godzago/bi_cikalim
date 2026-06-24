import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_empty_state.dart';
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

  final List<Activity> _featuredActivities = [
    MockDatabase.getActivityById('catan'),
    MockDatabase.getActivityById('karaoke_odasi'),
    MockDatabase.getActivityById('padel_court'),
    MockDatabase.getActivityById('dnd_5e'),
    MockDatabase.getActivityById('vr_shooter'),
  ];

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
        _displayedVenues = MockDatabase.venues.reversed.take(8).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                child: InkWell(
                  onTap: () => context.push('/discover/search'),
                  borderRadius: BorderRadius.circular(16),
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SizedBox(
                  height: 40,
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Veri daha gorunur hale geldi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                                color: BiCikalimTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${MockDatabase.venues.length} mekan, ${MockDatabase.activities.length} aktivite ve kategori bazli kesif akisi hazir.',
                              style: const TextStyle(
                                color: BiCikalimTheme.textSecondary,
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      FilledButton(
                        onPressed: () => context.push('/discover/catalog'),
                        child: const Text('Kesfet'),
                      ),
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
                  height: 108,
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
                  title: 'One Cikan Aktiviteler',
                  actionLabel: 'Aktivite Listele',
                  onActionTap: () => context.push('/discover/catalog'),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _featuredActivities.map((activity) {
                    final category = MockDatabase.getCategoryById(
                      activity.categoryId,
                    );
                    return _ActivityFilterCard(
                      activity: activity,
                      categoryName: category.name,
                      onTap: () {
                        context.push(
                          Uri(
                            path: '/discover/results',
                            queryParameters: {
                              'activityId': activity.id,
                              'title': activity.name,
                            },
                          ).toString(),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: AppSectionHeader(
                  title: 'Bu Aksam Ne Var?',
                  actionLabel: 'Tumunu Gor',
                  onActionTap: () {},
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
                  title: 'Mekan Listesi',
                  actionLabel: '${_displayedVenues.length} sonuc',
                  onActionTap: () {},
                ),
              ),
            ),
            if (_displayedVenues.isEmpty)
              const SliverToBoxAdapter(
                child: AppEmptyState(
                  icon: Icons.search_off,
                  message: 'Bu filtreye uygun mekan bulunamadi.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final venue = _displayedVenues[index];
                    return VenueCard(
                      venue: venue,
                      dense: true,
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

  Widget _buildFilterChip(String label) {
    return AppFilterChip(
      label: label,
      isSelected: _selectedFilter == label,
      onTap: () => _applyFilter(label),
    );
  }
}

class _ActivityFilterCard extends StatelessWidget {
  final Activity activity;
  final String categoryName;
  final VoidCallback onTap;

  const _ActivityFilterCard({
    required this.activity,
    required this.categoryName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 158,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity.icon,
                size: 20,
                color: BiCikalimTheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              activity.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: BiCikalimTheme.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 11,
                color: BiCikalimTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${MockDatabase.getVenuesForActivity(activity.id).length} mekanda var',
              style: const TextStyle(
                color: BiCikalimTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

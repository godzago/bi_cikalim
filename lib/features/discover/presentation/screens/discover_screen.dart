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
  String _selectedFilter = 'T\u00fcm\u00fc';
  final TextEditingController _searchController = TextEditingController();
  List<Venue> _displayedVenues = List.from(MockDatabase.venues);
  final List<Event> _displayedEvents = List.from(MockDatabase.events);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedVenues = MockDatabase.venues.where((venue) {
        return venue.name.toLowerCase().contains(query) ||
            venue.description.toLowerCase().contains(query) ||
            venue.activityTags.any((tag) => tag.toLowerCase().contains(query));
      }).toList();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;

      if (filter == 'T\u00fcm\u00fc' || filter == 'Bug\u00fcn A\u00e7\u0131k') {
        _displayedVenues = List.from(MockDatabase.venues);
      } else if (filter == 'Bu Ak\u015fam') {
        final tonight = DateTime.now().add(const Duration(hours: 12));
        final venueIds = MockDatabase.events
            .where((event) => event.startDate.isBefore(tonight))
            .map((event) => event.venueId)
            .toSet();
        _displayedVenues = MockDatabase.venues
            .where((venue) => venueIds.contains(venue.id))
            .toList();
      } else if (filter == '4 Ki\u015fi') {
        _displayedVenues = MockDatabase.venues.where((venue) {
          return venue.activityTags.contains('Masa\u00fcst\u00fc Oyunlar') ||
              venue.activityTags.contains('Bilardo') ||
              venue.activityTags.contains('Dart');
        }).toList();
      } else if (filter == 'Yak\u0131n\u0131mda') {
        _displayedVenues = MockDatabase.venues.take(3).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bi\u00c7\u0131kal\u0131m',
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
                              'Eski\u015fehir',
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Mekan, oyun veya aktivite ara...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: BiCikalimTheme.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : const Icon(Icons.tune, color: BiCikalimTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip('T\u00fcm\u00fc'),
                    _buildFilterChip('Bug\u00fcn A\u00e7\u0131k'),
                    _buildFilterChip('Bu Ak\u015fam'),
                    _buildFilterChip('4 Ki\u015fi'),
                    _buildFilterChip('Yak\u0131n\u0131mda'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const AppSectionHeader(title: 'Aktivite Kategorileri'),
              const SizedBox(height: 12),
              SizedBox(
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
                        setState(() {
                          _searchController.text = category.name;
                        });
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              AppSectionHeader(
                title: 'Bu Ak\u015fam Ne Var?',
                actionLabel: 'T\u00fcm\u00fcn\u00fc G\u00f6r',
                onActionTap: () {},
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 188,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _displayedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _displayedEvents[index];
                    final venue = MockDatabase.venues.firstWhere(
                      (item) => item.id == event.venueId,
                    );
                    return EventPreviewCard(
                      event: event,
                      venue: venue,
                      onTap: () => context.push('/venues/${venue.id}'),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const AppSectionHeader(title: 'Pop\u00fcler Mekanlar'),
              const SizedBox(height: 12),
              _displayedVenues.isEmpty
                  ? const AppEmptyState(
                      icon: Icons.search_off,
                      message: 'Araman\u0131za uygun mekan bulunamad\u0131.',
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _displayedVenues.length,
                      itemBuilder: (context, index) {
                        final venue = _displayedVenues[index];
                        return VenueCard(
                          venue: venue,
                          onTap: () => context.push('/venues/${venue.id}'),
                        );
                      },
                    ),
            ],
          ),
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

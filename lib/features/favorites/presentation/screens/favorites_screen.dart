import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_segmented_option.dart';
import '../../../../shared/widgets/event_list_card.dart';
import '../../../../shared/widgets/venue_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final savedVenues = [
      MockDatabase.venues[0],
      MockDatabase.venues[2],
      MockDatabase.venues[5],
    ];
    final savedEvents = [MockDatabase.events[0], MockDatabase.events[3]];

    return Scaffold(
      appBar: AppBar(title: const Text('Kaydedilenler')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildToggleTab(0, 'Mekanlar (${savedVenues.length})'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildToggleTab(
                    1,
                    'Etkinlikler (${savedEvents.length})',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? _buildSavedVenuesList(savedVenues)
                : _buildSavedEventsList(savedEvents),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab(int index, String label) {
    return AppSegmentedOption(
      label: label,
      isSelected: _selectedTab == index,
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
    );
  }

  Widget _buildSavedVenuesList(List<Venue> list) {
    if (list.isEmpty) {
      return const AppEmptyState(
        icon: Icons.bookmark_border,
        message: 'Henüz kaydettiğin bir mekan bulunmuyor.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final venue = list[index];
        return VenueCard(
          venue: venue,
          onTap: () => context.push('/venues/${venue.id}'),
        );
      },
    );
  }

  Widget _buildSavedEventsList(List<Event> list) {
    if (list.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_busy,
        message: 'Henüz kaydettiğin bir etkinlik bulunmuyor.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final event = list[index];
        final venue = MockDatabase.venues.firstWhere(
          (item) => item.id == event.venueId,
        );

        return EventListCard(
          event: event,
          venue: venue,
          onTap: () => context.push('/venues/${venue.id}'),
        );
      },
    );
  }
}

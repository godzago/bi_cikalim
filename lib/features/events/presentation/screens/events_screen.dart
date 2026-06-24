import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_segmented_option.dart';
import '../../../../shared/widgets/event_list_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedDateFilter = 'Tümü';

  List<Event> _getFilteredEvents() {
    if (_selectedDateFilter == 'Bugün') {
      return MockDatabase.events.where((e) {
        final now = DateTime.now();
        return e.startDate.day == now.day &&
            e.startDate.month == now.month &&
            e.startDate.year == now.year;
      }).toList();
    } else if (_selectedDateFilter == 'Yarın') {
      return MockDatabase.events.where((e) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return e.startDate.day == tomorrow.day &&
            e.startDate.month == tomorrow.month &&
            e.startDate.year == tomorrow.year;
      }).toList();
    }
    return MockDatabase.events;
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      appBar: AppBar(title: const Text('Etkinlikler')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildDateSegment('Tümü'),
                const SizedBox(width: 8),
                _buildDateSegment('Bugün'),
                const SizedBox(width: 8),
                _buildDateSegment('Yarın'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredEvents.isEmpty
                ? const AppEmptyState(
                    icon: Icons.event_busy,
                    message: 'Bu tarih için etkinlik bulunmuyor.',
                    padding: EdgeInsets.all(32),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final venue = MockDatabase.venues.firstWhere(
                        (v) => v.id == event.venueId,
                      );

                      return EventListCard(
                        event: event,
                        venue: venue,
                        onTap: () => context.push('/venues/${venue.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSegment(String label) {
    return AppSegmentedOption(
      label: label,
      isSelected: _selectedDateFilter == label,
      onTap: () {
        setState(() {
          _selectedDateFilter = label;
        });
      },
    );
  }
}

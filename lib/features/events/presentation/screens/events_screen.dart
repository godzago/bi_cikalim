import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_segmented_option.dart';
import '../../../../shared/widgets/event_list_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedDateFilter = 'Tumu';
  String _selectedCategoryFilter = 'Tumu';

  List<Event> _getFilteredEvents() {
    var filtered = List<Event>.from(MockDatabase.events);

    if (_selectedDateFilter == 'Bugun') {
      filtered = filtered.where((event) {
        final now = DateTime.now();
        return event.startDate.day == now.day &&
            event.startDate.month == now.month &&
            event.startDate.year == now.year;
      }).toList();
    } else if (_selectedDateFilter == 'Yarin') {
      filtered = filtered.where((event) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return event.startDate.day == tomorrow.day &&
            event.startDate.month == tomorrow.month &&
            event.startDate.year == tomorrow.year;
      }).toList();
    } else if (_selectedDateFilter == 'Bu Hafta') {
      final weekLimit = DateTime.now().add(const Duration(days: 7));
      filtered = filtered
          .where((event) => event.startDate.isBefore(weekLimit))
          .toList();
    }

    if (_selectedCategoryFilter != 'Tumu') {
      filtered = filtered
          .where((event) => event.category == _selectedCategoryFilter)
          .toList();
    }

    filtered.sort((left, right) => left.startDate.compareTo(right.startDate));
    return filtered;
  }

  List<String> _getEventCategories() {
    final categories =
        MockDatabase.events.map((event) => event.category).toSet().toList()
          ..sort();
    return ['Tumu', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();
    final categories = _getEventCategories();
    final highlightedEvents = filteredEvents.take(3).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Etkinlikler')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: BiCikalimTheme.primary.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: BiCikalimTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${filteredEvents.length} etkinlik listeleniyor · veri yogunlugu artirilmis demo akis',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: BiCikalimTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildDateSegment('Tumu'),
                const SizedBox(width: 8),
                _buildDateSegment('Bugun'),
                const SizedBox(width: 8),
                _buildDateSegment('Yarin'),
                const SizedBox(width: 8),
                _buildDateSegment('Bu Hafta'),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: categories.map((category) {
                final isSelected = _selectedCategoryFilter == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategoryFilter = category;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BiCikalimTheme.primary
                            : BiCikalimTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : BiCikalimTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (highlightedEvents.isNotEmpty)
            SizedBox(
              height: 88,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: highlightedEvents.map((event) {
                  final venue = MockDatabase.getVenueById(event.venueId);
                  return _EventSummaryPill(
                    event: event,
                    venue: venue,
                    onTap: () => context.push('/venues/${venue.id}'),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: filteredEvents.isEmpty
                ? const AppEmptyState(
                    icon: Icons.event_busy,
                    message: 'Bu filtre kombinasyonu icin etkinlik bulunmuyor.',
                    padding: EdgeInsets.all(32),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final venue = MockDatabase.getVenueById(event.venueId);

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

class _EventSummaryPill extends StatelessWidget {
  final Event event;
  final Venue venue;
  final VoidCallback onTap;

  const _EventSummaryPill({
    required this.event,
    required this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        '${event.startDate.day}.${event.startDate.month} ${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.category,
                      style: const TextStyle(
                        color: BiCikalimTheme.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 10,
                      color: BiCikalimTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                event.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: BiCikalimTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                venue.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: BiCikalimTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

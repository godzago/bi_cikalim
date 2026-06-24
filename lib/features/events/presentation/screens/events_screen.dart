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

    return Scaffold(
      appBar: AppBar(title: const Text('Etkinlikler')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    BiCikalimTheme.primary.withValues(alpha: 0.1),
                    BiCikalimTheme.primary.withValues(alpha: 0.03),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.event_available,
                      color: BiCikalimTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${filteredEvents.length} etkinlik listelendi. Tarih ve kategori secerek akisi daraltabilirsin.',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: BiCikalimTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (_, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategoryFilter == category;
                return InkWell(
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
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
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

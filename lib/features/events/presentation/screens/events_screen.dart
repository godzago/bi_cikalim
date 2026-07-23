import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';
import '../../../../shared/widgets/app_segmented_option.dart';
import '../../../../shared/widgets/event_list_card.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  String _selectedDateFilter = 'Tumu';
  String _selectedCategoryFilter = 'Tumu';

  List<ApiEvent> _getFilteredEvents(List<ApiEvent> events) {
    var filtered = List<ApiEvent>.from(events);

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

  List<String> _getEventCategories(List<ApiEvent> events) {
    final categories = events.map((event) => event.category).toSet().toList()
      ..sort();
    return ['Tumu', ...categories];
  }

  @override
  Widget build(BuildContext context) {
    final citySlug = ref.watch(selectedCityProvider).value?.slug;
    final provider = eventsListProvider(EventFilters(citySlug: citySlug));
    final eventsAsync = ref.watch(provider);

    Future<void> refreshEvents() async {
      ref.invalidate(provider);
      await ref.read(provider.future);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
        actions: [
          IconButton(
            tooltip: 'Bu Akşam Ne Yapsak?',
            onPressed: () => context.push('/events/tonight'),
            icon: const Icon(Icons.style_outlined),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: eventsAsync.when(
          loading: () => AppRefreshableContent(
            key: ValueKey('events-loading'),
            onRefresh: refreshEvents,
            child: const Center(
              child: CircularProgressIndicator(color: BiCikalimTheme.primary),
            ),
          ),
          error: (error, _) => AppRefreshableContent(
            key: const ValueKey('events-error'),
            onRefresh: refreshEvents,
            child: Center(child: Text('Hata: $error')),
          ),
          data: (events) {
            final filteredEvents = _getFilteredEvents(events);
            final categories = _getEventCategories(events);

            return Column(
              key: const ValueKey('events-content'),
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
                            '${filteredEvents.length} etkinlik listelendi. Tarih ve kategori seçerek akışı daraltabilirsin.',
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
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: filteredEvents.isEmpty
                        ? AppRefreshableContent(
                            key: ValueKey('events-empty'),
                            onRefresh: refreshEvents,
                            child: const AppEmptyState(
                              icon: Icons.event_busy,
                              message:
                                  'Bu filtre kombinasyonu için etkinlik bulunmuyor.',
                              padding: EdgeInsets.all(32),
                            ),
                          )
                        : RefreshIndicator(
                            key: const ValueKey('events-list'),
                            color: BiCikalimTheme.primary,
                            onRefresh: refreshEvents,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                final event = filteredEvents[index];

                                return EventListCard(
                                  event: event,
                                  onTap: () =>
                                      context.push('/events/${event.slug}'),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
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

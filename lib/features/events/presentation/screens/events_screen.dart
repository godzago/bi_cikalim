import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
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
            child: AppErrorState(
              error: error,
              title: 'Etkinlikler yüklenemedi',
              onRetry: refreshEvents,
            ),
          ),
          data: (events) {
            final filteredEvents = _getFilteredEvents(events);
            final categories = _getEventCategories(events);

            return Column(
              key: const ValueKey('events-content'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: AppDensity.screenInsets(context, top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
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
                          width: 36,
                          height: 36,
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
                            '${filteredEvents.length} etkinlik listelendi',
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.25,
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
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(
                      AppDensity.screenPadding(context),
                      8,
                      AppDensity.screenPadding(context),
                      0,
                    ),
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
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDensity.screenPadding(context),
                    ),
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
                            vertical: 7,
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
                const SizedBox(height: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: filteredEvents.isEmpty
                        ? AppRefreshableContent(
                            key: ValueKey('events-empty'),
                            onRefresh: refreshEvents,
                            child: Column(
                              children: [
                                _buildTonightPlanCard(events),
                                const Expanded(
                                  child: AppEmptyState(
                                    icon: Icons.event_busy,
                                    title:
                                        'Şu anda yayınlanmış bir etkinlik bulunmuyor',
                                    message:
                                        'Yine de şehirde yapabileceğin aktiviteleri keşfedebilirsin.',
                                    padding: EdgeInsets.all(32),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            key: const ValueKey('events-list'),
                            color: BiCikalimTheme.primary,
                            onRefresh: refreshEvents,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: filteredEvents.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return _buildTonightPlanCard(events);
                                }

                                final event = filteredEvents[index - 1];

                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppDensity.screenPadding(
                                      context,
                                    ),
                                  ),
                                  child: EventListCard(
                                    event: event,
                                    onTap: () =>
                                        context.push('/events/${event.slug}'),
                                  ),
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

  Widget _buildTonightPlanCard(List<ApiEvent> events) {
    final tonightEvents = events.where(_isTonight).toList();
    final suggestionLabels = (tonightEvents.isNotEmpty ? tonightEvents : events)
        .take(0)
        .map((event) => event.title)
        .where((title) => title.trim().isNotEmpty)
        .toList();
    final countLabel = tonightEvents.isEmpty
        ? 'Aktivite ve etkinlik önerilerini gör.'
        : '${tonightEvents.length} öneri hazır.';

    return Padding(
      padding: AppDensity.screenInsets(context, top: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/events/tonight'),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFFFF8F4), Color(0xFFFFF1EA)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -18,
                  bottom: -22,
                  child: Icon(
                    Icons.style_outlined,
                    color: BiCikalimTheme.primary.withValues(alpha: 0.05),
                    size: 96,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: BiCikalimTheme.primary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: BiCikalimTheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                              ),
                            ),
                            child: const Text(
                              'Bu Akşam',
                              style: TextStyle(
                                color: BiCikalimTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFEFE7),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: BiCikalimTheme.primary,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Bu Akşam Ne Yapsak?',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: BiCikalimTheme.textPrimary,
                          fontSize: 16,
                          height: 1.12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        countLabel,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (suggestionLabels.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: suggestionLabels
                              .map((label) => _EventSuggestionPill(label))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isTonight(ApiEvent event) {
    final local = event.startDate;
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
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

class _EventSuggestionPill extends StatelessWidget {
  final String label;

  const _EventSuggestionPill(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

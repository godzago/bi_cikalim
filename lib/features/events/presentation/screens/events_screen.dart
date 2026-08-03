import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_filter_controls.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';
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
                _buildFilterSummary(
                  filteredCount: filteredEvents.length,
                  categories: categories,
                ),
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
                                    horizontal: context.layout.screenPadding,
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
        .take(3)
        .map((event) => event.title)
        .where((title) => title.trim().isNotEmpty)
        .toList();
    final countLabel = tonightEvents.isEmpty
        ? 'Aktivite ve etkinlik önerilerini gör.'
        : '${tonightEvents.length} öneri hazır.';
    final visualEvent = (tonightEvents.isNotEmpty ? tonightEvents : events)
        .where((event) => event.imageUrl.trim().isNotEmpty)
        .firstOrNull;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        4,
        context.layout.screenPadding,
        6,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/events/tonight'),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: visualEvent == null
                    ? const [
                        Color(0xFF1D1714),
                        Color(0xFF563021),
                        BiCikalimTheme.primaryDark,
                      ]
                    : const [Color(0xFF171210), Color(0xFF3B211A)],
              ),
              boxShadow: [
                BoxShadow(
                  color: BiCikalimTheme.primary.withValues(alpha: 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (visualEvent != null)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.46,
                      child: AppNetworkImage(
                        imageUrl: visualEvent.imageUrl,
                        fit: BoxFit.cover,
                        semanticLabel: '${visualEvent.title} görseli',
                      ),
                    ),
                  ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.black.withValues(alpha: 0.36),
                          Colors.black.withValues(alpha: 0.08),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -18,
                  bottom: -22,
                  child: Icon(
                    Icons.style_outlined,
                    color: Colors.white.withValues(alpha: 0.08),
                    size: 96,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(context.layout.cardPadding),
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
                              color: Colors.white.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: const Text(
                              'Bu Akşam',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
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
                          color: Colors.white,
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
                          color: Colors.white.withValues(alpha: 0.78),
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

  Widget _buildFilterSummary({
    required int filteredCount,
    required List<String> categories,
  }) {
    final activeCount =
        (_selectedDateFilter == 'Tumu' ? 0 : 1) +
        (_selectedCategoryFilter == 'Tumu' ? 0 : 1);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        6,
        context.layout.screenPadding,
        2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$filteredCount etkinlik • ${_filterSummaryText()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: BiCikalimTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          AppFilterButton(
            onPressed: () => _showFilterSheet(categories),
            activeCount: activeCount,
          ),
        ],
      ),
    );
  }

  String _filterSummaryText() {
    final date = _filterLabel(_selectedDateFilter);
    if (_selectedCategoryFilter == 'Tumu') return date;
    return '$date, $_selectedCategoryFilter';
  }

  String _filterLabel(String value) {
    return switch (value) {
      'Bugun' => 'Bugün',
      'Yarin' => 'Yarın',
      'Bu Hafta' => 'Bu hafta',
      _ => 'Tümü',
    };
  }

  Future<void> _showFilterSheet(List<String> categories) async {
    var dateFilter = _selectedDateFilter;
    var categoryFilter = _selectedCategoryFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget optionChip({
              required String label,
              required bool selected,
              required VoidCallback onSelected,
            }) {
              return AppFilterChoiceChip(
                label: label,
                selected: selected,
                onTap: onSelected,
              );
            }

            return AppFilterSheet(
              clearEnabled: dateFilter != 'Tumu' || categoryFilter != 'Tumu',
              onClear: () {
                setSheetState(() {
                  dateFilter = 'Tumu';
                  categoryFilter = 'Tumu';
                });
              },
              onApply: () {
                setState(() {
                  _selectedDateFilter = dateFilter;
                  _selectedCategoryFilter = categoryFilter;
                });
                Navigator.pop(context);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppFilterSectionTitle('Tarih'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Tumu', 'Bugun', 'Yarin', 'Bu Hafta']
                        .map(
                          (value) => optionChip(
                            label: _filterLabel(value),
                            selected: dateFilter == value,
                            onSelected: () =>
                                setSheetState(() => dateFilter = value),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  const AppFilterSectionTitle('Kategori'),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 190),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: categories
                            .map(
                              (category) => optionChip(
                                label: category == 'Tumu' ? 'Tümü' : category,
                                selected: categoryFilter == category,
                                onSelected: () => setSheetState(
                                  () => categoryFilter = category,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isTonight(ApiEvent event) {
    final local = event.startDate;
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
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

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
import '../../../../shared/widgets/venue_card.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  int _selectedTab = 0;

  Future<void> _refreshVenues() async {
    ref.invalidate(favoriteVenuesProvider);
    await ref.read(favoriteVenuesProvider.future);
  }

  Future<void> _refreshEvents() async {
    ref.invalidate(favoriteEventsProvider);
    await ref.read(favoriteEventsProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteVenuesAsync = ref.watch(favoriteVenuesProvider);
    final favoriteEventsAsync = ref.watch(favoriteEventsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Kaydedilenler')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: favoriteVenuesAsync.when(
                    loading: () => _buildToggleTab(0, 'Mekanlar (...)'),
                    error: (_, _) => _buildToggleTab(0, 'Mekanlar (Hata)'),
                    data: (list) =>
                        _buildToggleTab(0, 'Mekanlar (${list.length})'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: favoriteEventsAsync.when(
                    loading: () => _buildToggleTab(1, 'Etkinlikler (...)'),
                    error: (_, _) => _buildToggleTab(1, 'Etkinlikler (Hata)'),
                    data: (list) =>
                        _buildToggleTab(1, 'Etkinlikler (${list.length})'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? favoriteVenuesAsync.when(
                    loading: () => AppRefreshableContent(
                      onRefresh: _refreshVenues,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: BiCikalimTheme.primary,
                        ),
                      ),
                    ),
                    error: (err, _) => AppRefreshableContent(
                      onRefresh: _refreshVenues,
                      child: Center(child: Text('Mekanlar yüklenemedi: $err')),
                    ),
                    data: (list) => _buildSavedVenuesList(list),
                  )
                : favoriteEventsAsync.when(
                    loading: () => AppRefreshableContent(
                      onRefresh: _refreshEvents,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: BiCikalimTheme.primary,
                        ),
                      ),
                    ),
                    error: (err, _) => AppRefreshableContent(
                      onRefresh: _refreshEvents,
                      child: Center(
                        child: Text('Etkinlikler yüklenemedi: $err'),
                      ),
                    ),
                    data: (list) => _buildSavedEventsList(list),
                  ),
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

  Widget _buildSavedVenuesList(List<ApiVenue> list) {
    if (list.isEmpty) {
      return AppRefreshableContent(
        onRefresh: _refreshVenues,
        child: const AppEmptyState(
          icon: Icons.bookmark_border,
          message: 'Henüz kaydettiğin bir mekan bulunmuyor.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshVenues,
      color: BiCikalimTheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final venue = list[index];
          return VenueCard(
            venue: venue,
            onTap: () => context.push('/venues/${venue.slug}'),
          );
        },
      ),
    );
  }

  Widget _buildSavedEventsList(List<ApiEvent> list) {
    if (list.isEmpty) {
      return AppRefreshableContent(
        onRefresh: _refreshEvents,
        child: const AppEmptyState(
          icon: Icons.event_busy,
          message: 'Henüz kaydettiğin bir etkinlik bulunmuyor.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      color: BiCikalimTheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final event = list[index];

          return EventListCard(
            event: event,
            onTap: () => context.push('/events/${event.slug}'),
          );
        },
      ),
    );
  }
}

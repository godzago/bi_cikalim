import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
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
      appBar: AppBar(title: const Text('Favorilerim')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.layout.screenPadding,
              vertical: 8,
            ),
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
                      child: AppErrorState(
                        error: err,
                        title: 'Mekanlar yüklenemedi',
                        onRetry: _refreshVenues,
                      ),
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
                      child: AppErrorState(
                        error: err,
                        title: 'Etkinlikler yüklenemedi',
                        onRetry: _refreshEvents,
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
          icon: Icons.favorite_border_rounded,
          title: 'Henüz favori mekanın yok',
          message:
              'Beğendiğin mekânları favorilerine ekleyerek daha sonra kolayca bulabilirsin.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshVenues,
      color: BiCikalimTheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.layout.screenPadding,
          vertical: 6,
        ),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final venue = list[index];
          return VenueCard(
            venue: venue,
            dense: true,
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
          title: 'Henüz favori etkinliğin yok',
          message:
              'İlgini çeken etkinlikleri favorilerine ekleyerek daha sonra hızlıca ulaşabilirsin.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshEvents,
      color: BiCikalimTheme.primary,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: context.layout.screenPadding,
          vertical: 6,
        ),
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

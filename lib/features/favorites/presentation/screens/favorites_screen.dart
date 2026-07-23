import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
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
                    error: (_, __) => _buildToggleTab(0, 'Mekanlar (Hata)'),
                    data: (list) => _buildToggleTab(0, 'Mekanlar (${list.length})'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: favoriteEventsAsync.when(
                    loading: () => _buildToggleTab(1, 'Etkinlikler (...)'),
                    error: (_, __) => _buildToggleTab(1, 'Etkinlikler (Hata)'),
                    data: (list) => _buildToggleTab(1, 'Etkinlikler (${list.length})'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 0
                ? favoriteVenuesAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: BiCikalimTheme.primary)),
                    error: (err, _) => Center(child: Text('Mekanlar yüklenemedi: $err')),
                    data: (list) => _buildSavedVenuesList(list),
                  )
                : favoriteEventsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator(color: BiCikalimTheme.primary)),
                    error: (err, _) => Center(child: Text('Etkinlikler yüklenemedi: $err')),
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
      return const AppEmptyState(
        icon: Icons.bookmark_border,
        message: 'Henüz kaydettiğin bir mekan bulunmuyor.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(favoriteVenuesProvider),
      color: BiCikalimTheme.primary,
      child: ListView.builder(
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
      return const AppEmptyState(
        icon: Icons.event_busy,
        message: 'Henüz kaydettiğin bir etkinlik bulunmuyor.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(favoriteEventsProvider),
      color: BiCikalimTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final event = list[index];
          final venue = ApiVenue(
            id: event.venueId,
            name: event.venue?.name ?? 'Mekan',
            slug: event.venue?.slug ?? 'mekan',
            venueType: 'cafe',
            city: ApiLocationSummary(id: '1', name: 'Eskişehir', slug: 'eskisehir'),
            isVerified: true,
            isFavorite: false,
            activitySummary: const [],
            coverUrl: event.coverUrl,
          );

          return EventListCard(
            event: event,
            venue: venue,
            onTap: () => context.push('/venues/${venue.slug}'),
          );
        },
      ),
    );
  }
}

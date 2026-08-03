import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';
import '../../../../shared/widgets/venue_card.dart';

class DiscoverResultsScreen extends ConsumerWidget {
  final String? query;
  final String? categoryId;
  final String? subcategoryId;
  final String? activityId;
  final String? categorySlug;
  final String? subcategorySlug;
  final String? activitySlug;
  final String? title;

  const DiscoverResultsScreen({
    super.key,
    this.query,
    this.categoryId,
    this.subcategoryId,
    this.activityId,
    this.categorySlug,
    this.subcategorySlug,
    this.activitySlug,
    this.title,
  });

  Future<void> _refreshSelectedCity(WidgetRef ref) async {
    ref.invalidate(selectedCityProvider);
    await ref.read(selectedCityProvider.future);
  }

  Future<void> _refreshVenues(
    WidgetRef ref,
    FutureProvider<List<ApiVenue>> provider,
  ) async {
    ref.invalidate(provider);
    await ref.read(provider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCityAsync = ref.watch(selectedCityProvider);
    return Scaffold(
      appBar: AppBar(title: Text(title ?? 'Mekanlar')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: selectedCityAsync.when(
          loading: () => AppRefreshableContent(
            key: const ValueKey('selected-city-loading'),
            onRefresh: () => _refreshSelectedCity(ref),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => AppRefreshableContent(
            key: const ValueKey('selected-city-error'),
            onRefresh: () => _refreshSelectedCity(ref),
            child: AppEmptyState(
              icon: Icons.location_off,
              message: 'Şehir bilgisi okunamadı.\n$error',
            ),
          ),
          data: (city) {
            final scope = categorySlug != null
                ? 'category'
                : subcategorySlug != null
                ? 'subcategory'
                : activitySlug != null
                ? 'activity'
                : null;
            final slug = categorySlug ?? subcategorySlug ?? activitySlug;

            if (scope != null && city == null) {
              return AppRefreshableContent(
                key: const ValueKey('city-required'),
                onRefresh: () => _refreshSelectedCity(ref),
                child: AppEmptyState(
                  icon: Icons.location_city,
                  message:
                      'Aktiviteye göre mekan bulmak için şehir seçmelisin.',
                  actionLabel: 'Şehir Seç',
                  onAction: () => context.push('/city-select'),
                ),
              );
            }

            final FutureProvider<List<ApiVenue>> venuesProvider;
            if (scope != null && slug != null) {
              venuesProvider = discoveryVenuesProvider(
                DiscoveryVenueFilters(
                  scope: scope,
                  slug: slug,
                  citySlug: city!.slug,
                  query: query,
                ),
              );
            } else {
              venuesProvider = venuesListProvider(
                VenueFilters(citySlug: city?.slug, q: query),
              );
            }
            final venuesAsync = ref.watch(venuesProvider);

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: venuesAsync.when(
                loading: () => AppRefreshableContent(
                  key: const ValueKey('venues-loading'),
                  onRefresh: () => _refreshVenues(ref, venuesProvider),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => AppRefreshableContent(
                  key: const ValueKey('venues-error'),
                  onRefresh: () => _refreshVenues(ref, venuesProvider),
                  child: AppEmptyState(
                    icon: Icons.cloud_off,
                    message: 'Mekanlar yüklenemedi.\n$error',
                  ),
                ),
                data: (venues) {
                  if (venues.isEmpty) {
                    return AppRefreshableContent(
                      key: const ValueKey('venues-empty'),
                      onRefresh: () => _refreshVenues(ref, venuesProvider),
                      child: const AppEmptyState(
                        icon: Icons.storefront_outlined,
                        message: 'Bu seçim için mekan bulunamadı.',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    key: const ValueKey('venues-content'),
                    onRefresh: () async {
                      await _refreshVenues(ref, venuesProvider);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: AppDensity.screenInsets(
                        context,
                        top: 10,
                        bottom: 16,
                      ),
                      itemCount: venues.length,
                      itemBuilder: (context, index) {
                        final venue = venues[index];
                        return VenueCard(
                          venue: venue,
                          onTap: () => context.push('/venues/${venue.slug}'),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

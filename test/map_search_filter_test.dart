import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/features/map/presentation/screens/map_screen.dart';
import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void configureCompactView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'map search debounces and applies an exact activity filter without overflow',
    (tester) async {
      configureCompactView(tester);
      final requestedFilters = <VenueFilters>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedCityProvider.overrideWith(_NoCityNotifier.new),
            categoriesProvider.overrideWith((_) async => const [_games]),
            searchResultsProvider.overrideWith(
              (_, _) async => const ApiSearchResult(
                query: 'billiards',
                taxonomy: [
                  ApiSearchTaxonomyItem(
                    id: 'billiards',
                    type: 'activity',
                    name: 'Billiards',
                    slug: 'billiards',
                  ),
                ],
                venues: [],
                events: [],
                total: 1,
              ),
            ),
            mapVenuesProvider.overrideWith((_, filters) async {
              requestedFilters.add(filters);
              return MapVenueResult(
                venues: filters.activitySlug == 'billiards'
                    ? const [_billiardsVenue]
                    : const [_billiardsVenue, _sportsVenue],
                total: filters.activitySlug == 'billiards' ? 1 : 2,
                pages: 1,
                loadedCount: filters.activitySlug == 'billiards' ? 1 : 2,
                invalidCoordinateCount: 0,
                detailFailureCount: 0,
              );
            }),
          ],
          child: const MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(
                size: Size(320, 568),
                textScaler: TextScaler.linear(1.5),
              ),
              child: MapScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final field = find.byKey(const ValueKey('map-search-field'));
      await tester.tap(field);
      await tester.enterText(field, 'Billiards');
      await tester.pump(const Duration(milliseconds: 349));
      expect(find.text('Activities'), findsNothing);

      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.text('Activities'), findsOneWidget);
      await tester.tap(find.text('Billiards').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const ValueKey('map-search-overlay')), findsNothing);
      expect(
        find.byKey(const ValueKey('map-active-activity-filter')),
        findsOneWidget,
      );
      expect(requestedFilters.last.activitySlug, 'billiards');
      expect(
        find.byKey(const ValueKey('map-marker-billiards-venue')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('map-marker-sports-venue')),
        findsNothing,
      );

      await tester.tap(
        find.byKey(const ValueKey('map-marker-billiards-venue')),
      );
      await tester.pump();
      expect(
        find.textContaining('Billiards · Uygun · 120 TRY'),
        findsOneWidget,
      );
      expect(find.text('Detay'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'venue and event results stay on the map and show compact previews',
    (tester) async {
      configureCompactView(tester);
      final event = ApiEvent(
        id: 'event',
        title: 'Billiards Tournament',
        slug: 'billiards-tournament',
        startAt: DateTime(2026, 8, 12, 20),
        timezone: 'Europe/Istanbul',
        status: 'published',
        priceType: 'free',
        currency: 'TRY',
        city: _city,
        venue: const ApiEventVenueSummary(
          id: 'billiards-venue',
          name: 'Blue Game House',
          slug: 'blue-game-house',
        ),
        activities: const [],
        isFavorite: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedCityProvider.overrideWith(_NoCityNotifier.new),
            categoriesProvider.overrideWith((_) async => const [_games]),
            mapVenuesProvider.overrideWith(
              (_, _) async => const MapVenueResult(
                venues: [],
                total: 0,
                pages: 0,
                loadedCount: 0,
                invalidCoordinateCount: 0,
                detailFailureCount: 0,
              ),
            ),
            searchResultsProvider.overrideWith(
              (_, _) async => const ApiSearchResult(
                query: 'blue',
                taxonomy: [
                  ApiSearchTaxonomyItem(
                    id: 'billiards',
                    type: 'activity',
                    name: 'Billiards',
                    slug: 'billiards',
                  ),
                ],
                venues: [
                  ApiSearchVenueItem(
                    id: 'billiards-venue',
                    name: 'Blue Game House',
                    slug: 'blue-game-house',
                    city: _city,
                  ),
                ],
                events: [
                  ApiSearchEventItem(
                    id: 'event',
                    title: 'Billiards Tournament',
                    slug: 'billiards-tournament',
                    city: _city,
                  ),
                ],
                total: 3,
              ),
            ),
            venueDetailProvider.overrideWith((_, _) async => _billiardsVenue),
            eventDetailProvider.overrideWith((_, _) async => event),
          ],
          child: const MaterialApp(home: MapScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final field = find.byKey(const ValueKey('map-search-field'));
      await tester.tap(field);
      await tester.enterText(field, 'Blue');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();

      expect(find.text('Activities'), findsOneWidget);
      expect(find.text('Venues'), findsOneWidget);
      expect(find.text('Events'), findsOneWidget);
      await tester.tap(find.text('Blue Game House'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const ValueKey('map-search-overlay')), findsNothing);
      expect(find.text('Yol Tarifi'), findsOneWidget);

      await tester.tap(field);
      await tester.enterText(field, 'Tournament');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pump();
      await tester.tap(find.text('Billiards Tournament'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const ValueKey('map-search-overlay')), findsNothing);
      expect(find.text('Etkinlik'), findsOneWidget);
      expect(find.text('Mekan'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _NoCityNotifier extends SelectedCityNotifier {
  @override
  Future<ApiCity?> build() async => null;
}

const _city = ApiLocationSummary(
  id: 'city',
  name: 'Eskişehir',
  slug: 'eskisehir',
);

const _games = ApiCategory(
  id: 'games',
  name: 'Games',
  slug: 'games',
  isActive: true,
  sortOrder: 0,
);

const _billiardsVenue = ApiVenue(
  id: 'billiards-venue',
  name: 'Blue Game House',
  slug: 'blue-game-house',
  venueType: 'game',
  city: _city,
  latitude: 39.7767,
  longitude: 30.5206,
  isVerified: true,
  isFavorite: false,
  activitySummary: [
    ApiVenueActivitySummary(
      id: 'venue-activity',
      activityId: 'billiards',
      activityName: 'Billiards',
      activitySlug: 'billiards',
      availability: 'available',
      isPaid: true,
      price: 120,
      priceUnit: 'TRY',
    ),
  ],
  ratingAverage: 4.8,
  ratingCount: 24,
);

const _sportsVenue = ApiVenue(
  id: 'sports-venue',
  name: 'Sports Center',
  slug: 'sports-center',
  venueType: 'sport',
  city: _city,
  latitude: 39.78,
  longitude: 30.53,
  isVerified: true,
  isFavorite: false,
  activitySummary: [],
);

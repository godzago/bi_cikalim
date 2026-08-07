import 'dart:async';

import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/core/services/api_services.dart';
import 'package:bi_cikalim/features/discover/presentation/screens/advanced_discover_results_screen.dart';
import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void verifyRouteSlugUsesGenericFilter({
    required String scope,
    String? categorySlug,
    String? subcategorySlug,
    String? activitySlug,
  }) {
    testWidgets('$scope route slug uses the generic venue filters', (
      tester,
    ) async {
      final venueService = _FakeVenueApiService()
        ..responses.add(
          Future.value(_page(items: [_venue('venue-1'), _venue('venue-1')])),
        );

      await tester.pumpWidget(
        _testApp(
          venueService,
          AdvancedDiscoverResultsScreen(
            scope: scope,
            categorySlug: categorySlug,
            subcategorySlug: subcategorySlug,
            activitySlug: activitySlug,
            citySlug: 'istanbul',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(venueService.requests, hasLength(1));
      expect(venueService.requests.single.citySlug, 'istanbul');
      expect(venueService.requests.single.activityCategorySlug, categorySlug);
      expect(
        venueService.requests.single.activitySubCategorySlug,
        subcategorySlug,
      );
      expect(venueService.requests.single.activitySlug, activitySlug);
      expect(venueService.discoveryRequestCount, 0);
      expect(find.text('Mekan venue-1'), findsOneWidget);
    });
  }

  verifyRouteSlugUsesGenericFilter(
    scope: 'category',
    categorySlug: 'masa-oyunlari',
  );
  verifyRouteSlugUsesGenericFilter(
    scope: 'subcategory',
    subcategorySlug: 'strateji-oyunlari',
  );
  verifyRouteSlugUsesGenericFilter(scope: 'activity', activitySlug: 'satranc');

  testWidgets('a stale first page cannot replace a newer refresh', (
    tester,
  ) async {
    final firstRequest = Completer<ApiPaginatedResponse<ApiVenue>>();
    final refreshRequest = Completer<ApiPaginatedResponse<ApiVenue>>();
    final venueService = _FakeVenueApiService()
      ..responses.addAll([firstRequest.future, refreshRequest.future]);

    await tester.pumpWidget(
      _testApp(
        venueService,
        const AdvancedDiscoverResultsScreen(citySlug: 'istanbul'),
      ),
    );
    await tester.pump();
    expect(venueService.requests, hasLength(1));

    final refresh = tester.state<RefreshIndicatorState>(
      find.byType(RefreshIndicator),
    );
    unawaited(refresh.show());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
    expect(venueService.requests, hasLength(2));

    refreshRequest.complete(_page(items: [_venue('new')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Mekan new'), findsOneWidget);

    firstRequest.complete(_page(items: [_venue('stale')]));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Mekan new'), findsOneWidget);
    expect(find.text('Mekan stale'), findsNothing);
  });
}

Widget _testApp(VenueApiService venueService, Widget child) {
  return ProviderScope(
    overrides: [
      selectedCityProvider.overrideWith(_EmptySelectedCityNotifier.new),
      venueApiServiceProvider.overrideWithValue(venueService),
      analyticsApiServiceProvider.overrideWithValue(_FakeAnalyticsApiService()),
    ],
    child: MaterialApp(home: child),
  );
}

class _EmptySelectedCityNotifier extends SelectedCityNotifier {
  @override
  Future<ApiCity?> build() async => null;
}

class _VenueRequest {
  final String? citySlug;
  final String? activityCategorySlug;
  final String? activitySubCategorySlug;
  final String? activitySlug;

  const _VenueRequest({
    this.citySlug,
    this.activityCategorySlug,
    this.activitySubCategorySlug,
    this.activitySlug,
  });
}

class _FakeVenueApiService extends VenueApiService {
  final responses = <Future<ApiPaginatedResponse<ApiVenue>>>[];
  final requests = <_VenueRequest>[];
  int discoveryRequestCount = 0;

  @override
  Future<ApiPaginatedResponse<ApiVenue>> fetchVenuesPage({
    int page = 1,
    int pageSize = 20,
    String? citySlug,
    String? districtSlug,
    String? neighborhoodSlug,
    String? activityCategorySlug,
    String? activitySubCategorySlug,
    String? activitySlug,
    String? tagSlug,
    String? q,
    bool? hasCoordinates,
    bool? isVerified,
  }) {
    requests.add(
      _VenueRequest(
        citySlug: citySlug,
        activityCategorySlug: activityCategorySlug,
        activitySubCategorySlug: activitySubCategorySlug,
        activitySlug: activitySlug,
      ),
    );
    return responses.removeAt(0);
  }

  @override
  Future<ApiPaginatedResponse<ApiVenue>> fetchVenuesForDiscovery({
    required String scope,
    required String slug,
    required String citySlug,
    int page = 1,
    int pageSize = 20,
    String? districtSlug,
    String? neighborhoodSlug,
    String? tagSlug,
    String? q,
  }) {
    discoveryRequestCount++;
    throw StateError('Scoped endpoint should not be used by this screen.');
  }
}

class _FakeAnalyticsApiService extends AnalyticsApiService {
  @override
  void track({
    required String eventName,
    String? cityId,
    String? venueId,
    String? activityId,
    String? eventRefId,
    Map<String, dynamic> properties = const {},
  }) {}
}

ApiPaginatedResponse<ApiVenue> _page({required List<ApiVenue> items}) {
  return ApiPaginatedResponse<ApiVenue>(
    items: items,
    total: items.length,
    page: 1,
    pageSize: 20,
    pages: 1,
  );
}

ApiVenue _venue(String id) {
  return ApiVenue(
    id: id,
    name: 'Mekan $id',
    slug: 'mekan-$id',
    venueType: 'other',
    city: const ApiLocationSummary(
      id: 'city-1',
      name: 'Istanbul',
      slug: 'istanbul',
    ),
    isVerified: false,
    isFavorite: false,
    activitySummary: const [],
  );
}

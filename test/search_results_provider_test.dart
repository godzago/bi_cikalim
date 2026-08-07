import 'dart:async';

import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/core/services/api_services.dart';
import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('unused search family entry is disposed and fetched again', () async {
    final searchService = _FakeSearchApiService();
    final analyticsService = _FakeAnalyticsApiService();
    final container = ProviderContainer(
      overrides: [
        searchApiServiceProvider.overrideWithValue(searchService),
        analyticsApiServiceProvider.overrideWithValue(analyticsService),
      ],
    );
    addTearDown(container.dispose);

    const filters = SearchFilters(query: 'buz pateni', citySlug: 'istanbul');
    final provider = searchResultsProvider(filters);
    final firstSubscription = container.listen(provider, (_, _) {});

    await container.read(provider.future);
    expect(searchService.queries, ['buz pateni']);

    firstSubscription.close();
    await container.pump();

    final secondSubscription = container.listen(provider, (_, _) {});
    addTearDown(secondSubscription.close);
    await container.read(provider.future);

    expect(searchService.queries, ['buz pateni', 'buz pateni']);
    expect(analyticsService.queries, ['buz pateni', 'buz pateni']);
  });

  test('completion of a disposed search does not publish analytics', () async {
    final searchService = _ControllableSearchApiService();
    final analyticsService = _FakeAnalyticsApiService();
    final container = ProviderContainer(
      overrides: [
        searchApiServiceProvider.overrideWithValue(searchService),
        analyticsApiServiceProvider.overrideWithValue(analyticsService),
      ],
    );
    addTearDown(container.dispose);

    const filters = SearchFilters(query: 'eski sorgu');
    final provider = searchResultsProvider(filters);
    final subscription = container.listen(provider, (_, _) {});
    final pendingResult = container.read(provider.future);

    subscription.close();
    await container.pump();
    searchService.complete('eski sorgu');
    await pendingResult;

    expect(analyticsService.queries, isEmpty);
  });
}

class _FakeSearchApiService extends SearchApiService {
  final List<String> queries = [];

  @override
  Future<ApiSearchResult> search({
    required String query,
    String? citySlug,
    int limit = 8,
  }) async {
    queries.add(query);
    return ApiSearchResult(
      query: query,
      taxonomy: const [],
      venues: const [],
      events: const [],
      total: 0,
    );
  }
}

class _FakeAnalyticsApiService extends AnalyticsApiService {
  final List<String> queries = [];

  @override
  void track({
    required String eventName,
    String? cityId,
    String? venueId,
    String? activityId,
    String? eventRefId,
    Map<String, dynamic> properties = const {},
  }) {
    final query = properties['query'];
    if (query is String) queries.add(query);
  }
}

class _ControllableSearchApiService extends SearchApiService {
  final _completer = Completer<ApiSearchResult>();

  @override
  Future<ApiSearchResult> search({
    required String query,
    String? citySlug,
    int limit = 8,
  }) => _completer.future;

  void complete(String query) {
    _completer.complete(
      ApiSearchResult(
        query: query,
        taxonomy: const [],
        venues: const [],
        events: const [],
        total: 0,
      ),
    );
  }
}

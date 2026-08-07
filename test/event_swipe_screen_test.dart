import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/features/events/presentation/screens/event_swipe_screen.dart';
import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'swipe provider receives a bounded local day and keeps client guard',
    (tester) async {
      final requests = <EventFilters>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedCityProvider.overrideWith(_NoCityNotifier.new),
            eventsListProvider.overrideWith((_, filters) async {
              requests.add(filters);
              final from = filters.dateFrom!;
              return [_eventAt(DateTime(from.year, from.month, from.day + 1))];
            }),
          ],
          child: const MaterialApp(home: EventSwipeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(requests, isNotEmpty);
      for (final filters in requests) {
        final from = filters.dateFrom;
        final to = filters.dateTo;
        expect(from, isNotNull);
        expect(to, isNotNull);
        expect(from!.hour, 0);
        expect(from.minute, 0);
        expect(from.second, 0);
        expect(from.millisecond, 0);
        expect(
          to!.add(const Duration(microseconds: 1)),
          DateTime(from.year, from.month, from.day + 1),
        );
      }

      // If the backend returns an out-of-range next-midnight event due to
      // timezone drift, the screen's local-day safety filter keeps it out.
      expect(find.byKey(const ValueKey('event-swipe-empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('event-swipe-content')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

class _NoCityNotifier extends SelectedCityNotifier {
  @override
  Future<ApiCity?> build() async => null;
}

ApiEvent _eventAt(DateTime startAt) => ApiEvent(
  id: 'next-midnight',
  title: 'Ertesi gün etkinliği',
  slug: 'ertesi-gun-etkinligi',
  startAt: startAt,
  timezone: 'Europe/Istanbul',
  status: 'published',
  priceType: 'free',
  currency: 'TRY',
  city: const ApiLocationSummary(id: '34', name: 'İstanbul', slug: 'istanbul'),
  activities: const [],
  isFavorite: false,
);

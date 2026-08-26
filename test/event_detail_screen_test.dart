import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/core/theme/theme.dart';
import 'package:bi_cikalim/features/events/presentation/screens/event_detail_screen.dart';
import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'event detail remains compact and overflow-free on a narrow large-text view',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [eventDetailProvider.overrideWith((_, _) async => _event)],
          child: MaterialApp(
            theme: BiCikalimTheme.lightTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 700),
                textScaler: TextScaler.linear(1.5),
              ),
              child: const EventDetailScreen(eventSlug: 'premium-event'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Premium Masaüstü Oyunları Gecesi'), findsOneWidget);
      expect(find.text('TARİH VE SAAT'), findsOneWidget);
      expect(find.text('Ücretsiz'), findsOneWidget);
      expect(find.text('MEKÂN'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text('Bilet detaylarını aç'),
        320,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Katılım durumun'), findsOneWidget);
      expect(find.text('Bilet detaylarını aç'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

final _event = ApiEvent(
  id: 'event-1',
  title: 'Premium Masaüstü Oyunları Gecesi',
  slug: 'premium-event',
  shortDescription: 'Kısa açıklama',
  description:
      'Arkadaşlarınla bir araya gel, yeni oyunlar keşfet ve keyifli bir akşam geçir. Tüm seviyelerden katılımcılar etkinliğe davetlidir.',
  startAt: DateTime.utc(2026, 8, 12, 17, 30),
  doorsOpenAt: DateTime.utc(2026, 8, 12, 17),
  timezone: 'Europe/Istanbul',
  status: 'published',
  priceType: 'free',
  currency: 'TRY',
  city: const ApiLocationSummary(
    id: '26',
    name: 'Eskişehir',
    slug: 'eskisehir',
  ),
  venue: const ApiEventVenueSummary(
    id: 'venue-1',
    name: 'BiÇıkalım Oyun ve Sosyal Yaşam Merkezi',
    slug: 'bicikalim-oyun-merkezi',
  ),
  coverUrl: '',
  activities: const [
    ApiEventActivitySummary(
      id: 'activity-1',
      name: 'Masaüstü Oyunları',
      slug: 'masaustu-oyunlari',
    ),
    ApiEventActivitySummary(
      id: 'activity-2',
      name: 'Strateji Turnuvası',
      slug: 'strateji-turnuvasi',
    ),
  ],
  isFavorite: false,
  ticketUrl: 'https://example.com/ticket',
  ageLimit: 18,
);

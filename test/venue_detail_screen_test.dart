import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/core/theme/theme.dart';
import 'package:bi_cikalim/features/venues/presentation/screens/venue_detail_screen.dart';
import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'venue profile sections stay complete on a narrow large-text view',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.reset);

      final venue = _venue();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            venueDetailProvider.overrideWith((_, _) async => venue),
            venueActivitiesProvider.overrideWith(
              (_, _) async => venue.activitySummary,
            ),
            eventsListProvider.overrideWith((_, _) async => [_event]),
            venueReviewsProvider.overrideWith((_, _) async => [_review]),
          ],
          child: MaterialApp(
            theme: BiCikalimTheme.lightTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 700),
                textScaler: TextScaler.linear(1.5),
              ),
              child: const VenueDetailScreen(venueId: 'premium-venue'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BiÇıkalım Premium Oyun Merkezi'), findsOneWidget);
      expect(find.text('Bilgileri doğrulandı'), findsOneWidget);
      expect(find.text('Yol Tarifi'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(NestedScrollView), const Offset(0, -1200));
      await tester.pumpAndSettle();

      expect(find.text('Aktivite Envanteri'), findsOneWidget);
      expect(find.text('Bilardo'), findsWidgets);
      final verticalLists = find.byWidgetPredicate(
        (widget) =>
            widget is ListView && widget.scrollDirection == Axis.vertical,
      );
      await tester.drag(verticalLists.last, const Offset(0, -260));
      await tester.pumpAndSettle();
      expect(find.text('240 TL / saat'), findsOneWidget);
      expect(find.textContaining('Son doğrulama:'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.drag(find.byType(TabBarView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Mekân hakkında'), findsOneWidget);
      expect(find.text('Çalışma Saatleri'), findsOneWidget);
      expect(find.text('Wi-Fi'), findsOneWidget);

      await tester.drag(find.byType(TabBarView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Yaklaşan Etkinlikler'), findsOneWidget);
      expect(find.text('Haftalık Bilardo Turnuvası'), findsOneWidget);

      await tester.drag(find.byType(TabBarView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('Kullanıcı Yorumları'), findsOneWidget);
      expect(
        find.text('Ekipmanlar temiz ve ortam çok keyifli.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}

ApiVenue _venue() {
  final today = DateTime.now().weekday;
  return ApiVenue(
    id: 'venue-1',
    name: 'BiÇıkalım Premium Oyun Merkezi',
    slug: 'premium-venue',
    shortDescription: 'Şehrin merkezinde oyun ve sosyalleşme alanı.',
    venueType: 'activity_center',
    city: const ApiLocationSummary(
      id: '26',
      name: 'Eskişehir',
      slug: 'eskisehir',
    ),
    district: const ApiLocationSummary(
      id: 'odunpazari',
      name: 'Odunpazarı',
      slug: 'odunpazari',
    ),
    coverUrl: '',
    isVerified: true,
    isFavorite: false,
    activitySummary: [
      ApiVenueActivitySummary(
        id: 'inventory-1',
        activityId: 'activity-1',
        activityName: 'Bilardo',
        activitySlug: 'bilardo',
        availability: 'available',
        isPaid: true,
        price: 240,
        priceUnit: 'hour',
        shortDescription: 'Profesyonel masalar ve ekipman desteği.',
        lastVerifiedAt: DateTime.utc(2026, 8, 1),
      ),
      const ApiVenueActivitySummary(
        id: 'inventory-2',
        activityId: 'activity-2',
        activityName: 'Masaüstü Oyunları',
        activitySlug: 'masaustu-oyunlari',
        availability: 'available',
        isPaid: false,
      ),
    ],
    description:
        'Arkadaş grupları için tasarlanmış, ferah ve modern bir sosyal yaşam alanı.',
    address: 'Hoşnudiye Mahallesi, İsmet İnönü Caddesi No: 24',
    googleMapsUrl: 'https://maps.google.com/example',
    phone: '+902220000000',
    websiteUrl: 'https://example.com',
    instagramUrl: 'https://instagram.com/example',
    openingHours: [
      ApiVenueOpeningHour(
        dayOfWeek: today,
        opensAt: '10:00',
        closesAt: '23:30',
        isClosed: false,
      ),
    ],
    tags: const [
      ApiTagSummary(id: 'wifi', name: 'Wi-Fi', slug: 'wifi'),
      ApiTagSummary(id: 'groups', name: 'Gruplara Uygun', slug: 'groups'),
    ],
    ratingAverage: 4.8,
    ratingCount: 126,
  );
}

final _event = ApiEvent(
  id: 'event-1',
  title: 'Haftalık Bilardo Turnuvası',
  slug: 'haftalik-bilardo-turnuvasi',
  startAt: DateTime.utc(2026, 8, 14, 18),
  timezone: 'Europe/Istanbul',
  status: 'published',
  priceType: 'free',
  currency: 'TRY',
  city: const ApiLocationSummary(
    id: '26',
    name: 'Eskişehir',
    slug: 'eskisehir',
  ),
  activities: const [],
  isFavorite: false,
);

final _review = ApiReview(
  id: 'review-1',
  venueId: 'venue-1',
  userId: 'user-1234',
  rating: 5,
  comment: 'Ekipmanlar temiz ve ortam çok keyifli.',
  status: 'published',
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

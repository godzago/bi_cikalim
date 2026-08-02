import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:bi_cikalim/shared/widgets/app_empty_state.dart';
import 'package:bi_cikalim/shared/widgets/app_error_state.dart';
import 'package:bi_cikalim/shared/widgets/app_refreshable_content.dart';
import 'package:bi_cikalim/shared/widgets/category_card.dart';
import 'package:bi_cikalim/shared/widgets/primary_button.dart';
import 'package:bi_cikalim/shared/widgets/venue_card.dart';
import 'package:bi_cikalim/core/errors/app_exception.dart';
import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/features/auth/presentation/screens/notification_permission_screen.dart';
import 'package:bi_cikalim/features/discover/presentation/screens/activity_list_tab.dart';
import 'package:bi_cikalim/features/events/presentation/widgets/activity_recommendation_card.dart';
import 'package:bi_cikalim/features/events/presentation/widgets/tonight_event_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void configureCompactView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
  }

  Widget testApp(Widget child) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(320, 568),
          textScaler: TextScaler.linear(1.35),
        ),
        child: Scaffold(body: child),
      ),
    );
  }

  testWidgets('kategori kartı dar alanda taşma üretmez', (tester) async {
    configureCompactView(tester);

    const category = ApiCategory(
      id: 'category',
      name: 'Masaüstü Oyunları ve Turnuvalar',
      slug: 'masaustu-oyunlari',
      iconName: 'casino',
      description: 'Arkadaşlarınla oynayabileceğin etkinlikler',
      isActive: true,
      sortOrder: 0,
    );

    await tester.pumpWidget(
      testApp(
        const Center(
          child: SizedBox(
            width: 142,
            height: 152,
            child: CategoryCard(category: category, onTap: _noop),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('uzun buton etiketi büyütülmüş yazıda taşmaz', (tester) async {
    configureCompactView(tester);

    await tester.pumpWidget(
      testApp(
        const Padding(
          padding: EdgeInsets.all(20),
          child: Align(
            alignment: Alignment.topCenter,
            child: PrimaryButton(
              label: 'Sıfırlama E-postası Gönder',
              onPressed: _noop,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('aktivite kartı dar ekranda taşma üretmez', (tester) async {
    configureCompactView(tester);

    const activity = ApiActivity(
      id: 'activity',
      categoryId: 'category',
      name: 'Çok Uzun İsimli Masa Oyunu Aktivitesi',
      slug: 'uzun-aktivite',
      kind: 'game',
      minPeople: null,
      maxPeople: null,
    );
    const category = ApiCategory(
      id: 'category',
      name: 'Masaüstü Oyunları ve Turnuvalar',
      slug: 'masaustu-oyunlari',
      isActive: true,
      sortOrder: 0,
    );

    await tester.pumpWidget(
      testApp(
        const Padding(
          padding: EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.topCenter,
            child: ActivityItemCard(
              activity: activity,
              category: category,
              onTap: _noop,
            ),
          ),
        ),
      ),
    );

    final layoutException = tester.takeException();
    expect(layoutException, isNull);
  });

  testWidgets('boş durum kısa ekranda kaydırılabilir', (tester) async {
    configureCompactView(tester);

    await tester.pumpWidget(
      testApp(
        const AppEmptyState(
          icon: Icons.cloud_off,
          message:
              'İçerik şu anda yüklenemedi. Bağlantını kontrol edip tekrar deneyebilirsin.',
          actionLabel: 'Tekrar Dene',
          onAction: _noop,
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scroll içermeyen durumda aşağı çekme yenilemeyi çalıştırır', (
    tester,
  ) async {
    configureCompactView(tester);
    var refreshed = false;

    await tester.pumpWidget(
      testApp(
        AppRefreshableContent(
          onRefresh: () async => refreshed = true,
          child: const AppEmptyState(icon: Icons.refresh, message: 'Yenile'),
        ),
      ),
    );

    await tester.drag(find.text('Yenile'), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(refreshed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bildirim izni ekranı küçük telefonda taşmaz', (tester) async {
    configureCompactView(tester);
    final router = GoRouter(
      initialLocation: '/permission',
      routes: [
        GoRoute(
          path: '/permission',
          builder: (_, _) =>
              const NotificationPermissionScreen(nextRoute: '/done'),
        ),
        GoRoute(
          path: '/done',
          builder: (_, _) => const Scaffold(body: Text('Tamamlandı')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    expect(find.text('Bildirimlere İzin Ver'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'hata durumu teknik exception metni göstermek yerine dost mesaj verir',
    (tester) async {
      configureCompactView(tester);

      await tester.pumpWidget(
        testApp(
          const AppErrorState(
            error: ServiceException(
              message: 'raw backend detail',
              statusCode: 429,
            ),
            title: 'İşlem yapılamadı',
          ),
        ),
      );

      expect(find.text('raw backend detail'), findsNothing);
      expect(find.textContaining('Çok sık işlem yaptın'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mekan kartı favori aksiyonu yoksa sahte favori butonu göstermez',
    (tester) async {
      configureCompactView(tester);

      await tester.pumpWidget(
        testApp(
          const Padding(
            padding: EdgeInsets.all(12),
            child: VenueCard(venue: _longVenue, onTap: _noop),
          ),
        ),
      );

      expect(find.byTooltip('Favoriye ekle'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('mekan kartı favori aksiyonu semantik ve tıklanabilir', (
    tester,
  ) async {
    configureCompactView(tester);
    var tapped = false;

    await tester.pumpWidget(
      testApp(
        Padding(
          padding: const EdgeInsets.all(12),
          child: VenueCard(
            venue: _longVenue,
            onTap: _noop,
            onFavoriteTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.byTooltip('Favoriye ekle'), findsOneWidget);
    await tester.tap(find.byTooltip('Favoriye ekle'));
    expect(tapped, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'aktivite ve etkinlik kartları farklı bilgi hiyerarşisi gösterir',
    (tester) async {
      configureCompactView(tester);
      final event = ApiEvent(
        id: 'event',
        title: 'Catan Turnuvası',
        slug: 'catan-turnuvasi',
        startAt: DateTime(2026, 8, 12, 20),
        timezone: 'Europe/Istanbul',
        status: 'published',
        priceType: 'free',
        currency: 'TRY',
        city: _eskisehir,
        venue: const ApiEventVenueSummary(
          id: 'venue',
          name: 'Blue Game House',
          slug: 'blue-game-house',
        ),
        activities: const [
          ApiEventActivitySummary(id: 'catan', name: 'Catan', slug: 'catan'),
        ],
        isFavorite: false,
      );

      await tester.pumpWidget(
        testApp(
          ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ActivityRecommendationCard(
                recommendation: _activityRecommendation,
                onTap: _noop,
              ),
              const SizedBox(height: 12),
              TonightEventCard(
                event: event,
                isFavorite: false,
                attendanceStatus: null,
                isBusy: false,
                onTap: _noop,
                onFavoriteTap: _noop,
                onAttendanceTap: (_) {},
              ),
            ],
          ),
        ),
      );

      expect(find.text('Mekânları Gör'), findsOneWidget);
      expect(find.text('Ne zaman ve nerede?'), findsOneWidget);
      expect(find.text('İlgileniyorum'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

void _noop() {}

const _eskisehir = ApiLocationSummary(
  id: 'city',
  name: 'Eskişehir',
  slug: 'eskisehir',
);

const _longVenue = ApiVenue(
  id: 'venue',
  name: 'Blue Game House Çok Uzun Mekan Adı',
  slug: 'blue-game-house',
  venueType: 'game',
  city: _eskisehir,
  district: ApiLocationSummary(
    id: 'district',
    name: 'Odunpazarı',
    slug: 'odunpazari',
  ),
  coverUrl: 'https://example.com/venue.jpg',
  isVerified: true,
  isFavorite: false,
  activitySummary: [],
  ratingAverage: 4.6,
  ratingCount: 12,
);

const _activityRecommendation = TonightActivityRecommendation(
  activity: ApiActivity(
    id: 'activity',
    categoryId: 'category',
    name: 'Bilardo',
    slug: 'bilardo',
    kind: 'game',
    minPeople: 2,
    maxPeople: 4,
  ),
  venues: ApiPaginatedResponse<ApiVenue>(
    items: [_longVenue],
    total: 1,
    page: 1,
    pageSize: 4,
    pages: 1,
  ),
);

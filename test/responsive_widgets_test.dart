import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:bi_cikalim/shared/widgets/app_empty_state.dart';
import 'package:bi_cikalim/shared/widgets/app_error_state.dart';
import 'package:bi_cikalim/shared/widgets/app_filter_controls.dart';
import 'package:bi_cikalim/shared/widgets/app_refreshable_content.dart';
import 'package:bi_cikalim/shared/widgets/category_card.dart';
import 'package:bi_cikalim/shared/widgets/event_list_card.dart';
import 'package:bi_cikalim/shared/widgets/primary_button.dart';
import 'package:bi_cikalim/shared/widgets/venue_card.dart';
import 'package:bi_cikalim/shared/widgets/app_filter_chip.dart';
import 'package:bi_cikalim/core/errors/app_exception.dart';
import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/core/theme/responsive.dart';
import 'package:bi_cikalim/features/auth/presentation/screens/notification_permission_screen.dart';
import 'package:bi_cikalim/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:bi_cikalim/features/discover/presentation/screens/activity_list_tab.dart';
import 'package:bi_cikalim/features/discover/presentation/screens/discover_screen.dart';
import 'package:bi_cikalim/features/events/presentation/widgets/activity_recommendation_card.dart';
import 'package:bi_cikalim/features/events/presentation/widgets/tonight_event_card.dart';
import 'package:bi_cikalim/features/map/presentation/screens/map_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  void configureCompactView(WidgetTester tester) {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    addTearDown(tester.view.reset);
  }

  Widget testApp(
    Widget child, {
    Size size = const Size(320, 568),
    double textScale = 1.35,
    EdgeInsets viewInsets = EdgeInsets.zero,
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: size,
          viewInsets: viewInsets,
          textScaler: TextScaler.linear(textScale),
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

  test('responsive tokenlar breakpoint ve carousel hedeflerini korur', () {
    const compact = AppLayout(320);
    const reference = AppLayout(390);
    const wide = AppLayout(480);

    expect(compact.windowClass, AppWindowClass.compact);
    expect(reference.windowClass, AppWindowClass.standard);
    expect(wide.windowClass, AppWindowClass.wide);
    expect(compact.screenPadding, 14);
    expect(reference.searchHeight, 43);
    expect(reference.venueHeroHeight, 144);
    expect(reference.collapsedMapSheetHeight, 136);

    final activityWidth = reference.carouselCardWidth(
      visibleItems: 2.9,
      min: 108,
      max: 150,
    );
    final activityVisible =
        (reference.width - (reference.screenPadding * 2) + reference.cardGap) /
        (activityWidth + reference.cardGap);
    expect(activityVisible, inInclusiveRange(2.8, 3.1));

    final venueWidth = reference.carouselCardWidth(
      visibleItems: 2.65,
      min: 116,
      max: 166,
    );
    final venueVisible =
        (reference.width - (reference.screenPadding * 2) + reference.cardGap) /
        (venueWidth + reference.cardGap);
    expect(venueVisible, inInclusiveRange(2.5, 2.8));
  });

  testWidgets('ortak kartlar tüm hedef genişlik ve yazı ölçeklerinde taşmaz', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    for (final width in [320.0, 360.0, 390.0, 430.0, 480.0]) {
      for (final scale in [1.0, 1.3, 1.5]) {
        final size = Size(width, 844);
        tester.view.physicalSize = size;
        await tester.pumpWidget(
          testApp(
            ListView(
              padding: const EdgeInsets.all(14),
              children: [
                const VenueCard(venue: _longVenue, dense: true, onTap: _noop),
                const ActivityItemCard(
                  activity: ApiActivity(
                    id: 'long-activity',
                    categoryId: 'category',
                    name:
                        'Arkadaşlarla Çok Uzun İsimli Masaüstü Strateji Oyunu',
                    slug: 'long-activity',
                    kind: 'game',
                    minPeople: 2,
                    maxPeople: 12,
                  ),
                  category: ApiCategory(
                    id: 'category',
                    name: 'Masaüstü Oyunları ve Turnuvalar',
                    slug: 'masaustu',
                    isActive: true,
                    sortOrder: 0,
                  ),
                  onTap: _noop,
                ),
                EventListCard(event: _longEvent(), onTap: _noop),
              ],
            ),
            size: size,
            textScale: scale,
          ),
        );
        await tester.pump();

        expect(
          tester.takeException(),
          isNull,
          reason: '$width px / text scale $scale',
        );
      }
    }
  });

  testWidgets(
    'keşfet sabit yükseklikli kartları 320 px ve 1.5 yazı ölçeğinde taşmaz',
    (tester) async {
      configureCompactView(tester);
      const venuePage = ApiPaginatedResponse<ApiVenue>(
        items: [_longVenue],
        total: 1,
        page: 1,
        pageSize: 16,
        pages: 1,
      );
      const activityPage = ApiPaginatedResponse<ApiActivity>(
        items: [_longActivity, _secondLongActivity],
        total: 2,
        page: 1,
        pageSize: 16,
        pages: 1,
      );
      final eventPage = ApiPaginatedResponse<ApiEvent>(
        items: [_longEvent()],
        total: 1,
        page: 1,
        pageSize: 8,
        pages: 1,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            selectedCityProvider.overrideWith(_NoCityNotifier.new),
            categoriesProvider.overrideWith((_) async => const [_longCategory]),
            activitiesPageProvider.overrideWith((_, _) async => activityPage),
            venuesPageProvider.overrideWith((_, _) async => venuePage),
            eventsPageProvider.overrideWith((_, _) async => eventPage),
          ],
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 568),
                textScaler: TextScaler.linear(1.5),
              ),
              child: const DiscoverScreen(),
            ),
          ),
        ),
      );
      // The production screen contains continuously animated loading/press
      // affordances, so a bounded pump is the deterministic way to let the
      // overridden async providers publish their data.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final scrollable = find.byType(CustomScrollView);
      for (var index = 0; index < 8; index++) {
        expect(
          tester.takeException(),
          isNull,
          reason: 'Keşfet akışında $index. viewport',
        );
        await tester.drag(scrollable, const Offset(0, -260));
        await tester.pump();
      }
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('kompakt kontroller en az 44 px dokunma alanı bırakır', (
    tester,
  ) async {
    configureCompactView(tester);
    final chipKey = GlobalKey();
    final buttonKey = GlobalKey();

    await tester.pumpWidget(
      testApp(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppFilterChip(
              key: chipKey,
              label: 'Bu Akşam',
              isSelected: true,
              onTap: _noop,
            ),
            PrimaryButton(key: buttonKey, label: 'Devam Et', onPressed: _noop),
          ],
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(chipKey)).height,
      greaterThanOrEqualTo(44),
    );
    expect(
      tester.getSize(find.byKey(buttonKey)).height,
      greaterThanOrEqualTo(44),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('filtre alt sayfası dar ekranda ve büyük yazıda taşma üretmez', (
    tester,
  ) async {
    configureCompactView(tester);

    await tester.pumpWidget(
      testApp(
        AppFilterSheet(
          onClear: _noop,
          onApply: _noop,
          child: Column(
            children: [
              const AppFilterGroup(
                title: 'Aktivite seçimi',
                subtitle: 'Kategori seçtikçe seçenekler yenilenir.',
                icon: Icons.local_activity_outlined,
                child: SizedBox(height: 240),
              ),
              const SizedBox(height: 12),
              AppFilterToggleTile(
                title: 'Doğrulanmış mekanlar',
                subtitle: 'Yalnızca bilgileri onaylanmış mekanları göster.',
                icon: Icons.verified_outlined,
                value: false,
                onChanged: _noopBool,
              ),
              const SizedBox(height: 10),
              AppFilterToggleTile(
                title: 'Konumu belli mekanlar',
                subtitle: 'Haritada görüntülenebilen mekanlarla sınırla.',
                icon: Icons.location_on_outlined,
                value: true,
                onChanged: _noopBool,
              ),
            ],
          ),
        ),
        textScale: 1.5,
      ),
    );
    await tester.pump();

    expect(find.text('Filtreler'), findsOneWidget);
    expect(find.text('Filtreleri Uygula'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('harita mekan alt kartı 320 px ve 1.5 yazı ölçeğinde taşmaz', (
    tester,
  ) async {
    configureCompactView(tester);
    const mapResult = MapVenueResult(
      venues: [_longMapVenue],
      total: 1,
      pages: 1,
      loadedCount: 1,
      invalidCoordinateCount: 0,
      detailFailureCount: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCityProvider.overrideWith(_NoCityNotifier.new),
          mapVenuesProvider.overrideWith((_, _) async => mapResult),
        ],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(1.5),
            ),
            child: const MapScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      tester.takeException(),
      isNull,
      reason: 'Harita ilk görünümü taşmamalı',
    );

    final marker = find.byKey(const ValueKey('map-marker-map-venue'));
    expect(marker, findsOneWidget);
    await tester.tap(marker);
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Yol Tarifi'), findsOneWidget);
  });

  testWidgets(
    'giriş formu klavye, çentik ve büyütülmüş yazıda erişilebilir kalır',
    (tester) async {
      configureCompactView(tester);
      const size = Size(320, 568);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: size,
              padding: EdgeInsets.only(top: 30, bottom: 24),
              viewPadding: EdgeInsets.only(top: 30, bottom: 24),
              viewInsets: EdgeInsets.only(bottom: 260),
              textScaler: TextScaler.linear(1.5),
            ),
            child: const ProviderScope(child: SignInScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -260),
      );
      await tester.pump();

      expect(find.text('Giriş Yap'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );
}

void _noop() {}

void _noopBool(bool _) {}

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

const _longMapVenue = ApiVenue(
  id: 'map-venue',
  name: 'Blue Game House Çok Uzun Mekan Adı ve Oyun Salonu',
  slug: 'blue-game-house-map',
  venueType: 'game',
  city: _eskisehir,
  district: ApiLocationSummary(
    id: 'district',
    name: 'Odunpazarı Çok Uzun İlçe Merkezi',
    slug: 'odunpazari',
  ),
  latitude: 39.7767,
  longitude: 30.5206,
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

class _NoCityNotifier extends SelectedCityNotifier {
  @override
  Future<ApiCity?> build() async => null;
}

const _longCategory = ApiCategory(
  id: 'category',
  name: 'Masaüstü Oyunları ve Kalabalık Arkadaş Turnuvaları',
  slug: 'masaustu-oyunlari',
  iconName: 'casino',
  description: 'Uzun kategori açıklaması',
  isActive: true,
  sortOrder: 0,
);

const _longActivity = ApiActivity(
  id: 'long-activity',
  categoryId: 'category',
  name: 'Arkadaşlarla Çok Uzun İsimli Masaüstü Strateji Oyunu',
  slug: 'long-activity',
  kind: 'game',
  minPeople: 2,
  maxPeople: 12,
);

const _secondLongActivity = ApiActivity(
  id: 'second-long-activity',
  categoryId: 'category',
  name: 'Çok Kalabalık Gruplar İçin Uzun Turnuva Aktivitesi',
  slug: 'second-long-activity',
  kind: 'game',
  minPeople: 4,
  maxPeople: 16,
);

ApiEvent _longEvent() => ApiEvent(
  id: 'long-event',
  title: 'Eskişehir Arkadaşlık ve Masa Oyunları Büyük Yaz Turnuvası',
  slug: 'long-event',
  description:
      'Uzun açıklamalı, tarih ve fiyat bilgisini koruyan örnek etkinlik.',
  startAt: DateTime(2026, 8, 12, 20),
  timezone: 'Europe/Istanbul',
  status: 'published',
  priceType: 'free',
  currency: 'TRY',
  city: _eskisehir,
  venue: const ApiEventVenueSummary(
    id: 'venue',
    name: 'Blue Game House Çok Uzun Mekan Adı',
    slug: 'blue-game-house',
  ),
  activities: const [],
  isFavorite: false,
);

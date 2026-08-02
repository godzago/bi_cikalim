import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_pressable_scale.dart';
import '../../../events/presentation/widgets/activity_recommendation_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  static const _filters = [
    'Sana Özel',
    'Trend',
    'Yakınında',
    'Bu Akşam',
    'Spor',
    'Oyun',
    'Eğlence',
    'Yeni',
    'Ücretsiz',
    'Grupça',
  ];

  String _selectedFilter = _filters.first;
  int _sliderIndex = 0;

  Future<void> _refreshDiscover() async {
    ref.invalidate(selectedCityProvider);
    final selectedCity = await ref.read(selectedCityProvider.future);
    final citySlug = selectedCity?.slug;
    final activitiesProvider = activitiesPageProvider(
      const ActivityPageFilters(pageSize: 16),
    );
    final venuesProvider = venuesPageProvider(
      VenuePageFilters(citySlug: citySlug, pageSize: 16),
    );
    final eventsProvider = eventsPageProvider(
      EventPageFilters(citySlug: citySlug, pageSize: 8),
    );
    final tonightProvider = citySlug == null
        ? null
        : tonightActivityRecommendationsProvider(
            TonightRecommendationFilters(citySlug: citySlug, limit: 6),
          );

    ref
      ..invalidate(categoriesProvider)
      ..invalidate(activitiesProvider)
      ..invalidate(venuesProvider)
      ..invalidate(eventsProvider);
    if (tonightProvider != null) ref.invalidate(tonightProvider);

    await Future.wait([
      ref.read(categoriesProvider.future),
      ref.read(activitiesProvider.future),
      ref.read(venuesProvider.future),
      ref.read(eventsProvider.future),
      if (tonightProvider != null) ref.read(tonightProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCityAsync = ref.watch(selectedCityProvider);
    final selectedCity = selectedCityAsync.value;
    final citySlug = selectedCity?.slug;
    final venuesProvider = venuesPageProvider(
      VenuePageFilters(citySlug: citySlug, pageSize: 16),
    );
    final eventsProvider = eventsPageProvider(
      EventPageFilters(citySlug: citySlug, pageSize: 8),
    );
    final activitiesProvider = activitiesPageProvider(
      const ActivityPageFilters(pageSize: 16),
    );
    final tonightRecommendationsAsync = citySlug == null
        ? null
        : ref.watch(
            tonightActivityRecommendationsProvider(
              TonightRecommendationFilters(citySlug: citySlug, limit: 6),
            ),
          );
    final categoriesAsync = ref.watch(categoriesProvider);
    final activitiesAsync = ref.watch(activitiesProvider);
    final venuesAsync = ref.watch(venuesProvider);
    final eventsAsync = ref.watch(eventsProvider);

    final categories = categoriesAsync.value ?? const <ApiCategory>[];
    final activities = activitiesAsync.value?.items ?? const <ApiActivity>[];
    final venues = venuesAsync.value?.items ?? const <ApiVenue>[];
    final events = eventsAsync.value?.items ?? const <ApiEvent>[];

    final hasAnyContent =
        categories.isNotEmpty ||
        activities.isNotEmpty ||
        venues.isNotEmpty ||
        events.isNotEmpty;
    final isFirstLoad =
        !hasAnyContent &&
        (categoriesAsync.isLoading ||
            activitiesAsync.isLoading ||
            venuesAsync.isLoading ||
            eventsAsync.isLoading);
    final hasBlockingError =
        !hasAnyContent &&
        (categoriesAsync.hasError ||
            activitiesAsync.hasError ||
            venuesAsync.hasError ||
            eventsAsync.hasError);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF8),
      body: SafeArea(
        child: RefreshIndicator(
          color: BiCikalimTheme.primary,
          onRefresh: _refreshDiscover,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildFilterBar()),
              if (isFirstLoad)
                SliverToBoxAdapter(child: _buildSkeletonFeed())
              else if (hasBlockingError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                )
              else ...[
                SliverToBoxAdapter(
                  child: _buildHomeImageSlider(events: events, venues: venues),
                ),
                SliverToBoxAdapter(
                  child: _buildTonightHomeSection(
                    selectedCity: selectedCity,
                    recommendationsAsync: tonightRecommendationsAsync,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildFeedTitle(
                    activities: activities,
                    venues: venues,
                    events: events,
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildExploreGrid(
                    activities: activities,
                    categories: categories,
                    venues: venues,
                    events: events,
                  ),
                ),
                SliverToBoxAdapter(child: _buildSkeletonTail()),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ignore: unused_element
  Widget _buildHeader(ApiCity? selectedCity) {
    final cityLabel = selectedCity?.name ?? 'Şehir seç';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Keşfet',
                  style: TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: 30,
                    height: 1.05,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => context.go('/city-select'),
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: BiCikalimTheme.primary,
                          size: 17,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            cityLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: BiCikalimTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: BiCikalimTheme.textLight,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _HeaderIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'Bildirimler',
            onTap: () {},
          ),
          const SizedBox(width: 10),
          _HeaderIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: 'Profil',
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
      child: AppPressableScale(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/discover/search'),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF0EDE9)),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: BiCikalimTheme.primary,
                    size: 23,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Aktivite, mekan veya etkinlik ara',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: BiCikalimTheme.textLight,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 62,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _selectedFilter == filter;
          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => setState(() => _selectedFilter = filter),
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(
              color: selected
                  ? BiCikalimTheme.primary
                  : const Color(0xFFEDE8E3),
            ),
            selectedColor: BiCikalimTheme.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected ? Colors.white : BiCikalimTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          );
        },
      ),
    );
  }

  Widget _buildTonightHomeSection({
    required ApiCity? selectedCity,
    required AsyncValue<List<TonightActivityRecommendation>>?
    recommendationsAsync,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bu Akşam Ne Yapsak?',
                      style: TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: 20,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Şehirde şu anda yapabileceğin aktiviteleri keşfet.',
                      style: TextStyle(
                        color: BiCikalimTheme.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => context.push('/events/tonight'),
                child: const Text('Tüm Öneriler'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (selectedCity == null)
            _WarmStateCard(
              icon: Icons.location_city_outlined,
              title: 'Öneriler için şehir seç',
              message:
                  'Aktivite önerilerini şehirdeki gerçek mekanlara göre hazırlıyoruz.',
              actionLabel: 'Şehir Seç',
              onAction: () => context.push('/city-select'),
            )
          else
            recommendationsAsync!.when(
              loading: () => const _HorizontalActivitySkeleton(),
              error: (error, _) => _WarmStateCard(
                icon: Icons.info_outline,
                title: 'Öneriler yüklenemedi',
                message:
                    'Ana akışı kullanmaya devam edebilirsin. İstersen tekrar deneyebilirsin.',
                actionLabel: 'Tekrar Dene',
                onAction: _refreshDiscover,
              ),
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return _WarmStateCard(
                    icon: Icons.sports_esports_outlined,
                    title: 'Bu akşam için henüz aktivite önerisi bulamadık',
                    message:
                        'Şehirdeki tüm aktiviteleri inceleyebilir veya farklı bir kategori seçebilirsin.',
                    actionLabel: 'Tüm Aktiviteleri Gör',
                    onAction: () => context.push('/discover/catalog'),
                  );
                }

                final cardHeight = MediaQuery.textScalerOf(
                  context,
                ).scale(236).clamp(236.0, 330.0).toDouble();
                return SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: recommendations.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final recommendation = recommendations[index];
                      return SizedBox(
                        width: 248,
                        child: ActivityRecommendationCard(
                          recommendation: recommendation,
                          compact: true,
                          onTap: () => _openTonightActivityVenues(
                            recommendation,
                            selectedCity.slug,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  void _openTonightActivityVenues(
    TonightActivityRecommendation recommendation,
    String citySlug,
  ) {
    final activity = recommendation.activity;
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {
          'scope': 'activity',
          'activitySlug': activity.slug,
          'citySlug': citySlug,
          'title': '${activity.name} Yapabileceğin Mekânlar',
        },
      ).toString(),
    );
  }

  Widget _buildHomeImageSlider({
    required List<ApiEvent> events,
    required List<ApiVenue> venues,
  }) {
    final items = _homeSliderItems(events: events, venues: venues);

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: AspectRatio(
          aspectRatio: 2.35,
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF0EDE9)),
            ),
            child: const Row(
              children: [
                Icon(Icons.image_outlined, color: BiCikalimTheme.textSecondary),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Slider görselleri API’den gelince burada gösterilecek.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentIndex = _sliderIndex.clamp(0, items.length - 1).toInt();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2.35,
            child: PageView.builder(
              itemCount: items.length,
              onPageChanged: (index) => setState(() => _sliderIndex = index),
              itemBuilder: (context, index) {
                final item = items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: AppPressableScale(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.push(item.route),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            AppNetworkImage(
                              imageUrl: item.imageUrl,
                              fit: BoxFit.cover,
                              semanticLabel: '${item.title} görseli',
                            ),
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: .62),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              left: 14,
                              right: 14,
                              bottom: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: .18,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: .2,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      item.badge,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      height: 1.1,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  if (item.subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 3),
                                    Text(
                                      item.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: .82,
                                        ),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (items.length > 1) ...[
            const SizedBox(height: 9),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(items.length, (index) {
                final selected = index == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: selected ? 18 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: selected
                        ? BiCikalimTheme.primary
                        : BiCikalimTheme.primary.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }

  List<_HomeSliderItem> _homeSliderItems({
    required List<ApiEvent> events,
    required List<ApiVenue> venues,
  }) {
    final items = <_HomeSliderItem>[];
    final seenImages = <String>{};

    void addItem(_HomeSliderItem item) {
      if (item.imageUrl.trim().isEmpty) return;
      if (!seenImages.add(item.imageUrl)) return;
      items.add(item);
    }

    for (final event in events) {
      addItem(
        _HomeSliderItem(
          title: event.title,
          subtitle: [
            _formatEventDate(event.startDate),
            event.venue?.name ?? event.city.name,
          ].where((part) => part.isNotEmpty).join(' • '),
          imageUrl: event.imageUrl,
          badge: 'Etkinlik',
          route: '/events/${event.slug}',
        ),
      );
      if (items.length >= 6) return items;
    }

    for (final venue in venues) {
      addItem(
        _HomeSliderItem(
          title: venue.name,
          subtitle: [
            venue.districtName,
            venue.cityName,
          ].where((part) => part.isNotEmpty).join(' • '),
          imageUrl: venue.coverImageUrl,
          badge: 'Mekan',
          route: '/venues/${venue.slug}',
        ),
      );
      if (items.length >= 6) return items;
    }

    return items;
  }

  // ignore: unused_element
  Widget _buildTonightCard(
    List<ApiActivity> activities,
    List<ApiVenue> venues,
    List<ApiCategory> categories,
  ) {
    final suggestions = activities.isNotEmpty
        ? activities.take(5).map((activity) => activity.name).toList()
        : categories.take(5).map((category) => category.name).toList();
    final venueNames = venues.take(2).map((venue) => venue.name).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: AppPressableScale(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/events/tonight'),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF191716),
                    Color(0xFF3D251D),
                    BiCikalimTheme.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.2),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -18,
                    bottom: -22,
                    child: Icon(
                      Icons.explore_rounded,
                      color: Colors.white.withValues(alpha: 0.08),
                      size: 150,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.14),
                                ),
                              ),
                              child: const Text(
                                'Bu Akşam',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                color: BiCikalimTheme.primary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Bu Akşam Ne Yapsak?',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          venueNames.isEmpty
                              ? 'Aktivite seç, yakınındaki uygun mekanları keşfet.'
                              : '${venueNames.join(' ve ')} gibi mekanlarda plan yap.',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 12,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: suggestions
                                .map(
                                  (label) => _LightPill(
                                    label: label,
                                    icon: Icons.local_activity_outlined,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedTitle({
    required List<ApiActivity> activities,
    required List<ApiVenue> venues,
    required List<ApiEvent> events,
  }) {
    final total =
        _visibleActivities(activities).length +
        _visibleVenues(venues).length +
        _visibleEvents(events).length;
    final title = switch (_selectedFilter) {
      'Trend' => 'Trend keşifler',
      'Yakınında' => 'Yakınındaki fikirler',
      'Bu Akşam' => 'Bu akşam için',
      'Spor' => 'Spor aktiviteleri',
      'Oyun' => 'Oyun odaklı keşif',
      'Eğlence' => 'Eğlence akışı',
      'Yeni' => 'Yeni eklenenler',
      'Ücretsiz' => 'Ücretsiz seçenekler',
      'Grupça' => 'Grupça yapılacaklar',
      _ => 'Sana özel akış',
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  total == 0
                      ? 'Filtreye uygun öneri bekleniyor.'
                      : '$total öneri ve keşif sinyali',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.push('/discover/catalog'),
            child: const Text('Tümü'),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreGrid({
    required List<ApiActivity> activities,
    required List<ApiCategory> categories,
    required List<ApiVenue> venues,
    required List<ApiEvent> events,
  }) {
    final visibleActivities = _visibleActivities(activities);
    final visibleVenues = _visibleVenues(venues);
    final visibleEvents = _visibleEvents(events);
    final categoryById = {
      for (final category in categories) category.id: category,
    };

    if (visibleActivities.isEmpty &&
        visibleVenues.isEmpty &&
        visibleEvents.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = 12.0;
          final fullWidth = constraints.maxWidth;
          final halfWidth = (constraints.maxWidth - gap) / 2;
          final cards = <Widget>[];

          void addCard(Widget child, {required bool large, double? height}) {
            cards.add(
              SizedBox(
                width: large ? fullWidth : halfWidth,
                height: height ?? (large ? 220 : 188),
                child: child,
              ),
            );
          }

          if (visibleActivities.isNotEmpty) {
            final activity = visibleActivities.first;
            addCard(
              _ActivityExploreCard(
                activity: activity,
                category: categoryById[activity.categoryId],
                venueSignal: _activityVenueSignal(activity, venues),
                proof: _activityProof(activity),
                accent: _accentFor(activity.slug),
                large: true,
                onTap: () => _openActivity(activity),
              ),
              large: true,
              height: 224,
            );
          }

          if (visibleActivities.length > 1 || visibleVenues.isNotEmpty) {
            addCard(
              _PersonalRecommendationCard(
                activity: visibleActivities.length > 1
                    ? visibleActivities[1]
                    : visibleActivities.firstOrNull,
                venue: visibleVenues.firstOrNull,
                onTap: () {
                  final activity = visibleActivities.length > 1
                      ? visibleActivities[1]
                      : visibleActivities.firstOrNull;
                  if (activity != null) {
                    _openActivity(activity);
                    return;
                  }
                  final venue = visibleVenues.firstOrNull;
                  if (venue != null) context.push('/venues/${venue.slug}');
                },
              ),
              large: true,
              height: 152,
            );
          }

          for (var i = 1; i < visibleActivities.length && i < 7; i++) {
            final activity = visibleActivities[i];
            addCard(
              _ActivityExploreCard(
                activity: activity,
                category: categoryById[activity.categoryId],
                venueSignal: _activityVenueSignal(activity, venues),
                proof: _activityProof(activity),
                accent: _accentFor(activity.slug),
                large: false,
                onTap: () => _openActivity(activity),
              ),
              large: false,
              height: i.isEven ? 206 : 188,
            );
          }

          for (var i = 0; i < visibleVenues.length && i < 5; i++) {
            final venue = visibleVenues[i];
            addCard(
              _VenueExploreCard(
                venue: venue,
                large: i == 0,
                accent: _accentFor(venue.slug),
                onTap: () => context.push('/venues/${venue.slug}'),
              ),
              large: i == 0,
              height: i == 0 ? 226 : 196,
            );
          }

          for (var i = 0; i < visibleEvents.length && i < 5; i++) {
            final event = visibleEvents[i];
            addCard(
              _EventExploreCard(
                event: event,
                large: i == 0 && visibleActivities.length < 3,
                accent: _accentFor(event.slug),
                onTap: () => context.push('/events/${event.slug}'),
              ),
              large: i == 0 && visibleActivities.length < 3,
              height: i == 0 && visibleActivities.length < 3 ? 218 : 192,
            );
          }

          if (cards.length < 4) {
            for (final category in categories.take(4 - cards.length)) {
              addCard(
                _CategoryExploreCard(
                  category: category,
                  accent: _accentFor(category.slug),
                  onTap: () => context.push(
                    Uri(
                      path: '/discover/results',
                      queryParameters: {
                        'categorySlug': category.slug,
                        'title': category.name,
                      },
                    ).toString(),
                  ),
                ),
                large: false,
                height: 184,
              );
            }
          }

          return Wrap(spacing: gap, runSpacing: gap, children: cards);
        },
      ),
    );
  }

  Widget _buildSkeletonFeed() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SkeletonBox(height: 174, radius: 24),
          const SizedBox(height: 18),
          Row(
            children: const [
              Expanded(child: _SkeletonBox(height: 182, radius: 22)),
              SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 206, radius: 22)),
            ],
          ),
          const SizedBox(height: 12),
          const _SkeletonBox(height: 218, radius: 22),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _SkeletonBox(height: 178, radius: 22)),
              SizedBox(width: 12),
              Expanded(child: _SkeletonBox(height: 188, radius: 22)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonTail() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Row(
        children: const [
          Expanded(child: _SkeletonBox(height: 78, radius: 18)),
          SizedBox(width: 12),
          Expanded(child: _SkeletonBox(height: 78, radius: 18)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: _WarmStateCard(
        icon: Icons.cloud_off_outlined,
        title: 'Keşif akışı yüklenemedi',
        message: 'Bağlantıyı kontrol edip tekrar deneyebilirsin.',
        actionLabel: 'Tekrar Dene',
        onAction: _refreshDiscover,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      child: _WarmStateCard(
        icon: Icons.explore_off_outlined,
        title: 'Yakınında henüz sonuç bulamadık',
        message:
            'Şehir genelindeki popüler aktiviteleri keşfet veya farklı filtreler dene.',
        actionLabel: 'Popülerleri Gör',
        onAction: () => setState(() => _selectedFilter = 'Trend'),
      ),
    );
  }

  List<ApiActivity> _visibleActivities(List<ApiActivity> activities) {
    final filtered = switch (_selectedFilter) {
      'Spor' => activities.where(_isSportActivity).toList(),
      'Oyun' => activities.where(_isGameActivity).toList(),
      'Eğlence' => activities.where(_isEntertainmentActivity).toList(),
      'Grupça' => activities.where(_isGroupActivity).toList(),
      _ => List<ApiActivity>.from(activities),
    };
    return filtered.take(12).toList();
  }

  List<ApiVenue> _visibleVenues(List<ApiVenue> venues) {
    final filtered = switch (_selectedFilter) {
      'Spor' =>
        venues.where((venue) => _venueContains(venue, _sportTerms)).toList(),
      'Oyun' =>
        venues.where((venue) => _venueContains(venue, _gameTerms)).toList(),
      'Eğlence' =>
        venues
            .where((venue) => _venueContains(venue, _entertainmentTerms))
            .toList(),
      'Yeni' => List<ApiVenue>.from(venues.reversed),
      _ => List<ApiVenue>.from(venues),
    };
    return filtered.take(8).toList();
  }

  List<ApiEvent> _visibleEvents(List<ApiEvent> events) {
    final now = DateTime.now();
    final filtered = switch (_selectedFilter) {
      'Bu Akşam' => events.where((event) {
        final start = event.startAt.toLocal();
        return start.year == now.year &&
            start.month == now.month &&
            start.day == now.day;
      }).toList(),
      'Ücretsiz' =>
        events
            .where((event) => event.priceType.toLowerCase() == 'free')
            .toList(),
      'Yeni' => List<ApiEvent>.from(events.reversed),
      _ => List<ApiEvent>.from(events),
    };
    filtered.sort((left, right) => left.startAt.compareTo(right.startAt));
    return filtered.take(8).toList();
  }

  bool _isSportActivity(ApiActivity activity) {
    return activity.kind.toLowerCase() == 'sport' ||
        _containsAny(activity.name, _sportTerms);
  }

  bool _isGameActivity(ApiActivity activity) {
    return activity.kind.toLowerCase() == 'game' ||
        _containsAny(activity.name, _gameTerms);
  }

  bool _isEntertainmentActivity(ApiActivity activity) {
    return activity.kind.toLowerCase() == 'entertainment' ||
        _containsAny(activity.name, _entertainmentTerms);
  }

  bool _isGroupActivity(ApiActivity activity) {
    return (activity.maxPeople ?? 0) >= 3 ||
        (activity.minPeople ?? 0) >= 2 ||
        _containsAny(activity.name, _groupTerms);
  }

  bool _venueContains(ApiVenue venue, List<String> terms) {
    final source = [
      venue.name,
      venue.shortDescription ?? '',
      ...venue.activitySummary.map((item) => item.activityName),
      ...venue.tags.map((tag) => tag.name),
    ].join(' ');
    return _containsAny(source, terms);
  }

  bool _containsAny(String source, List<String> terms) {
    final normalized = source.toLowerCase();
    return terms.any((term) => normalized.contains(term));
  }

  String _activityVenueSignal(ApiActivity activity, List<ApiVenue> venues) {
    final count = venues.where((venue) {
      return venue.activitySummary.any((item) {
        return item.activityId == activity.id ||
            item.activitySlug == activity.slug ||
            item.activityName.toLowerCase() == activity.name.toLowerCase();
      });
    }).length;
    if (count > 0) return '$count mekanda var';
    return 'Mekanlarda ara';
  }

  String _activityProof(ApiActivity activity) {
    if (_isGroupActivity(activity)) return 'Grupça uygun';
    if (_isSportActivity(activity)) return 'Bugün hareketli';
    if (_isGameActivity(activity)) return 'Trend aktivite';
    return 'İlgini çekebilir';
  }

  void _openActivity(ApiActivity activity) {
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {
          'activitySlug': activity.slug,
          'title': activity.name,
        },
      ).toString(),
    );
  }
}

const _sportTerms = [
  'spor',
  'futbol',
  'basket',
  'tenis',
  'fitness',
  'yoga',
  'saha',
];
const _gameTerms = [
  'oyun',
  'bowling',
  'bilardo',
  'dart',
  'masa',
  'vr',
  'playstation',
];
const _entertainmentTerms = [
  'eğlence',
  'eglence',
  'karaoke',
  'müzik',
  'muzik',
  'parti',
  'sinema',
];
const _groupTerms = ['grup', 'takım', 'takim', 'arkadaş', 'arkadas', 'masa'];

const _accentPalette = [
  BiCikalimTheme.primary,
  Color(0xFF2E7D6F),
  Color(0xFF3D6FB6),
  Color(0xFF8A5A1F),
  Color(0xFF7B4BA0),
  Color(0xFF455A64),
];

Color _accentFor(String seed) {
  if (seed.isEmpty) return BiCikalimTheme.primary;
  final index = seed.codeUnits.fold<int>(
    0,
    (value, unit) => (value + unit) % _accentPalette.length,
  );
  return _accentPalette[index];
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF0EDE9)),
            ),
            child: Icon(icon, size: 21, color: BiCikalimTheme.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _LightPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _LightPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 160),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityExploreCard extends StatelessWidget {
  final ApiActivity activity;
  final ApiCategory? category;
  final String venueSignal;
  final String proof;
  final Color accent;
  final bool large;
  final VoidCallback onTap;

  const _ActivityExploreCard({
    required this.activity,
    required this.category,
    required this.venueSignal,
    required this.proof,
    required this.accent,
    required this.large,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ExploreCardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: large ? 126 : 92,
            child: _GradientCover(
              accent: accent,
              icon: activity.iconData,
              badge: large ? 'Aktivite' : proof,
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(large ? 16 : 12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.name,
                    maxLines: large ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BiCikalimTheme.textPrimary,
                      fontSize: large ? 20 : 15,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category?.name ?? _participantLabel(activity),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _SignalRow(
                    icon: Icons.storefront_outlined,
                    label: venueSignal,
                    secondary: proof,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueExploreCard extends StatelessWidget {
  final ApiVenue venue;
  final bool large;
  final Color accent;
  final VoidCallback onTap;

  const _VenueExploreCard({
    required this.venue,
    required this.large,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activityText = venue.activitySummary.isEmpty
        ? venue.shortDescription ?? venue.districtName
        : venue.activitySummary
              .take(3)
              .map((activity) => activity.activityName)
              .join(' • ');
    final proof = venue.reviewCount > 0
        ? '${venue.reviewCount} yorum'
        : venue.isVerified
        ? 'Doğrulanmış mekan'
        : 'Yeni keşif';

    return _ExploreCardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: large ? 126 : 92,
            child: _ImageOrGradientCover(
              imageUrl: venue.coverImageUrl,
              accent: accent,
              icon: Icons.storefront_rounded,
              badge: 'Mekan',
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(large ? 16 : 12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue.name,
                    maxLines: large ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BiCikalimTheme.textPrimary,
                      fontSize: large ? 18 : 14,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activityText.isEmpty ? venue.cityName : activityText,
                    maxLines: large ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 11,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _SignalRow(
                    icon: Icons.near_me_outlined,
                    label: venue.districtName.isEmpty
                        ? venue.cityName
                        : venue.districtName,
                    secondary: proof,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EventExploreCard extends StatelessWidget {
  final ApiEvent event;
  final bool large;
  final Color accent;
  final VoidCallback onTap;

  const _EventExploreCard({
    required this.event,
    required this.large,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ExploreCardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: large ? 120 : 88,
            child: _ImageOrGradientCover(
              imageUrl: event.imageUrl,
              accent: accent,
              icon: Icons.event_rounded,
              badge: _eventBadge(event),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(large ? 16 : 12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: large ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BiCikalimTheme.textPrimary,
                      fontSize: large ? 17 : 14,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.venue?.name ?? event.city.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  _SignalRow(
                    icon: Icons.schedule_outlined,
                    label: _formatEventDate(event.startAt),
                    secondary: event.priceInfo,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalRecommendationCard extends StatelessWidget {
  final ApiActivity? activity;
  final ApiVenue? venue;
  final VoidCallback onTap;

  const _PersonalRecommendationCard({
    required this.activity,
    required this.venue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = activity?.name ?? venue?.name ?? 'Yeni bir plan keşfet';
    final subtitle = venue == null
        ? 'İlgini çekebilecek aktiviteleri şehirde ara.'
        : '${venue!.name} ve benzeri mekanlarda dene.';

    return _ExploreCardShell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFFF3ED),
              Colors.white,
              const Color(0xFFF3F8F6),
            ],
            stops: const [0, 0.62, 1],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SolidPill(label: 'Sana Özel'),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BiCikalimTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 62,
              height: 96,
              decoration: BoxDecoration(
                color: BiCikalimTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                activity?.iconData ?? Icons.auto_awesome_rounded,
                color: BiCikalimTheme.primary,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryExploreCard extends StatelessWidget {
  final ApiCategory category;
  final Color accent;
  final VoidCallback onTap;

  const _CategoryExploreCard({
    required this.category,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _ExploreCardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 92,
            child: _GradientCover(
              accent: accent,
              icon: category.iconData,
              badge: 'Kategori',
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: BiCikalimTheme.textPrimary,
                      fontSize: 15,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  const _SignalRow(
                    icon: Icons.explore_outlined,
                    label: 'Popülerleri gör',
                    secondary: 'Keşfet',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExploreCardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ExploreCardShell({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppPressableScale(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: InkWell(onTap: onTap, child: child),
        ),
      ),
    );
  }
}

class _ImageOrGradientCover extends StatelessWidget {
  final String imageUrl;
  final Color accent;
  final IconData icon;
  final String badge;

  const _ImageOrGradientCover({
    required this.imageUrl,
    required this.accent,
    required this.icon,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _GradientCover(accent: accent, icon: icon, badge: badge);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        AppNetworkImage(imageUrl: imageUrl),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withValues(alpha: 0.45),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(top: 10, left: 10, child: _CoverBadge(label: badge)),
      ],
    );
  }
}

class _GradientCover extends StatelessWidget {
  final Color accent;
  final IconData icon;
  final String badge;

  const _GradientCover({
    required this.accent,
    required this.icon,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.92),
            Color.lerp(accent, Colors.black, 0.28)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -22,
            child: Icon(
              icon,
              size: 108,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
          Positioned(top: 10, left: 10, child: _CoverBadge(label: badge)),
          Center(child: Icon(icon, color: Colors.white, size: 34)),
        ],
      ),
    );
  }
}

class _CoverBadge extends StatelessWidget {
  final String label;

  const _CoverBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 126),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: BiCikalimTheme.textPrimary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SolidPill extends StatelessWidget {
  final String label;

  const _SolidPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: BiCikalimTheme.primary,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SignalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String secondary;

  const _SignalRow({
    required this.icon,
    required this.label,
    required this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: BiCikalimTheme.primary, size: 14),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BiCikalimTheme.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            secondary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: BiCikalimTheme.textLight,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WarmStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _WarmStateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF0EDE9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.045),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: BiCikalimTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: BiCikalimTheme.primary, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BiCikalimTheme.textPrimary,
              fontSize: 18,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BiCikalimTheme.textSecondary,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _HomeSliderItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String badge;
  final String route;

  const _HomeSliderItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.badge,
    required this.route,
  });
}

class _HorizontalActivitySkeleton extends StatelessWidget {
  const _HorizontalActivitySkeleton();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.textScalerOf(
      context,
    ).scale(236).clamp(236.0, 330.0).toDouble();
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => SizedBox(
          width: 248,
          child: _SkeletonBox(height: height, radius: 20),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double radius;

  const _SkeletonBox({required this.height, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF1EFEC), Color(0xFFE7E3DF), Color(0xFFF7F5F3)],
        ),
      ),
    );
  }
}

String _participantLabel(ApiActivity activity) {
  if (activity.minPeople != null && activity.maxPeople != null) {
    return '${activity.minPeople}-${activity.maxPeople} kişi';
  }
  if (activity.minPeople != null) return '${activity.minPeople}+ kişi';
  return 'Aktivite';
}

String _eventBadge(ApiEvent event) {
  final start = event.startAt.toLocal();
  final now = DateTime.now();
  if (start.year == now.year &&
      start.month == now.month &&
      start.day == now.day) {
    return 'Bu akşam';
  }
  if (event.priceType.toLowerCase() == 'free') return 'Ücretsiz';
  return 'Etkinlik';
}

String _formatEventDate(DateTime value) {
  final local = value.toLocal();
  const months = [
    'Oca',
    'Şub',
    'Mar',
    'Nis',
    'May',
    'Haz',
    'Tem',
    'Ağu',
    'Eyl',
    'Eki',
    'Kas',
    'Ara',
  ];
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${months[local.month - 1]} $hour:$minute';
}

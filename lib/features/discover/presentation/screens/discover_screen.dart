import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_filter_controls.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_pressable_scale.dart';
import '../../../events/presentation/widgets/activity_recommendation_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String? _selectedEventSlug;
  String? _selectedVenueActivitySlug;
  int _sliderIndex = 0;
  int _eventSliderIndex = 0;

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
    final selectedEventExists =
        _selectedEventSlug == null ||
        events.any((event) => event.slug == _selectedEventSlug);
    final effectiveSelectedEventSlug = selectedEventExists
        ? _selectedEventSlug
        : null;
    final sliderEvents = effectiveSelectedEventSlug == null
        ? events
        : events
              .where((event) => event.slug == effectiveSelectedEventSlug)
              .toList();
    final selectedVenueActivityExists =
        _selectedVenueActivitySlug == null ||
        activities.any(
          (activity) => activity.slug == _selectedVenueActivitySlug,
        ) ||
        venues.any(
          (venue) => venue.activitySummary.any(
            (activity) => activity.activitySlug == _selectedVenueActivitySlug,
          ),
        );
    final effectiveSelectedVenueActivitySlug = selectedVenueActivityExists
        ? _selectedVenueActivitySlug
        : null;
    final filteredVenues = effectiveSelectedVenueActivitySlug == null
        ? venues
        : venues
              .where(
                (venue) => venue.activitySummary.any(
                  (activity) =>
                      activity.activitySlug ==
                      effectiveSelectedVenueActivitySlug,
                ),
              )
              .toList();

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
              SliverToBoxAdapter(
                child: _buildFilterBar(
                  events,
                  effectiveSelectedEventSlug: effectiveSelectedEventSlug,
                ),
              ),
              if (isFirstLoad)
                SliverToBoxAdapter(child: _buildSkeletonFeed())
              else if (hasBlockingError)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildErrorState(),
                )
              else ...[
                SliverToBoxAdapter(
                  child: _buildNearbyMapSection(selectedCity: selectedCity),
                ),
                SliverToBoxAdapter(
                  child: _buildHomeImageSlider(
                    events: sliderEvents,
                    venues: effectiveSelectedEventSlug == null
                        ? venues
                        : const <ApiVenue>[],
                  ),
                ),
                if (effectiveSelectedEventSlug == null)
                  SliverToBoxAdapter(
                    child: _buildMoodEventSlider(sliderEvents),
                  ),
                SliverToBoxAdapter(
                  child: _buildPopularVenuesCarousel(
                    venues: filteredVenues,
                    allVenues: venues,
                    activities: activities,
                    effectiveSelectedActivitySlug:
                        effectiveSelectedVenueActivitySlug,
                  ),
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
    final layout = context.layout;

    return SizedBox(
      height: layout.headerHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: layout.screenPadding),
        child: Row(
          children: [
            Text(
              'Keşfet',
              style: TextStyle(
                color: BiCikalimTheme.textPrimary,
                fontSize: layout.pageTitleSize,
                height: 1.05,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => context.go('/profile'),
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: BiCikalimTheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            cityLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
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
              ),
            ),
            if (!layout.isCompact) ...[
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
                tooltip: 'Bildirimler',
                onTap: () {},
              ),
              const SizedBox(width: 4),
            ],
            _HeaderIconButton(
              icon: Icons.person_outline_rounded,
              tooltip: 'Profil',
              onTap: () => context.go('/profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.layout.screenPadding),
      child: AppPressableScale(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.layout.controlRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push('/discover/search'),
            child: Container(
              height: context.layout.searchHeight,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF0EDE9)),
                borderRadius: BorderRadius.circular(
                  context.layout.controlRadius,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.035),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: BiCikalimTheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Aktivite, mekan veya etkinlik ara',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: BiCikalimTheme.textLight,
                        fontSize: 13,
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

  Widget _buildFilterBar(
    List<ApiEvent> events, {
    required String? effectiveSelectedEventSlug,
  }) {
    return SizedBox(
      height: AppLayout.minTouchTarget + 4,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.layout.screenPadding),
        itemCount: events.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final event = index == 0 ? null : events[index - 1];
          final selected = event == null
              ? effectiveSelectedEventSlug == null
              : effectiveSelectedEventSlug == event.slug;
          return AppFilterChoiceChip(
            label: event?.title ?? 'Trendler',
            selected: selected,
            onTap: () => setState(() {
              _selectedEventSlug = event?.slug;
              _sliderIndex = 0;
              _eventSliderIndex = 0;
            }),
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
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        0,
        context.layout.screenPadding,
        context.layout.sectionGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sana Göre Aktiviteler',
                      style: TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: context.layout.sectionTitleSize,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Şehirde yapabileceğin aktiviteleri keşfet.',
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
              actionLabel: 'Ayarlara Git',
              onAction: () => context.go('/profile'),
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

                final cardHeight = MediaQuery.textScalerOf(context)
                    .scale(context.layout.fluid(170, 176, 188))
                    .clamp(170.0, 246.0)
                    .toDouble();
                final cardWidth = context.layout.carouselCardWidth(
                  visibleItems: 2.9,
                  min: 108,
                  max: 150,
                );
                return SizedBox(
                  height: cardHeight,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: recommendations.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(width: context.layout.cardGap),
                    itemBuilder: (context, index) {
                      final recommendation = recommendations[index];
                      return SizedBox(
                        width: cardWidth,
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

  Widget _buildPopularVenuesCarousel({
    required List<ApiVenue> venues,
    required List<ApiVenue> allVenues,
    required List<ApiActivity> activities,
    required String? effectiveSelectedActivitySlug,
  }) {
    if (allVenues.isEmpty) return const SizedBox.shrink();
    final layout = context.layout;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final textHeightAllowance = (textScale - 1).clamp(0.0, 1.0) * 52;
    final cardWidth = layout.carouselCardWidth(
      visibleItems: 2.45,
      min: 124,
      max: 176,
    );

    return Padding(
      padding: EdgeInsets.only(bottom: layout.cardGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: layout.screenPadding),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Popüler Mekanlar',
                    style: TextStyle(
                      color: BiCikalimTheme.textPrimary,
                      fontSize: layout.sectionTitleSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push(
                    '/discover/results?type=venues&title=Popüler%20Mekanlar',
                  ),
                  child: const Text('Tümü'),
                ),
              ],
            ),
          ),
          _buildPopularVenueFilterBar(
            allVenues,
            activities: activities,
            effectiveSelectedActivitySlug: effectiveSelectedActivitySlug,
          ),
          const SizedBox(height: 8),
          if (venues.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: layout.screenPadding),
              child: _WarmStateCard(
                icon: Icons.storefront_outlined,
                title: 'Bu filtrede mekan bulamadık',
                message:
                    'Farklı bir aktivite seçerek popüler mekanları görebilirsin.',
                actionLabel: 'Popülerleri Göster',
                onAction: () =>
                    setState(() => _selectedVenueActivitySlug = null),
              ),
            )
          else
            SizedBox(
              height: layout.fluid(154, 164, 178) + textHeightAllowance,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: layout.screenPadding),
                itemCount: venues.take(8).length,
                separatorBuilder: (_, _) => SizedBox(width: layout.cardGap),
                itemBuilder: (context, index) {
                  final venue = venues[index];
                  return SizedBox(
                    width: cardWidth,
                    child: _VenueExploreCard(
                      venue: venue,
                      large: false,
                      accent: _accentFor(venue.slug),
                      onTap: () => context.push('/venues/${venue.slug}'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPopularVenueFilterBar(
    List<ApiVenue> venues, {
    required List<ApiActivity> activities,
    required String? effectiveSelectedActivitySlug,
  }) {
    final filters = _popularVenueActivityFilters(
      venues: venues,
      activities: activities,
    );
    if (filters.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: AppLayout.minTouchTarget + 4,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: context.layout.screenPadding),
        itemCount: filters.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = index == 0 ? null : filters[index - 1];
          final selected = filter == null
              ? effectiveSelectedActivitySlug == null
              : effectiveSelectedActivitySlug == filter.slug;
          return AppFilterChoiceChip(
            label: filter?.label ?? 'Popüler',
            selected: selected,
            onTap: () => setState(() {
              _selectedVenueActivitySlug = filter?.slug;
            }),
          );
        },
      ),
    );
  }

  List<_VenueActivityFilter> _popularVenueActivityFilters({
    required List<ApiVenue> venues,
    required List<ApiActivity> activities,
  }) {
    final bySlug = <String, _VenueActivityFilter>{};
    for (final activity in activities) {
      final slug = activity.slug.trim();
      final label = activity.name.trim();
      if (slug.isEmpty || label.isEmpty || bySlug.containsKey(slug)) {
        continue;
      }
      bySlug[slug] = _VenueActivityFilter(slug: slug, label: label);
    }
    for (final venue in venues) {
      for (final activity in venue.activitySummary) {
        final slug = activity.activitySlug.trim();
        final label = activity.activityName.trim();
        if (slug.isEmpty || label.isEmpty || bySlug.containsKey(slug)) {
          continue;
        }
        bySlug[slug] = _VenueActivityFilter(slug: slug, label: label);
      }
    }
    return bySlug.values.take(10).toList();
  }

  Widget _buildMoodEventSlider(
    List<ApiEvent> events, {
    bool includeSports = false,
  }) {
    final items = events
        .where((event) => event.imageUrl.trim().isNotEmpty)
        .where((event) => includeSports || !_isSportEvent(event))
        .take(6)
        .map(
          (event) => _HomeSliderItem(
            title: event.title,
            subtitle: [
              _formatEventDate(event.startDate),
              event.venue?.name ?? event.city.name,
            ].where((part) => part.isNotEmpty).join(' • '),
            imageUrl: event.imageUrl,
            badge: _eventBadge(event),
            route: '/events/${event.slug}',
          ),
        )
        .toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final currentIndex = _eventSliderIndex.clamp(0, items.length - 1).toInt();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        0,
        context.layout.screenPadding,
        8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Sıkı can iyidir çabuk çıkmaz AMA',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: BiCikalimTheme.textPrimary,
                fontSize: context.layout.sectionTitleSize,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 2.7,
            child: PageView.builder(
              key: ValueKey('mood-${_selectedEventSlug ?? 'trends'}'),
              itemCount: items.length,
              onPageChanged: (index) =>
                  setState(() => _eventSliderIndex = index),
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
            const SizedBox(height: 5),
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

  Widget _buildHomeImageSlider({
    required List<ApiEvent> events,
    required List<ApiVenue> venues,
  }) {
    final items = _homeSliderItems(events: events, venues: venues);

    if (items.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          context.layout.screenPadding,
          6,
          context.layout.screenPadding,
          8,
        ),
        child: AspectRatio(
          aspectRatio: 2.7,
          child: Container(
            padding: EdgeInsets.all(context.layout.cardPadding),
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
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        6,
        context.layout.screenPadding,
        8,
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 2.7,
            child: PageView.builder(
              key: ValueKey('home-${_selectedEventSlug ?? 'trends'}'),
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
            const SizedBox(height: 5),
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
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        8,
        context.layout.screenPadding,
        context.layout.sectionGap,
      ),
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
                    padding: EdgeInsets.all(context.layout.cardPadding),
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
                        Text(
                          'Bu Akşam Ne Yapsak?',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.layout.sectionTitleSize,
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

  Widget _buildNearbyMapSection({required ApiCity? selectedCity}) {
    final hasCity = selectedCity != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        0,
        context.layout.screenPadding,
        context.layout.sectionGap,
      ),
      child: AppPressableScale(
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(context.layout.cardRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => hasCity ? context.go('/map') : context.go('/profile'),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.layout.cardRadius),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF171A18),
                    Color(0xFF24372D),
                    BiCikalimTheme.primaryDark,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -16,
                    bottom: -20,
                    child: Icon(
                      Icons.map_rounded,
                      color: Colors.white.withValues(alpha: 0.08),
                      size: 132,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(context.layout.cardPadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _SolidPill(label: 'Yakınımda'),
                              const SizedBox(height: 12),
                              Text(
                                'Yakınımda ne var?',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.layout.sectionTitleSize,
                                  height: 1.12,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                hasCity
                                    ? '${selectedCity.name} içindeki mekanları haritada keşfet.'
                                    : 'Yakındaki mekanları görmek için şehir seçimini profilden tamamla.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 12,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            hasCity
                                ? Icons.near_me_rounded
                                : Icons.settings_rounded,
                            color: BiCikalimTheme.primary,
                            size: 22,
                          ),
                        ),
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
    final selectedEventTitle = events
        .where((event) => event.slug == _selectedEventSlug)
        .firstOrNull
        ?.title;
    final title = selectedEventTitle ?? 'Trend keşifler';

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        4,
        context.layout.screenPadding,
        8,
      ),
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
                  style: TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: context.layout.sectionTitleSize,
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
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        0,
        context.layout.screenPadding,
        context.layout.sectionGap,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = context.layout.cardGap;
          final useTwoColumns = !context.layout.isCompact;
          final fullWidth = constraints.maxWidth;
          final halfWidth = (constraints.maxWidth - gap) / 2;
          final cards = <Widget>[];

          void addCard(Widget child, {required bool large}) {
            cards.add(
              SizedBox(
                width: large || !useTwoColumns ? fullWidth : halfWidth,
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
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        8,
        context.layout.screenPadding,
        context.layout.sectionGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(
            height: context.layout.fluid(142, 148, 158),
            radius: context.layout.cardRadius,
          ),
          SizedBox(height: context.layout.sectionGap),
          if (context.layout.isCompact) ...[
            _SkeletonBox(
              height: context.layout.fluid(150, 156, 166),
              radius: context.layout.cardRadius,
            ),
            SizedBox(height: context.layout.cardGap),
            _SkeletonBox(
              height: context.layout.fluid(168, 174, 186),
              radius: context.layout.cardRadius,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _SkeletonBox(
                    height: context.layout.fluid(150, 156, 166),
                    radius: context.layout.cardRadius,
                  ),
                ),
                SizedBox(width: context.layout.cardGap),
                Expanded(
                  child: _SkeletonBox(
                    height: context.layout.fluid(168, 174, 186),
                    radius: context.layout.cardRadius,
                  ),
                ),
              ],
            ),
          SizedBox(height: context.layout.cardGap),
          _SkeletonBox(
            height: context.layout.fluid(178, 184, 196),
            radius: context.layout.cardRadius,
          ),
          SizedBox(height: context.layout.cardGap),
          if (context.layout.isCompact) ...[
            _SkeletonBox(
              height: context.layout.fluid(146, 152, 162),
              radius: context.layout.cardRadius,
            ),
            SizedBox(height: context.layout.cardGap),
            _SkeletonBox(
              height: context.layout.fluid(154, 160, 170),
              radius: context.layout.cardRadius,
            ),
          ] else
            Row(
              children: [
                Expanded(
                  child: _SkeletonBox(
                    height: context.layout.fluid(146, 152, 162),
                    radius: context.layout.cardRadius,
                  ),
                ),
                SizedBox(width: context.layout.cardGap),
                Expanded(
                  child: _SkeletonBox(
                    height: context.layout.fluid(154, 160, 170),
                    radius: context.layout.cardRadius,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonTail() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        0,
        context.layout.screenPadding,
        context.layout.sectionGap,
      ),
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
      padding: EdgeInsets.all(context.layout.screenPadding),
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
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        10,
        context.layout.screenPadding,
        context.layout.sectionGap,
      ),
      child: _WarmStateCard(
        icon: Icons.explore_off_outlined,
        title: 'Yakınında henüz sonuç bulamadık',
        message:
            'Şehir genelindeki popüler aktiviteleri keşfet veya farklı filtreler dene.',
        actionLabel: 'Popülerleri Gör',
        onAction: () => setState(() {
          _selectedEventSlug = null;
          _sliderIndex = 0;
          _eventSliderIndex = 0;
        }),
      ),
    );
  }

  List<ApiActivity> _visibleActivities(List<ApiActivity> activities) {
    return activities.take(12).toList();
  }

  List<ApiVenue> _visibleVenues(List<ApiVenue> venues) {
    return venues.take(8).toList();
  }

  List<ApiEvent> _visibleEvents(List<ApiEvent> events) {
    final filtered = _selectedEventSlug == null
        ? List<ApiEvent>.from(events)
        : events.where((event) => event.slug == _selectedEventSlug).toList();
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

  bool _isGroupActivity(ApiActivity activity) {
    return (activity.maxPeople ?? 0) >= 3 ||
        (activity.minPeople ?? 0) >= 2 ||
        _containsAny(activity.name, _groupTerms);
  }

  bool _isSportEvent(ApiEvent event) {
    final source = [
      event.title,
      event.shortDescription ?? '',
      ...event.activities.map((activity) => activity.name),
      ...event.activities.map((activity) => activity.slug),
    ].join(' ');
    return _containsAny(source, _sportTerms);
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
            width: AppLayout.minTouchTarget,
            height: AppLayout.minTouchTarget,
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
    final layout = context.layout;

    return _ExploreCardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: large
                ? layout.fluid(96, 104, 112)
                : layout.fluid(68, 72, 78),
            child: _GradientCover(
              accent: accent,
              icon: activity.iconData,
              badge: large ? 'Aktivite' : proof,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(layout.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  maxLines: large ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: large
                        ? layout.sectionTitleSize
                        : layout.cardTitleSize,
                    height: 1.12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category?.name ?? _participantLabel(activity),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: layout.metadataSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _SignalRow(
                  icon: Icons.storefront_outlined,
                  label: venueSignal,
                  secondary: proof,
                ),
              ],
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
    final layout = context.layout;
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
            height: large
                ? layout.fluid(96, 104, 112)
                : layout.fluid(68, 72, 78),
            child: _ImageOrGradientCover(
              imageUrl: venue.coverImageUrl,
              accent: accent,
              icon: Icons.storefront_rounded,
              badge: 'Mekan',
            ),
          ),
          Padding(
            padding: EdgeInsets.all(layout.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  maxLines: large ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: large
                        ? layout.sectionTitleSize
                        : layout.cardTitleSize,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activityText.isEmpty ? venue.cityName : activityText,
                  maxLines: large ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: layout.metadataSize,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
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
    final layout = context.layout;

    return _ExploreCardShell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: large
                ? layout.fluid(92, 100, 108)
                : layout.fluid(66, 70, 76),
            child: _ImageOrGradientCover(
              imageUrl: event.imageUrl,
              accent: accent,
              icon: Icons.event_rounded,
              badge: _eventBadge(event),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(layout.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: large ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: large
                        ? layout.sectionTitleSize
                        : layout.cardTitleSize,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.venue?.name ?? event.city.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: layout.metadataSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _SignalRow(
                  icon: Icons.schedule_outlined,
                  label: _formatEventDate(event.startAt),
                  secondary: event.priceInfo,
                ),
              ],
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
        padding: EdgeInsets.all(context.layout.cardPadding),
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
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BiCikalimTheme.textPrimary,
                      fontSize: context.layout.sectionTitleSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: context.layout.metadataSize,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: context.layout.fluid(52, 56, 62),
              height: context.layout.fluid(68, 74, 82),
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
            height: context.layout.fluid(60, 64, 70),
            child: _GradientCover(
              accent: accent,
              icon: category.iconData,
              badge: 'Kategori',
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.layout.cardPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: context.layout.cardTitleSize,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const _SignalRow(
                  icon: Icons.explore_outlined,
                  label: 'Popülerleri gör',
                  secondary: 'Keşfet',
                ),
              ],
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
    final radius = context.layout.cardRadius;

    return AppPressableScale(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
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
          borderRadius: BorderRadius.circular(radius),
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
      padding: EdgeInsets.all(context.layout.screenPadding),
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

class _VenueActivityFilter {
  final String slug;
  final String label;

  const _VenueActivityFilter({required this.slug, required this.label});
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
          width: context.layout.fluid(112, 122, 142),
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

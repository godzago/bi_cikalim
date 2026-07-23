import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_section_header.dart';
import '../../../../shared/widgets/app_pressable_scale.dart';
import '../../../../shared/widgets/category_card.dart';
import '../../../../shared/widgets/event_preview_card.dart';
import '../../../../shared/widgets/venue_card.dart';
import 'activity_list_tab.dart';

/// Keşfet ana ekranı.
/// Getir benzeri ergonomik, modüler ve görsel odaklı tasarım prensipleriyle revize edilmiştir.
class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _lastTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging ||
        _tabController.index == _lastTabIndex) {
      return;
    }

    _lastTabIndex = _tabController.index;
    if (_lastTabIndex == 1) {
      ref.invalidate(venuesListProvider);
    }
  }

  Future<void> _refreshDiscover() async {
    final citySlug = ref.read(selectedCityProvider).value?.slug;
    final venuesProvider = venuesListProvider(VenueFilters(citySlug: citySlug));
    final eventsProvider = eventsListProvider(EventFilters(citySlug: citySlug));

    ref
      ..invalidate(categoriesProvider)
      ..invalidate(activitiesProvider)
      ..invalidate(venuesProvider)
      ..invalidate(eventsProvider);

    await Future.wait([
      ref.read(categoriesProvider.future),
      ref.read(activitiesProvider.future),
      ref.read(venuesProvider.future),
      ref.read(eventsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final citySlug = ref.watch(selectedCityProvider).value?.slug;
    final eventsAsync = ref.watch(
      eventsListProvider(EventFilters(citySlug: citySlug)),
    );
    final venuesAsync = ref.watch(
      venuesListProvider(VenueFilters(citySlug: citySlug)),
    );

    return Scaffold(
      backgroundColor: BiCikalimTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: BiCikalimTheme.primary,
          onRefresh: _refreshDiscover,
          notificationPredicate: (notification) =>
              notification.metrics.axis == Axis.vertical &&
              notification.depth <= 1,
          child: NestedScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                // Kaydırılabilir Üst Modüler Alanlar
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopHeader(),
                      _buildTopSearchBar(),
                      _buildQuickIntentArea(),
                      _buildTonightDiscoveryBanner(),
                      categoriesAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(
                              color: BiCikalimTheme.primary,
                            ),
                          ),
                        ),
                        error: (e, _) => Center(child: Text('Hata: $e')),
                        data: (categories) =>
                            _buildCategoryGridSection(categories),
                      ),
                      eventsAsync.when(
                        loading: () => const SizedBox(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: BiCikalimTheme.primary,
                            ),
                          ),
                        ),
                        error: (e, _) => Center(child: Text('Hata: $e')),
                        data: (events) => _buildEventsSection(events),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Tab Switcher (Aktiviteler / Mekanlar) - Tepeye Sabitlenir (Pinned)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(child: _buildTabBar()),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                const ActivityListTab(),
                venuesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      color: BiCikalimTheme.primary,
                    ),
                  ),
                  error: (e, _) => Center(child: Text('Hata: $e')),
                  data: (venues) => _buildVenueListTab(venues),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Üst Header (Logo, Konum Seçimi, Profil İkonu)
  // ---------------------------------------------------------------------------

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol Kısım: Marka logosu
          Image.asset(
            'assets/inapplogo.png',
            width: 100,
            height: 78,
            fit: BoxFit.contain,
            color: BiCikalimTheme.primary,
            colorBlendMode: BlendMode.srcIn,
            filterQuality: FilterQuality.high,
          ),
          // Sağ Kısım: Sade Profil İkonu
          GestureDetector(
            onTap: () => context.go('/profile'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_outline,
                color: BiCikalimTheme.textPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Search Bar — Tepe Arama Odak Noktası
  // ---------------------------------------------------------------------------

  Widget _buildTopSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GestureDetector(
        onTap: () => context.push('/discover/search'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: BiCikalimTheme.primary, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Oyun, aktivite, etkinlik veya mekan ara',
                  style: TextStyle(
                    color: BiCikalimTheme.textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Hızlı Niyet / Hızlı Aksiyon Alanı
  // ---------------------------------------------------------------------------

  Widget _buildQuickIntentArea() {
    final actions = [
      {'label': 'Yakınımda', 'icon': '📍', 'route': '/map'},
      {'label': 'Bu Akşam', 'icon': '🌙', 'route': '/events/tonight'},
      {'label': '4 Kişi', 'icon': '👥', 'query': '4 kişi'},
      {'label': 'Ücretsiz', 'icon': '🆓', 'query': 'ücretsiz'},
      {'label': 'Etkinlik Bul', 'icon': '🎟️', 'route': '/events'},
      {'label': 'Mekan Bul', 'icon': '🏪', 'query': 'mekan'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 18, 20, 8),
          child: Text(
            'Bugün ne yapmak istersin?',
            style: TextStyle(
              color: BiCikalimTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    if (action['route'] != null) {
                      context.go(action['route'] as String);
                    } else if (action['query'] != null) {
                      context.push(
                        Uri(
                          path: '/discover/results',
                          queryParameters: {
                            'query': action['query'] as String,
                            'title': action['label'] as String,
                          },
                        ).toString(),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          action['icon'] as String,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          action['label'] as String,
                          style: const TextStyle(
                            color: BiCikalimTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Bu Akşam Ne Yapsak?
  // ---------------------------------------------------------------------------

  Widget _buildTonightDiscoveryBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: AppPressableScale(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/events/tonight'),
            borderRadius: BorderRadius.circular(20),
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [BiCikalimTheme.primary, BiCikalimTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -28,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.style_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bu Akşam Ne Yapsak?',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Etkinlikleri sağa veya sola kaydırarak seç.',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.35,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 34,
                          height: 34,
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Responsive kategori keşif grid'i
  // ---------------------------------------------------------------------------

  Widget _buildCategoryGridSection(List<ApiCategory> categories) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 22),
          child: AppSectionHeader(
            title: 'Kategorileri Keşfet',
            actionLabel: 'Tümü',
            onActionTap: () => context.push('/discover/catalog'),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 190,
                  mainAxisExtent: 152,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    category: category,
                    width: double.infinity,
                    margin: EdgeInsets.zero,
                    onTap: () {
                      context.push(
                        Uri(
                          path: '/discover/results',
                          queryParameters: {
                            'categorySlug': category.slug,
                            'title': category.name,
                          },
                        ).toString(),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Yakındaki Etkinlikler
  // ---------------------------------------------------------------------------

  Widget _buildEventsSection(List<ApiEvent> events) {
    if (events.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 22),
          child: AppSectionHeader(
            title: 'Bu Akşam Yakınında Ne Var?',
            actionLabel: 'Tümünü Gör',
            onActionTap: () => context.go('/events'),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 188,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventPreviewCard(
                event: event,
                onTap: () => context.push('/events/${event.slug}'),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 7. Tab Bar — Aktiviteler / Mekanlar Switcher
  // ---------------------------------------------------------------------------

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: BiCikalimTheme.textPrimary,
        unselectedLabelColor: BiCikalimTheme.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_esports_outlined, size: 16),
                SizedBox(width: 6),
                Text('Aktiviteler'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.store_outlined, size: 16),
                SizedBox(width: 6),
                Text('Mekanlar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Mekan Listesi Sekmesi
  // ---------------------------------------------------------------------------

  Widget _buildVenueListTab(List<ApiVenue> venues) {
    if (venues.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          Padding(
            padding: EdgeInsets.fromLTRB(32, 96, 32, 32),
            child: Text(
              'Mekan bulunamadı.\nYenilemek için aşağı çek.',
              textAlign: TextAlign.center,
              style: TextStyle(color: BiCikalimTheme.textSecondary),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: venues.length,
      separatorBuilder: (context, i) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final venue = venues[index];
        return VenueCard(
          venue: venue,
          onTap: () => context.push('/venues/${venue.slug}'),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sliver Persistent Header Delegate for TabBar
// ---------------------------------------------------------------------------

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverTabBarDelegate({required this.child});

  @override
  double get minExtent => 76.0;
  @override
  double get maxExtent => 76.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: BiCikalimTheme.background,
      alignment: Alignment.center,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

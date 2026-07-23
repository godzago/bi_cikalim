import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_section_header.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final eventsAsync = ref.watch(eventsListProvider(const EventFilters()));
    final venuesAsync = ref.watch(venuesListProvider(const VenueFilters()));

    return Scaffold(
      backgroundColor: BiCikalimTheme.background,
      body: SafeArea(
        child: NestedScrollView(
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
                    categoriesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: BiCikalimTheme.primary),
                        ),
                      ),
                      error: (e, _) => Center(child: Text('Hata: $e')),
                      data: (categories) => _buildCategoryGridSection(categories),
                    ),
                    eventsAsync.when(
                      loading: () => const SizedBox(
                        height: 180,
                        child: Center(child: CircularProgressIndicator(color: BiCikalimTheme.primary)),
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
                delegate: _SliverTabBarDelegate(
                  child: _buildTabBar(),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              const ActivityListTab(),
              venuesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: BiCikalimTheme.primary)),
                error: (e, _) => Center(child: Text('Hata: $e')),
                data: (venues) => _buildVenueListTab(venues),
              ),
            ],
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
          // Sol Kısım: Başlık
          const Text(
            'BiÇıkalım',
            style: TextStyle(
              color: BiCikalimTheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 26,
              height: 1.2,
            ),
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
            border: Border.all(
              color: Colors.grey.shade200,
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.search,
                color: BiCikalimTheme.primary,
                size: 22,
              ),
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
      {'label': 'Bu Akşam', 'icon': '🌙', 'query': 'bu akşam'},
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
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
                        Text(action['icon'] as String, style: const TextStyle(fontSize: 12)),
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
  // 4. Ana Kategori Grid Görünümü (Getir stili görsel listeleme)
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
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
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
                        'categoryId': category.id,
                        'title': category.name,
                      },
                    ).toString(),
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
  // 5. Yakındaki Etkinlikler
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
              final venue = ApiVenue(
                id: event.venueId,
                name: event.venue?.name ?? 'Mekan',
                slug: event.venue?.slug ?? 'mekan',
                venueType: 'cafe',
                city: ApiLocationSummary(id: '1', name: 'Eskişehir', slug: 'eskisehir'),
                isVerified: true,
                isFavorite: false,
                activitySummary: const [],
                coverUrl: event.coverUrl,
              );
              return EventPreviewCard(
                event: event,
                venue: venue,
                onTap: () => context.push('/venues/${venue.slug}'),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Tab Bar — Aktiviteler / Mekanlar Switcher
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
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
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
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Mekan bulunamadı.',
            style: TextStyle(color: BiCikalimTheme.textSecondary),
          ),
        ),
      );
    }

    return ListView.separated(
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
      BuildContext context, double shrinkOffset, bool overlapsContent) {
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_skeleton.dart';
import '../widgets/activity_recommendation_card.dart';
import '../widgets/tonight_event_card.dart';

class TonightScreen extends ConsumerStatefulWidget {
  const TonightScreen({super.key});

  @override
  ConsumerState<TonightScreen> createState() => _TonightScreenState();
}

class _TonightScreenState extends ConsumerState<TonightScreen> {
  static const _eventPageSize = 10;

  final _scrollController = ScrollController();
  final _favoriteOverrides = <String, bool>{};
  final _attendanceOverrides = <String, String?>{};
  final _eventBusy = <String>{};

  String? _categorySlug;
  String? _subcategorySlug;
  String? _activitySlug;
  bool _verifiedOnly = false;
  bool _coordinatesOnly = false;

  List<ApiEvent> _events = const [];
  Object? _eventsError;
  bool _eventsLoading = false;
  bool _eventsLoadingMore = false;
  bool _eventsHasMore = true;
  int _eventsPage = 0;
  int _eventsRequestToken = 0;
  String? _loadedCitySlug;
  String? _loadedActivitySlug;
  TonightTimeRange? _loadedRange;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.extentAfter < 700) {
      _loadMoreEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cityAsync = ref.watch(selectedCityProvider);
    final selectedCity = cityAsync.value;
    final citySlug = selectedCity?.slug;

    if ((citySlug == null && _loadedCitySlug != null) ||
        (citySlug != null &&
            (citySlug != _loadedCitySlug ||
                _activitySlug != _loadedActivitySlug))) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reloadEvents(citySlug);
      });
    }

    final recommendationsAsync = citySlug == null
        ? null
        : ref.watch(
            tonightActivityRecommendationsProvider(
              TonightRecommendationFilters(
                citySlug: citySlug,
                categorySlug: _categorySlug,
                subcategorySlug: _subcategorySlug,
                activitySlug: _activitySlug,
                isVerified: _verifiedOnly ? true : null,
                hasCoordinates: _coordinatesOnly ? true : null,
                limit: 10,
              ),
            ),
          );

    return Scaffold(
      backgroundColor: const Color(0xFFFBFAF8),
      appBar: AppBar(title: const Text('Bu Akşam Ne Yapsak?')),
      body: RefreshIndicator(
        color: BiCikalimTheme.primary,
        onRefresh: () => _refreshAll(citySlug),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(selectedCity)),
            SliverToBoxAdapter(child: _buildFilterArea()),
            SliverToBoxAdapter(
              child: _buildActivitySection(recommendationsAsync, citySlug),
            ),
            SliverToBoxAdapter(child: _buildEventsHeader()),
            ..._buildEventSlivers(),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ApiCity? selectedCity) {
    final range = _loadedRange ?? _calculateTonightRange();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF0EDE9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              selectedCity == null
                  ? 'Şehir seçerek önerileri gör'
                  : '${selectedCity.name}’de bu akşam',
              style: const TextStyle(
                color: BiCikalimTheme.textPrimary,
                fontSize: 22,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Şehirde şu anda yapabileceğin aktiviteleri keşfet.',
              style: TextStyle(
                color: BiCikalimTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 17,
                  color: BiCikalimTheme.primary.withValues(alpha: .9),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_formatClock(range.from)} - ${_formatClock(range.to)} aralığı',
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/city-select'),
                  child: Text(selectedCity == null ? 'Şehir Seç' : 'Değiştir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterArea() {
    final categoriesAsync = ref.watch(categoriesProvider);
    final subcategoriesAsync = ref.watch(subcategoriesProvider(_categorySlug));
    final activitiesAsync = ref.watch(
      filteredActivitiesProvider(
        ActivityFilters(
          categorySlug: _categorySlug,
          subcategorySlug: _subcategorySlug,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChipRow(
            children: [
              _filterChip('Tümü', _categorySlug == null, () {
                setState(() {
                  _categorySlug = null;
                  _subcategorySlug = null;
                  _activitySlug = null;
                });
              }),
              ...categoriesAsync.value
                      ?.take(10)
                      .map(
                        (category) => _filterChip(
                          category.name,
                          _categorySlug == category.slug,
                          () {
                            setState(() {
                              _categorySlug = category.slug;
                              _subcategorySlug = null;
                              _activitySlug = null;
                            });
                          },
                        ),
                      ) ??
                  const [],
            ],
          ),
          if (_categorySlug != null &&
              (subcategoriesAsync.value?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            _buildChipRow(
              children: [
                _filterChip('Alt kategori yok', _subcategorySlug == null, () {
                  setState(() {
                    _subcategorySlug = null;
                    _activitySlug = null;
                  });
                }),
                ...subcategoriesAsync.value!
                    .take(10)
                    .map(
                      (subcategory) => _filterChip(
                        subcategory.name,
                        _subcategorySlug == subcategory.slug,
                        () {
                          setState(() {
                            _subcategorySlug = subcategory.slug;
                            _activitySlug = null;
                          });
                        },
                      ),
                    ),
              ],
            ),
          ],
          if (activitiesAsync.value?.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            _buildChipRow(
              children: [
                _filterChip('Aktivite seçme', _activitySlug == null, () {
                  setState(() => _activitySlug = null);
                }),
                ...activitiesAsync.value!
                    .take(12)
                    .map(
                      (activity) => _filterChip(
                        activity.name,
                        _activitySlug == activity.slug,
                        () => setState(() => _activitySlug = activity.slug),
                      ),
                    ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _buildChipRow(
            children: [
              _filterChip('Doğrulanmış mekânlar', _verifiedOnly, () {
                setState(() => _verifiedOnly = !_verifiedOnly);
              }),
              _filterChip('Konum bilgisi var', _coordinatesOnly, () {
                setState(() => _coordinatesOnly = !_coordinatesOnly);
              }),
              if (_categorySlug != null ||
                  _subcategorySlug != null ||
                  _activitySlug != null ||
                  _verifiedOnly ||
                  _coordinatesOnly)
                _filterChip('Filtreleri temizle', false, () {
                  setState(() {
                    _categorySlug = null;
                    _subcategorySlug = null;
                    _activitySlug = null;
                    _verifiedOnly = false;
                    _coordinatesOnly = false;
                  });
                }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChipRow({required List<Widget> children}) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      selectedColor: BiCikalimTheme.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: selected ? BiCikalimTheme.primary : const Color(0xFFEDE8E3),
      ),
      labelStyle: TextStyle(
        color: selected ? Colors.white : BiCikalimTheme.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildActivitySection(
    AsyncValue<List<TonightActivityRecommendation>>? recommendationsAsync,
    String? citySlug,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: 'Bu akşam yapabileceğin aktiviteler',
            subtitle:
                'Aktiviteler zamansızdır; kartlar “nerede yapabilirim?” sorusuna cevap verir.',
          ),
          const SizedBox(height: 12),
          if (citySlug == null)
            AppEmptyState(
              icon: Icons.location_city_outlined,
              title: 'Şehir seçmelisin',
              message: 'Önerileri göstermek için şehir seçmelisin.',
              actionLabel: 'Şehir Seç',
              onAction: () => context.push('/city-select'),
              padding: const EdgeInsets.all(24),
            )
          else
            recommendationsAsync!.when(
              loading: () => const _ActivitySkeletonList(),
              error: (error, _) => _PartialErrorView(
                message: 'Aktivite önerileri yüklenemedi.',
                onRetry: () => ref.invalidate(
                  tonightActivityRecommendationsProvider(
                    TonightRecommendationFilters(
                      citySlug: citySlug,
                      categorySlug: _categorySlug,
                      subcategorySlug: _subcategorySlug,
                      activitySlug: _activitySlug,
                      isVerified: _verifiedOnly ? true : null,
                      hasCoordinates: _coordinatesOnly ? true : null,
                      limit: 10,
                    ),
                  ),
                ),
              ),
              data: (recommendations) {
                if (recommendations.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.sports_esports_outlined,
                    title: 'Bu akşam için henüz aktivite önerisi bulamadık',
                    message:
                        'Şehirdeki tüm aktiviteleri inceleyebilir veya farklı bir kategori seçebilirsin.',
                    actionLabel: 'Filtreleri Temizle',
                    onAction: () {
                      setState(() {
                        _categorySlug = null;
                        _subcategorySlug = null;
                        _activitySlug = null;
                        _verifiedOnly = false;
                        _coordinatesOnly = false;
                      });
                    },
                    padding: const EdgeInsets.all(24),
                  );
                }

                return Column(
                  children: recommendations
                      .map(
                        (recommendation) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ActivityRecommendationCard(
                            recommendation: recommendation,
                            onTap: () =>
                                _openActivityVenues(recommendation, citySlug),
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEventsHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: _SectionTitle(
        title: 'Bu Akşamki Etkinlikler',
        subtitle: 'Etkinlikler tarih, saat ve mekânı belli tekil içeriklerdir.',
      ),
    );
  }

  List<Widget> _buildEventSlivers() {
    if (_eventsLoading && _events.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: _EventSkeletonList(),
          ),
        ),
      ];
    }

    if (_eventsError != null && _events.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _PartialErrorView(
              message: 'Bu akşamki etkinlikler yüklenemedi.',
              onRetry: () => _reloadEvents(_loadedCitySlug),
            ),
          ),
        ),
      ];
    }

    if (_events.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AppEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Bu akşam yayınlanmış bir etkinlik bulunmuyor',
              message: 'Yine de şehirde yapabileceğin pek çok aktivite var.',
              padding: EdgeInsets.all(24),
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList.builder(
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
            return TonightEventCard(
              event: event,
              isFavorite: _favoriteOverrides[event.id] ?? event.isFavorite,
              attendanceStatus:
                  _attendanceOverrides[event.id] ?? event.attendanceStatus,
              isBusy: _eventBusy.contains(event.id),
              onTap: () => _openEvent(event),
              onFavoriteTap: () => _toggleFavorite(event),
              onAttendanceTap: (status) => _setAttendance(event, status),
            );
          },
        ),
      ),
      if (_eventsLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Center(
              child: CircularProgressIndicator(color: BiCikalimTheme.primary),
            ),
          ),
        ),
      if (_eventsError != null && _events.isNotEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: _PartialErrorView(
              message: 'Etkinliklerin devamı yüklenemedi.',
              onRetry: _loadMoreEvents,
            ),
          ),
        ),
    ];
  }

  Future<void> _refreshAll(String? citySlug) async {
    Future<void>? recommendationsRefresh;
    if (citySlug != null) {
      final provider = tonightActivityRecommendationsProvider(
        TonightRecommendationFilters(
          citySlug: citySlug,
          categorySlug: _categorySlug,
          subcategorySlug: _subcategorySlug,
          activitySlug: _activitySlug,
          isVerified: _verifiedOnly ? true : null,
          hasCoordinates: _coordinatesOnly ? true : null,
          limit: 10,
        ),
      );
      ref.invalidate(provider);
      recommendationsRefresh = ref.read(provider.future).then((_) {});
    }
    await Future.wait([_reloadEvents(citySlug), ?recommendationsRefresh]);
  }

  Future<void> _reloadEvents(String? citySlug) async {
    final requestToken = ++_eventsRequestToken;
    if (citySlug == null) {
      if (!mounted) return;
      setState(() {
        _events = const [];
        _eventsError = null;
        _eventsLoading = false;
        _eventsLoadingMore = false;
        _eventsHasMore = false;
        _eventsPage = 0;
        _loadedCitySlug = null;
        _loadedActivitySlug = _activitySlug;
        _loadedRange = _calculateTonightRange();
      });
      return;
    }

    final range = _calculateTonightRange();
    setState(() {
      _eventsLoading = true;
      _eventsLoadingMore = false;
      _eventsError = null;
      _events = const [];
      _eventsPage = 0;
      _eventsHasMore = true;
      _loadedCitySlug = citySlug;
      _loadedActivitySlug = _activitySlug;
      _loadedRange = range;
    });

    try {
      final response = await ref
          .read(eventApiServiceProvider)
          .fetchEventsPage(
            page: 1,
            pageSize: _eventPageSize,
            citySlug: citySlug,
            activitySlug: _activitySlug,
            dateFrom: range.from,
            dateTo: range.to,
          );
      if (!mounted || requestToken != _eventsRequestToken) return;
      setState(() {
        _events = response.items;
        _eventsPage = response.page;
        _eventsHasMore = response.page < response.pages;
        _eventsLoading = false;
      });
    } catch (error) {
      if (!mounted || requestToken != _eventsRequestToken) return;
      setState(() {
        _eventsError = error;
        _eventsLoading = false;
      });
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_eventsLoading ||
        _eventsLoadingMore ||
        !_eventsHasMore ||
        _loadedCitySlug == null) {
      return;
    }
    final range = _loadedRange ?? _calculateTonightRange();
    setState(() {
      _eventsLoadingMore = true;
      _eventsError = null;
    });

    try {
      final response = await ref
          .read(eventApiServiceProvider)
          .fetchEventsPage(
            page: _eventsPage + 1,
            pageSize: _eventPageSize,
            citySlug: _loadedCitySlug,
            activitySlug: _activitySlug,
            dateFrom: range.from,
            dateTo: range.to,
          );
      if (!mounted) return;
      setState(() {
        _events = [..._events, ...response.items];
        _eventsPage = response.page;
        _eventsHasMore = response.page < response.pages;
        _eventsLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _eventsError = error;
        _eventsLoadingMore = false;
      });
    }
  }

  void _openActivityVenues(
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

  void _openEvent(ApiEvent event) {
    ref
        .read(analyticsApiServiceProvider)
        .track(
          eventName: AnalyticsEventName.eventView,
          eventRefId: event.id,
          properties: {'source': 'tonight_events'},
        );
    context.push('/events/${event.slug}');
  }

  Future<bool> _requireAuth() async {
    if (await ApiClient.instance.getToken() != null) return true;
    if (!mounted) return false;
    context.push('/sign-in?accountType=user');
    return false;
  }

  Future<void> _toggleFavorite(ApiEvent event) async {
    if (_eventBusy.contains(event.id) || !await _requireAuth()) return;
    final current = _favoriteOverrides[event.id] ?? event.isFavorite;
    final next = !current;
    setState(() {
      _eventBusy.add(event.id);
      _favoriteOverrides[event.id] = next;
    });

    try {
      final saved = next
          ? await ref.read(eventApiServiceProvider).addFavoriteEvent(event.id)
          : await ref
                .read(eventApiServiceProvider)
                .removeFavoriteEvent(event.id);
      ref
          .read(analyticsApiServiceProvider)
          .track(
            eventName: AnalyticsEventName.favorite,
            eventRefId: event.id,
            properties: {
              'source': 'tonight_screen',
              'target_type': 'event',
              'action': saved ? 'add' : 'remove',
            },
          );
      ref.invalidate(favoriteEventsProvider);
      if (!mounted) return;
      setState(() => _favoriteOverrides[event.id] = saved);
    } catch (error) {
      if (!mounted) return;
      setState(() => _favoriteOverrides[event.id] = current);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() => _eventBusy.remove(event.id));
      }
    }
  }

  Future<void> _setAttendance(ApiEvent event, String status) async {
    if (_eventBusy.contains(event.id) || !await _requireAuth()) return;
    final current = _attendanceOverrides[event.id] ?? event.attendanceStatus;
    final removing = current == status;
    final next = removing ? null : status;
    setState(() {
      _eventBusy.add(event.id);
      _attendanceOverrides[event.id] = next;
    });

    try {
      if (removing) {
        await ref.read(eventApiServiceProvider).deleteAttendance(event.id);
      } else {
        final attendance = await ref
            .read(eventApiServiceProvider)
            .setAttendance(event.id, status);
        _attendanceOverrides[event.id] = attendance.status;
      }
      if (!mounted) return;
      setState(() {});
    } catch (error) {
      if (!mounted) return;
      setState(() => _attendanceOverrides[event.id] = current);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
    } finally {
      if (mounted) {
        setState(() => _eventBusy.remove(event.id));
      }
    }
  }
}

class TonightTimeRange {
  final DateTime from;
  final DateTime to;

  const TonightTimeRange({required this.from, required this.to});
}

TonightTimeRange _calculateTonightRange([DateTime? now]) {
  final localNow = now ?? DateTime.now();
  final today = DateTime(localNow.year, localNow.month, localNow.day);
  final eveningStart = today.add(const Duration(hours: 18));
  final nextMorning = today.add(const Duration(days: 1, hours: 5));

  if (localNow.hour < 6 || localNow.isBefore(eveningStart)) {
    return TonightTimeRange(from: eveningStart, to: nextMorning);
  }

  return TonightTimeRange(from: localNow, to: nextMorning);
}

String _formatClock(DateTime value) {
  final local = value.toLocal();
  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$day/$month $hour:$minute';
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: BiCikalimTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: BiCikalimTheme.textSecondary,
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PartialErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _PartialErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0EDE9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: BiCikalimTheme.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: BiCikalimTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Tekrar Dene')),
        ],
      ),
    );
  }
}

class _ActivitySkeletonList extends StatelessWidget {
  const _ActivitySkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: ActivityCardSkeleton(),
        ),
      ),
    );
  }
}

class _EventSkeletonList extends StatelessWidget {
  const _EventSkeletonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => const Padding(
          padding: EdgeInsets.only(bottom: 14),
          child: EventCardSkeleton(),
        ),
      ),
    );
  }
}

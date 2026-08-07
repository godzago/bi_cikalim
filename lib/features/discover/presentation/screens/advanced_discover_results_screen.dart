import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_filter_controls.dart';
import '../../../../shared/widgets/event_list_card.dart';
import '../../../../shared/widgets/venue_card.dart';

class AdvancedDiscoverResultsScreen extends ConsumerStatefulWidget {
  final String type;
  final String? scope;
  final String? query;
  final String? citySlug;
  final String? categoryId;
  final String? subcategoryId;
  final String? activityId;
  final String? categorySlug;
  final String? subcategorySlug;
  final String? activitySlug;
  final String? activityCategorySlug;
  final String? activitySubCategorySlug;
  final bool? hasCoordinates;
  final bool? isVerified;
  final String? currentVenueId;
  final String? title;

  const AdvancedDiscoverResultsScreen({
    super.key,
    this.type = 'venues',
    this.scope,
    this.query,
    this.citySlug,
    this.categoryId,
    this.subcategoryId,
    this.activityId,
    this.categorySlug,
    this.subcategorySlug,
    this.activitySlug,
    this.activityCategorySlug,
    this.activitySubCategorySlug,
    this.hasCoordinates,
    this.isVerified,
    this.currentVenueId,
    this.title,
  });

  @override
  ConsumerState<AdvancedDiscoverResultsScreen> createState() =>
      _AdvancedDiscoverResultsScreenState();
}

class _AdvancedDiscoverResultsScreenState
    extends ConsumerState<AdvancedDiscoverResultsScreen> {
  static const _pageSize = 20;

  final _scrollController = ScrollController();
  final _venues = <ApiVenue>[];
  final _events = <ApiEvent>[];
  final _favoriteOverrides = <String, bool>{};
  final _favoriteBusy = <String>{};

  late String? _activityCategorySlug =
      widget.activityCategorySlug ?? widget.categorySlug;
  late String? _activitySubCategorySlug =
      widget.activitySubCategorySlug ?? widget.subcategorySlug;
  late String? _activitySlug = widget.activitySlug;
  late bool? _hasCoordinates = widget.hasCoordinates;
  late bool? _isVerified = widget.isVerified;

  bool _initialLoading = true;
  bool _loadingMore = false;
  bool _needsCity = false;
  Object? _error;
  int _page = 1;
  int _pages = 1;
  int _total = 0;
  int _requestGeneration = 0;

  bool get _isEvents => widget.type == 'events';
  bool get _canLoadMore => !_loadingMore && _page < _pages;

  int get _activeFilterCount {
    return [
      _activityCategorySlug,
      _activitySubCategorySlug,
      _activitySlug,
      _hasCoordinates == true ? 'has_coordinates' : null,
      _isVerified == true ? 'is_verified' : null,
    ].whereType<Object>().length;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    Future.microtask(_loadFirstPage);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.position.extentAfter < 500 && _canLoadMore) {
      _loadNextPage();
    }
  }

  Future<void> _loadFirstPage() async {
    if (!mounted) return;
    final generation = ++_requestGeneration;
    setState(() {
      _initialLoading = true;
      _loadingMore = false;
      _error = null;
      _needsCity = false;
      _page = 1;
      _pages = 1;
      _total = 0;
      _venues.clear();
      _events.clear();
    });
    await _loadPage(1, replace: true, generation: generation);
  }

  Future<void> _refresh() async {
    await _loadFirstPage();
  }

  Future<void> _loadNextPage() async {
    if (!_canLoadMore) return;
    final generation = _requestGeneration;
    setState(() => _loadingMore = true);
    await _loadPage(_page + 1, replace: false, generation: generation);
  }

  bool _isCurrentRequest(int generation) {
    return mounted && generation == _requestGeneration;
  }

  Future<void> _loadPage(
    int page, {
    required bool replace,
    required int generation,
  }) async {
    try {
      final selectedCity = await ref.read(selectedCityProvider.future);
      if (!_isCurrentRequest(generation)) return;
      final citySlug = selectedCity?.slug ?? widget.citySlug;
      if (!_isEvents && widget.scope != null && citySlug == null) {
        setState(() {
          _needsCity = true;
          _initialLoading = false;
          _loadingMore = false;
        });
        return;
      }

      if (_isEvents) {
        final response = await ref
            .read(eventApiServiceProvider)
            .fetchEventsPage(
              page: page,
              pageSize: _pageSize,
              citySlug: citySlug,
              activitySlug: widget.activitySlug,
              q: widget.query,
            );
        if (!_isCurrentRequest(generation)) return;
        setState(() {
          if (replace) _events.clear();
          final seenIds = _events.map((event) => event.id).toSet();
          _events.addAll(
            response.items.where((event) => seenIds.add(event.id)),
          );
          _page = response.page;
          _pages = response.pages;
          _total = response.total;
          _initialLoading = false;
          _loadingMore = false;
        });
        return;
      }

      final response = await _loadVenuePage(page, citySlug);
      if (!_isCurrentRequest(generation)) return;
      setState(() {
        if (replace) _venues.clear();
        final seenIds = _venues.map((venue) => venue.id).toSet();
        _venues.addAll(response.items.where((venue) => seenIds.add(venue.id)));
        _page = response.page;
        _pages = response.pages;
        _total = response.total;
        _initialLoading = false;
        _loadingMore = false;
      });
      if (page == 1) {
        ref
            .read(analyticsApiServiceProvider)
            .track(
              eventName: AnalyticsEventName.activityFilter,
              properties: {
                'source': 'advanced_results',
                if (widget.scope != null) 'scope': widget.scope,
                if (widget.query != null) 'query': widget.query,
                if (_activityCategorySlug != null)
                  'activity_category_slug': _activityCategorySlug,
                if (_activitySubCategorySlug != null)
                  'activity_sub_category_slug': _activitySubCategorySlug,
                if (_activitySlug != null) 'activity_slug': _activitySlug,
                'result_count': response.total,
              },
            );
      }
    } catch (error) {
      if (!_isCurrentRequest(generation)) return;
      setState(() {
        _error = error;
        _initialLoading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _toggleFavorite(ApiVenue venue) async {
    if (_favoriteBusy.contains(venue.id)) return;
    final previous = _favoriteOverrides[venue.id] ?? venue.isFavorite;
    setState(() {
      _favoriteBusy.add(venue.id);
      _favoriteOverrides[venue.id] = !previous;
    });
    try {
      final next = previous
          ? await ref
                .read(venueApiServiceProvider)
                .removeFavoriteVenue(venue.id)
          : await ref.read(venueApiServiceProvider).addFavoriteVenue(venue.id);
      _favoriteOverrides[venue.id] = next;
      ref
        ..invalidate(favoriteVenuesProvider)
        ..invalidate(venuesListProvider);
      ref
          .read(analyticsApiServiceProvider)
          .track(
            eventName: AnalyticsEventName.favorite,
            venueId: venue.id,
            properties: {
              'target_type': 'venue',
              'action': next ? 'add' : 'remove',
              'source': 'advanced_results',
            },
          );
    } catch (error) {
      _favoriteOverrides[venue.id] = previous;
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _favoriteBusy.remove(venue.id));
      }
    }
  }

  Future<ApiPaginatedResponse<ApiVenue>> _loadVenuePage(
    int page,
    String? citySlug,
  ) {
    return ref
        .read(venueApiServiceProvider)
        .fetchVenuesPage(
          page: page,
          pageSize: _pageSize,
          citySlug: citySlug,
          activityCategorySlug: _activityCategorySlug,
          activitySubCategorySlug: _activitySubCategorySlug,
          activitySlug: _activitySlug,
          q: widget.query,
          hasCoordinates: _hasCoordinates,
          isVerified: _isVerified,
        );
  }

  void _openMapView() {
    final citySlug =
        widget.citySlug ?? ref.read(selectedCityProvider).value?.slug;
    final params = <String, String>{
      if (citySlug != null && citySlug.trim().isNotEmpty)
        'citySlug': citySlug.trim(),
      'activityCategorySlug': ?_activityCategorySlug,
      'activitySubCategorySlug': ?_activitySubCategorySlug,
      'activitySlug': ?_activitySlug,
      if (widget.query != null && widget.query!.trim().isNotEmpty)
        'query': widget.query!.trim(),
      if (_isVerified == true) 'isVerified': 'true',
    };
    context.push(Uri(path: '/map', queryParameters: params).toString());
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.title ?? (_isEvents ? 'Etkinlikler' : 'Mekanlar');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (!_isEvents)
            IconButton(
              tooltip: 'Haritada Göster',
              onPressed: _openMapView,
              icon: const Icon(Icons.map_rounded),
            ),
          if (!_isEvents)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: AppFilterButton(
                onPressed: _showFilterSheet,
                activeCount: _activeFilterCount,
                iconOnly: true,
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: BiCikalimTheme.primary,
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_initialLoading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(context.layout.screenPadding),
        children: List.generate(6, (_) => const _ResultSkeletonCard()),
      );
    }

    if (_needsCity) {
      return AppEmptyState(
        icon: Icons.location_city,
        title: 'Şehir seçmelisin',
        message: 'Aktiviteye göre mekan bulmak için şehir seçmelisin.',
        actionLabel: 'Ayarlara Git',
        onAction: () => context.go('/profile'),
      );
    }

    if (_error != null) {
      return AppErrorState(
        error: _error!,
        title: 'Sonuçlar yüklenemedi',
        onRetry: _loadFirstPage,
      );
    }

    final itemCount = _isEvents ? _events.length : _venues.length;
    if (itemCount == 0) {
      return AppEmptyState(
        icon: _isEvents ? Icons.event_busy : Icons.storefront_outlined,
        title: _isEvents
            ? 'Şu anda yayınlanmış bir etkinlik bulunmuyor'
            : 'Bu aktiviteyi sunan bir mekân henüz eklenmemiş',
        message: _isEvents
            ? 'Yine de şehirde yapabileceğin aktiviteleri keşfedebilirsin.'
            : 'Başka bir aktivite seçebilir veya eksik bir mekânı bize önerebilirsin.',
        actionLabel: _activeFilterCount > 0 ? 'Filtreleri Temizle' : null,
        onAction: _activeFilterCount > 0 ? _clearAllFilters : null,
      );
    }

    return ListView.builder(
      key: PageStorageKey('advanced-results-${widget.type}-${widget.title}'),
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        8,
        context.layout.screenPadding,
        context.layout.sectionGap,
      ),
      itemCount: itemCount + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_total sonuç',
                  style: const TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (_activeFilterCount > 0) ...[
                  const SizedBox(height: 10),
                  _buildActiveFilterChips(),
                ],
              ],
            ),
          );
        }
        if (index == itemCount + 1) {
          return _loadingMore
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              : const SizedBox(height: 12);
        }

        final itemIndex = index - 1;
        if (_isEvents) {
          final event = _events[itemIndex];
          return EventListCard(
            event: event,
            onTap: () => context.push('/events/${event.slug}'),
          );
        }

        final venue = _venues[itemIndex];
        final isCurrent =
            widget.currentVenueId != null && widget.currentVenueId == venue.id;
        final isFavorite = _favoriteOverrides[venue.id] ?? venue.isFavorite;
        final isBusy = _favoriteBusy.contains(venue.id);
        return Column(
          children: [
            if (isCurrent)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: BiCikalimTheme.primary.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Şu anda görüntülüyorsun',
                  style: TextStyle(
                    color: BiCikalimTheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Stack(
              children: [
                VenueCard(
                  venue: venue,
                  dense: true,
                  onTap: () => context.push('/venues/${venue.slug}'),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: IconButton.filledTonal(
                    tooltip: isFavorite
                        ? 'Favorilerden çıkar'
                        : 'Favoriye ekle',
                    onPressed: isBusy ? null : () => _toggleFavorite(venue),
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: BiCikalimTheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildActiveFilterChips() {
    final chips = <Widget>[];

    void addChip(String key, String label) {
      chips.add(
        InputChip(
          label: Text(label),
          tooltip: '$label filtresini kaldır',
          onDeleted: () => _removeFilter(key),
          deleteIcon: const Icon(Icons.close_rounded, size: 18),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    if (_activityCategorySlug != null) {
      addChip('category', 'Kategori: $_activityCategorySlug');
    }
    if (_activitySubCategorySlug != null) {
      addChip('subcategory', 'Alt kategori: $_activitySubCategorySlug');
    }
    if (_activitySlug != null) {
      addChip('activity', 'Aktivite: $_activitySlug');
    }
    if (_hasCoordinates == true) {
      addChip('coordinates', 'Konum bilgisi var');
    }
    if (_isVerified == true) {
      addChip('verified', 'Doğrulanmış');
    }

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  void _removeFilter(String key) {
    setState(() {
      if (key == 'category') {
        _activityCategorySlug = null;
        _activitySubCategorySlug = null;
        _activitySlug = null;
      } else if (key == 'subcategory') {
        _activitySubCategorySlug = null;
        _activitySlug = null;
      } else if (key == 'activity') {
        _activitySlug = null;
      } else if (key == 'coordinates') {
        _hasCoordinates = null;
      } else if (key == 'verified') {
        _isVerified = null;
      }
    });
    _loadFirstPage();
  }

  void _clearAllFilters() {
    setState(() {
      _activityCategorySlug = null;
      _activitySubCategorySlug = null;
      _activitySlug = null;
      _hasCoordinates = null;
      _isVerified = null;
    });
    _loadFirstPage();
  }

  Future<void> _showFilterSheet() async {
    var draftCategorySlug = _activityCategorySlug;
    var draftSubcategorySlug = _activitySubCategorySlug;
    var draftActivitySlug = _activitySlug;
    var draftHasCoordinates = _hasCoordinates == true;
    var draftIsVerified = _isVerified == true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFFFFFBF9),
      barrierColor: Colors.black.withValues(alpha: .46),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Consumer(
              builder: (context, ref, _) {
                final categoriesAsync = ref.watch(categoriesProvider);
                final subcategoriesAsync = ref.watch(
                  subcategoriesProvider(draftCategorySlug),
                );
                final activitiesAsync = ref.watch(
                  filteredActivitiesProvider(
                    ActivityFilters(
                      categorySlug: draftCategorySlug,
                      subcategorySlug: draftSubcategorySlug,
                    ),
                  ),
                );

                final hasDraftFilters =
                    draftCategorySlug != null ||
                    draftSubcategorySlug != null ||
                    draftActivitySlug != null ||
                    draftHasCoordinates ||
                    draftIsVerified;

                return AppFilterSheet(
                  clearEnabled: hasDraftFilters,
                  onClear: () => setSheetState(() {
                    draftCategorySlug = null;
                    draftSubcategorySlug = null;
                    draftActivitySlug = null;
                    draftHasCoordinates = false;
                    draftIsVerified = false;
                  }),
                  onApply: () {
                    setState(() {
                      _activityCategorySlug = draftCategorySlug;
                      _activitySubCategorySlug = draftSubcategorySlug;
                      _activitySlug = draftActivitySlug;
                      _hasCoordinates = draftHasCoordinates ? true : null;
                      _isVerified = draftIsVerified ? true : null;
                    });
                    Navigator.pop(sheetContext);
                    _loadFirstPage();
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppFilterGroup(
                        title: 'Aktivite seçimi',
                        subtitle:
                            'Kategori seçtikçe alt seçenekler sana göre yenilenir.',
                        icon: Icons.local_activity_outlined,
                        child: Column(
                          children: [
                            categoriesAsync.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (error, _) => const Text(
                                'Kategoriler yüklenemedi. Tekrar deneyebilirsin.',
                              ),
                              data: (categories) =>
                                  DropdownButtonFormField<String>(
                                    initialValue: draftCategorySlug,
                                    decoration: const InputDecoration(
                                      labelText: 'Aktivite kategorisi',
                                      prefixIcon: Icon(Icons.category_outlined),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Tümü'),
                                      ),
                                      ...categories.map(
                                        (category) => DropdownMenuItem<String>(
                                          value: category.slug,
                                          child: Text(category.name),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setSheetState(() {
                                        draftCategorySlug = value;
                                        draftSubcategorySlug = null;
                                        draftActivitySlug = null;
                                      });
                                    },
                                  ),
                            ),
                            const SizedBox(height: 12),
                            subcategoriesAsync.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (error, _) =>
                                  const Text('Alt kategoriler yüklenemedi.'),
                              data: (subcategories) =>
                                  DropdownButtonFormField<String>(
                                    initialValue: draftSubcategorySlug,
                                    decoration: const InputDecoration(
                                      labelText: 'Alt kategori',
                                      prefixIcon: Icon(
                                        Icons.account_tree_outlined,
                                      ),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Tümü'),
                                      ),
                                      ...subcategories.map(
                                        (subcategory) =>
                                            DropdownMenuItem<String>(
                                              value: subcategory.slug,
                                              child: Text(subcategory.name),
                                            ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setSheetState(() {
                                        draftSubcategorySlug = value;
                                        draftActivitySlug = null;
                                      });
                                    },
                                  ),
                            ),
                            const SizedBox(height: 12),
                            activitiesAsync.when(
                              loading: () => const LinearProgressIndicator(),
                              error: (error, _) =>
                                  const Text('Aktiviteler yüklenemedi.'),
                              data: (activities) =>
                                  DropdownButtonFormField<String>(
                                    initialValue: draftActivitySlug,
                                    decoration: const InputDecoration(
                                      labelText: 'Aktivite',
                                      prefixIcon: Icon(Icons.sports_outlined),
                                    ),
                                    isExpanded: true,
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('Tümü'),
                                      ),
                                      ...activities.map(
                                        (activity) => DropdownMenuItem<String>(
                                          value: activity.slug,
                                          child: Text(activity.name),
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setSheetState(() {
                                        draftActivitySlug = value;
                                      });
                                    },
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AppFilterSectionTitle('Mekan tercihleri'),
                      const SizedBox(height: 8),
                      AppFilterToggleTile(
                        value: draftIsVerified,
                        icon: Icons.verified_outlined,
                        title: 'Doğrulanmış mekanlar',
                        subtitle:
                            'Yalnızca bilgileri onaylanmış mekanları göster.',
                        onChanged: (value) =>
                            setSheetState(() => draftIsVerified = value),
                      ),
                      const SizedBox(height: 10),
                      AppFilterToggleTile(
                        value: draftHasCoordinates,
                        icon: Icons.location_on_outlined,
                        title: 'Konumu belli mekanlar',
                        subtitle:
                            'Haritada görüntülenebilen mekanlarla sınırla.',
                        onChanged: (value) =>
                            setSheetState(() => draftHasCoordinates = value),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ResultSkeletonCard extends StatelessWidget {
  const _ResultSkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }
}

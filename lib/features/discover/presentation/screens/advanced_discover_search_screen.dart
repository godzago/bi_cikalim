import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';

class AdvancedDiscoverSearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;

  const AdvancedDiscoverSearchScreen({super.key, this.initialQuery = ''});

  @override
  ConsumerState<AdvancedDiscoverSearchScreen> createState() =>
      _AdvancedDiscoverSearchScreenState();
}

class _AdvancedDiscoverSearchScreenState
    extends ConsumerState<AdvancedDiscoverSearchScreen> {
  late final TextEditingController _controller;
  final _scrollController = ScrollController();
  Timer? _debounce;
  late String _query;

  String? _categorySlug;
  String? _subcategorySlug;
  String? _activitySlug;
  bool? _hasCoordinates;
  bool? _isVerified;

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery.trim();
    _controller = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    return [
      _categorySlug,
      _subcategorySlug,
      _activitySlug,
      _hasCoordinates == true ? 'has_coordinates' : null,
      _isVerified == true ? 'is_verified' : null,
    ].whereType<Object>().length;
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _query = value.trim());
    });
  }

  Future<void> _refresh(FutureProvider<ApiSearchResult>? provider) async {
    if (provider == null) {
      ref
        ..invalidate(categoriesProvider)
        ..invalidate(activitiesProvider)
        ..invalidate(selectedCityProvider);
      await Future.wait([
        ref.read(categoriesProvider.future),
        ref.read(activitiesProvider.future),
        ref.read(selectedCityProvider.future),
      ]);
      return;
    }
    ref.invalidate(provider);
    await ref.read(provider.future);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCity = ref.watch(selectedCityProvider).value;
    final provider = _query.length < 2
        ? null
        : searchResultsProvider(
            SearchFilters(
              query: _query,
              citySlug: selectedCity?.slug,
              limit: 8,
            ),
          );
    final resultAsync = provider == null ? null : ref.watch(provider);
    final isSearching = resultAsync?.isLoading == true;

    return Scaffold(
      backgroundColor: BiCikalimTheme.background,
      appBar: AppBar(
        title: const Text('Ara'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  tooltip: 'Filtreler',
                  onPressed: _showFilterSheet,
                  icon: const Icon(Icons.tune_rounded),
                ),
                if (_activeFilterCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: const BoxDecoration(
                        color: BiCikalimTheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$_activeFilterCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: BiCikalimTheme.primary,
        onRefresh: () => _refresh(provider),
        child: ListView(
          key: const PageStorageKey('advanced-discover-search-scroll'),
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _SearchInput(
              controller: _controller,
              isSearching: isSearching,
              onChanged: _onChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                setState(() => _query = value.trim());
              },
              onClear: () {
                _controller.clear();
                _debounce?.cancel();
                setState(() => _query = '');
              },
            ),
            if (_activeFilterCount > 0) ...[
              const SizedBox(height: 10),
              _AppliedFilterSummary(
                count: _activeFilterCount,
                onClear: _clearFilters,
                onOpenResults: _openFilteredVenues,
              ),
            ],
            const SizedBox(height: 18),
            if (_query.length < 2)
              _buildStartState()
            else
              resultAsync!.when(
                loading: _SearchSkeleton.new,
                error: (error, _) => AppErrorState(
                  error: error,
                  title: 'Arama yapılamadı',
                  fallbackMessage:
                      'Bağlantını kontrol edip tekrar deneyebilirsin.',
                  onRetry: () => _refresh(provider),
                ),
                data: _buildResults,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartState() {
    final activitiesAsync = ref.watch(activitiesProvider);
    return activitiesAsync.when(
      loading: _SearchSkeleton.new,
      error: (_, _) => const AppEmptyState(
        icon: Icons.search,
        title: 'Aramaya başla',
        message: 'Aktivite, mekan veya etkinlik aramak için yazmaya başla.',
      ),
      data: (activities) {
        if (activities.isEmpty) {
          return const AppEmptyState(
            icon: Icons.search,
            title: 'Aramak için yaz',
            message: 'Aramak için en az iki karakter yaz.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: 'Popüler aktiviteler'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activities.take(10).map((activity) {
                return ActionChip(
                  avatar: Icon(activity.iconData, size: 16),
                  label: Text(activity.name),
                  onPressed: () {
                    _controller.text = activity.name;
                    setState(() => _query = activity.name);
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResults(ApiSearchResult result) {
    if (result.total == 0) {
      return AppEmptyState(
        icon: Icons.search_off,
        title: 'Aramana uygun sonuç bulamadık',
        message:
            'Farklı bir kelime deneyebilir veya filtrelerini genişletebilirsin.',
        actionLabel: _activeFilterCount > 0 ? 'Filtreleri Temizle' : null,
        onAction: _activeFilterCount > 0 ? _clearFilters : null,
        secondaryActionLabel: 'Popüler Aktivitelere Dön',
        onSecondaryAction: () {
          _controller.clear();
          _debounce?.cancel();
          setState(() => _query = '');
        },
      );
    }

    final activities = result.taxonomy
        .where((item) => _taxonomyScope(item) == _TaxonomyScope.activity)
        .toList();
    final categories = result.taxonomy
        .where((item) => _taxonomyScope(item) == _TaxonomyScope.category)
        .toList();
    final subcategories = result.taxonomy
        .where((item) => _taxonomyScope(item) == _TaxonomyScope.subcategory)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (activities.isNotEmpty)
          _ResultSection(
            title: 'Aktiviteler',
            actionLabel: 'Filtreli mekanlar',
            onAction: _openFilteredVenues,
            children: activities
                .map(
                  (item) => _TaxonomyResultCard(
                    item: item,
                    scope: _TaxonomyScope.activity,
                    onTap: () => _openTaxonomy(item),
                  ),
                )
                .toList(),
          ),
        if (result.venues.isNotEmpty)
          _ResultSection(
            title: 'Mekanlar',
            actionLabel: 'Tümünü Gör',
            onAction: _openFilteredVenues,
            children: result.venues
                .map(
                  (venue) => _VenueSearchResultCard(
                    venue: venue,
                    onTap: () => context.push('/venues/${venue.slug}'),
                  ),
                )
                .toList(),
          ),
        if (categories.isNotEmpty)
          _ResultSection(
            title: 'Kategoriler',
            children: categories
                .map(
                  (item) => _TaxonomyResultCard(
                    item: item,
                    scope: _TaxonomyScope.category,
                    onTap: () => _openTaxonomy(item),
                  ),
                )
                .toList(),
          ),
        if (subcategories.isNotEmpty)
          _ResultSection(
            title: 'Alt Kategoriler',
            children: subcategories
                .map(
                  (item) => _TaxonomyResultCard(
                    item: item,
                    scope: _TaxonomyScope.subcategory,
                    onTap: () => _openTaxonomy(item),
                  ),
                )
                .toList(),
          ),
        if (result.events.isNotEmpty)
          _ResultSection(
            title: 'Etkinlikler',
            actionLabel: 'Tümünü Gör',
            onAction: () => _openEvents(),
            children: result.events
                .map(
                  (event) => _EventSearchResultCard(
                    event: event,
                    onTap: () => context.push('/events/${event.slug}'),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  void _openTaxonomy(ApiSearchTaxonomyItem item) {
    final scope = _taxonomyScope(item);
    final key = switch (scope) {
      _TaxonomyScope.category => 'categorySlug',
      _TaxonomyScope.subcategory => 'subcategorySlug',
      _TaxonomyScope.activity => 'activitySlug',
    };
    final scopeValue = switch (scope) {
      _TaxonomyScope.category => 'category',
      _TaxonomyScope.subcategory => 'subcategory',
      _TaxonomyScope.activity => 'activity',
    };
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {
          'scope': scopeValue,
          key: item.slug,
          'title': scope == _TaxonomyScope.activity
              ? '${item.name} Yapabileceğin Mekanlar'
              : item.name,
          if (_query.isNotEmpty) 'query': _query,
        },
      ).toString(),
    );
  }

  void _openFilteredVenues() {
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {
          'type': 'venues',
          if (_query.isNotEmpty) 'query': _query,
          'activityCategorySlug': ?_categorySlug,
          'activitySubCategorySlug': ?_subcategorySlug,
          'activitySlug': ?_activitySlug,
          if (_hasCoordinates == true) 'hasCoordinates': 'true',
          if (_isVerified == true) 'isVerified': 'true',
          'title': _query.isEmpty ? 'Mekanlar' : '$_query mekanları',
        },
      ).toString(),
    );
  }

  void _openEvents() {
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {
          'type': 'events',
          if (_query.isNotEmpty) 'query': _query,
          'activitySlug': ?_activitySlug,
          'title': _query.isEmpty ? 'Etkinlikler' : '$_query etkinlikleri',
        },
      ).toString(),
    );
  }

  void _clearFilters() {
    setState(() {
      _categorySlug = null;
      _subcategorySlug = null;
      _activitySlug = null;
      _hasCoordinates = null;
      _isVerified = null;
    });
  }

  Future<void> _showFilterSheet() async {
    var draftCategorySlug = _categorySlug;
    var draftSubcategorySlug = _subcategorySlug;
    var draftActivitySlug = _activitySlug;
    var draftHasCoordinates = _hasCoordinates == true;
    var draftIsVerified = _isVerified == true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
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

                return SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Filtreler',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          categoriesAsync.when(
                            loading: () => const LinearProgressIndicator(),
                            error: (error, _) =>
                                Text('Kategoriler yüklenemedi: $error'),
                            data: (categories) =>
                                DropdownButtonFormField<String>(
                                  initialValue: draftCategorySlug,
                                  decoration: const InputDecoration(
                                    labelText: 'Aktivite kategorisi',
                                  ),
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
                                Text('Alt kategoriler yüklenemedi: $error'),
                            data: (subcategories) =>
                                DropdownButtonFormField<String>(
                                  initialValue: draftSubcategorySlug,
                                  decoration: const InputDecoration(
                                    labelText: 'Alt kategori',
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Tümü'),
                                    ),
                                    ...subcategories.map(
                                      (subcategory) => DropdownMenuItem<String>(
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
                                Text('Aktiviteler yüklenemedi: $error'),
                            data: (activities) =>
                                DropdownButtonFormField<String>(
                                  initialValue: draftActivitySlug,
                                  decoration: const InputDecoration(
                                    labelText: 'Aktivite',
                                  ),
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
                          const SizedBox(height: 12),
                          SwitchListTile(
                            value: draftIsVerified,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Doğrulanmış mekanlar'),
                            onChanged: (value) =>
                                setSheetState(() => draftIsVerified = value),
                          ),
                          SwitchListTile(
                            value: draftHasCoordinates,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Konum bilgisi bulunanlar'),
                            onChanged: (value) => setSheetState(
                              () => draftHasCoordinates = value,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    setSheetState(() {
                                      draftCategorySlug = null;
                                      draftSubcategorySlug = null;
                                      draftActivitySlug = null;
                                      draftHasCoordinates = false;
                                      draftIsVerified = false;
                                    });
                                  },
                                  child: const Text('Tümünü Temizle'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () {
                                    setState(() {
                                      _categorySlug = draftCategorySlug;
                                      _subcategorySlug = draftSubcategorySlug;
                                      _activitySlug = draftActivitySlug;
                                      _hasCoordinates = draftHasCoordinates
                                          ? true
                                          : null;
                                      _isVerified = draftIsVerified
                                          ? true
                                          : null;
                                    });
                                    Navigator.pop(sheetContext);
                                  },
                                  child: const Text('Filtreleri Uygula'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

enum _TaxonomyScope { activity, category, subcategory }

_TaxonomyScope _taxonomyScope(ApiSearchTaxonomyItem item) {
  final type = item.type.toLowerCase();
  if (type == 'category' || type == 'activity_category') {
    return _TaxonomyScope.category;
  }
  if (type == 'sub_category' ||
      type == 'subcategory' ||
      type == 'activity_sub_category') {
    return _TaxonomyScope.subcategory;
  }
  return _TaxonomyScope.activity;
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchInput({
    required this.controller,
    required this.isSearching,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: BiCikalimTheme.primary.withValues(alpha: .08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            autofocus: true,
            autocorrect: false,
            textInputAction: TextInputAction.search,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              labelText: 'Arama',
              hintText: 'Aktivite, mekan veya etkinlik ara',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Temizle',
                      onPressed: onClear,
                      icon: const Icon(Icons.clear_rounded),
                    ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: isSearching ? 2 : 0,
            child: const LinearProgressIndicator(
              color: BiCikalimTheme.primary,
              minHeight: 2,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppliedFilterSummary extends StatelessWidget {
  final int count;
  final VoidCallback onClear;
  final VoidCallback onOpenResults;

  const _AppliedFilterSummary({
    required this.count,
    required this.onClear,
    required this.onOpenResults,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: BiCikalimTheme.primary.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '$count filtre seçili',
              style: const TextStyle(
                color: BiCikalimTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onClear, child: const Text('Temizle')),
          TextButton(onPressed: onOpenResults, child: const Text('Mekanlar')),
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget> children;

  const _ResultSection({
    required this.title,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: title,
            actionLabel: actionLabel,
            onAction: onAction,
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _TaxonomyResultCard extends StatelessWidget {
  final ApiSearchTaxonomyItem item;
  final _TaxonomyScope scope;
  final VoidCallback onTap;

  const _TaxonomyResultCard({
    required this.item,
    required this.scope,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = switch (scope) {
      _TaxonomyScope.activity => Icons.sports_esports_rounded,
      _TaxonomyScope.category => Icons.category_rounded,
      _TaxonomyScope.subcategory => Icons.local_activity_rounded,
    };
    final subtitle = switch (scope) {
      _TaxonomyScope.activity => 'Nerede yapabilirim?',
      _TaxonomyScope.category => 'Kategori kapsamındaki mekanları gör',
      _TaxonomyScope.subcategory => 'Alt kategori kapsamındaki mekanları gör',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: BiCikalimTheme.primary.withValues(alpha: .09),
          child: Icon(icon, color: BiCikalimTheme.primary),
        ),
        title: Text(
          item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _VenueSearchResultCard extends StatelessWidget {
  final ApiSearchVenueItem venue;
  final VoidCallback onTap;

  const _VenueSearchResultCard({required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
        title: Text(
          venue.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          venue.shortDescription ?? venue.city.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _EventSearchResultCard extends StatelessWidget {
  final ApiSearchEventItem event;
  final VoidCallback onTap;

  const _EventSearchResultCard({required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: .06),
          child: const Icon(Icons.event_outlined),
        ),
        title: Text(
          event.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(event.city.name),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

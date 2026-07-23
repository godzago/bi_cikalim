import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/venue_card.dart';

class DiscoverResultsScreen extends ConsumerStatefulWidget {
  final String? query;
  final String? categoryId;
  final String? subcategoryId;
  final String? activityId;
  final String? title;

  const DiscoverResultsScreen({
    super.key,
    this.query,
    this.categoryId,
    this.subcategoryId,
    this.activityId,
    this.title,
  });

  @override
  ConsumerState<DiscoverResultsScreen> createState() => _DiscoverResultsScreenState();
}

class _DiscoverResultsScreenState extends ConsumerState<DiscoverResultsScreen> {
  String? _selectedSubcategoryId;

  bool _showsCategoryFilters(List<ApiSubcategory> subcategories) =>
      widget.activityId == null &&
      widget.categoryId != null &&
      subcategories.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedSubcategoryId = widget.subcategoryId;
  }

  List<ApiActivity> _resolveActivities(List<ApiActivity> activities) {
    if (widget.activityId != null) {
      return activities.where((a) => a.id == widget.activityId).toList();
    }
    if (_selectedSubcategoryId != null) {
      return activities.where((a) => a.subcategoryId == _selectedSubcategoryId).toList();
    }
    if (widget.subcategoryId != null) {
      return activities.where((a) => a.subcategoryId == widget.subcategoryId).toList();
    }
    if (widget.categoryId != null) {
      return activities.where((a) => a.categoryId == widget.categoryId).toList();
    }
    if (widget.query != null && widget.query!.isNotEmpty) {
      return activities.where((a) => a.name.toLowerCase().contains(widget.query!.toLowerCase())).toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = _resolveTitle();

    final venuesAsync = ref.watch(venuesListProvider(VenueFilters(
      q: widget.query,
      activityCategorySlug: widget.categoryId,
      activitySlug: widget.activityId,
    )));

    final activitiesAsync = ref.watch(activitiesProvider);

    // Filter subcategories using local MockDatabase for category
    final availableSubcategories = widget.categoryId != null
        ? MockDatabase.getSubcategoriesForCategory(widget.categoryId!)
        : <ActivitySubcategory>[];

    return Scaffold(
      appBar: AppBar(title: Text(resolvedTitle)),
      body: venuesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: BiCikalimTheme.primary)),
        error: (err, _) => Center(child: Text('Arama sonuçları yüklenemedi: $err')),
        data: (venues) {
          // Apply local subcategory filter if selected
          var matchedVenues = venues;
          if (_selectedSubcategoryId != null) {
            matchedVenues = venues.where((v) => v.activityTags.any((t) => t.toLowerCase() == _selectedSubcategoryId!.toLowerCase())).toList();
          }

          return activitiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: BiCikalimTheme.primary)),
            error: (err, _) => Center(child: Text('Aktiviteler yüklenemedi: $err')),
            data: (allActivities) {
              final matchedActivities = _resolveActivities(allActivities);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Text(
                    '${matchedVenues.length} mekan - ${matchedActivities.length} aktivite',
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_showsCategoryFilters(availableSubcategories.map((sc) => ApiSubcategory(id: sc.id, categoryId: sc.categoryId, name: sc.name, slug: sc.id)).toList())) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 38,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _SubcategoryChip(
                            label: 'Tüm alt kategoriler',
                            isSelected: _selectedSubcategoryId == null,
                            onTap: () {
                              setState(() {
                                _selectedSubcategoryId = null;
                              });
                            },
                          ),
                          ...availableSubcategories.map((subcategory) {
                            final venueCount = MockDatabase.getVenuesForSubcategory(
                              subcategory.id,
                            ).length;
                            return _SubcategoryChip(
                              label: '${subcategory.name} ($venueCount)',
                              isSelected: _selectedSubcategoryId == subcategory.id,
                              onTap: () {
                                setState(() {
                                  _selectedSubcategoryId = subcategory.id;
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const _SectionTitle(title: 'Mekanlar'),
                  const SizedBox(height: 12),
                  if (matchedVenues.isEmpty)
                    const AppEmptyState(
                      icon: Icons.travel_explore,
                      message: 'Bu filtreye uygun mekan bulunamadı.',
                    )
                  else
                    ...matchedVenues.map((venue) {
                      return VenueCard(
                        venue: venue,
                        dense: true,
                        onTap: () => context.push('/venues/${venue.slug}'),
                      );
                    }),
                  if (matchedActivities.isNotEmpty && widget.activityId == null) ...[
                    const SizedBox(height: 18),
                    const _SectionTitle(title: 'İlgili Aktiviteler'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 124,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: matchedActivities.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final activity = matchedActivities[index];
                          final subcategory = MockDatabase.getSubcategoryById(
                            activity.subcategoryId,
                          );
                          return _ActivityRailCard(
                            activity: activity,
                            subtitle: subcategory?.name ?? 'Genel aktivite',
                            venueCount: MockDatabase.getVenuesForActivity(
                              activity.id,
                            ).length,
                            onTap: () => _openActivity(context, activity),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _resolveTitle() {
    if (widget.title != null && widget.title!.isNotEmpty) {
      return widget.title!;
    }
    if (widget.activityId != null) {
      return MockDatabase.getActivityById(widget.activityId!).name;
    }
    if (widget.categoryId != null) {
      return MockDatabase.getCategoryById(widget.categoryId!).name;
    }
    if (widget.subcategoryId != null) {
      return MockDatabase.getSubcategoryById(widget.subcategoryId!)?.name ??
          'Alt Kategori';
    }
    if (widget.query != null && widget.query!.isNotEmpty) {
      return '"${widget.query}" araması';
    }
    return 'Keşif Sonuçları';
  }

  void _openActivity(BuildContext context, ApiActivity activity) {
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {'activityId': activity.id, 'title': activity.name},
      ).toString(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SubcategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SubcategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? BiCikalimTheme.primary
                : BiCikalimTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? Colors.white : BiCikalimTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityRailCard extends StatelessWidget {
  final ApiActivity activity;
  final String subtitle;
  final int venueCount;
  final VoidCallback onTap;

  const _ActivityRailCard({
    required this.activity,
    required this.subtitle,
    required this.venueCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 184,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                activity.iconData,
                color: BiCikalimTheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              activity.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: BiCikalimTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: BiCikalimTheme.textSecondary,
              ),
            ),
            const Spacer(),
            Text(
              '$venueCount mekanda var',
              style: const TextStyle(
                color: BiCikalimTheme.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

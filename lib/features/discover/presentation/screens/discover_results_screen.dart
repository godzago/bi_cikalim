import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/venue_card.dart';

class DiscoverResultsScreen extends StatefulWidget {
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
  State<DiscoverResultsScreen> createState() => _DiscoverResultsScreenState();
}

class _DiscoverResultsScreenState extends State<DiscoverResultsScreen> {
  String? _selectedSubcategoryId;

  bool get _showsCategoryFilters =>
      widget.activityId == null &&
      widget.categoryId != null &&
      _resolveSubcategories().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _selectedSubcategoryId = widget.subcategoryId;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = _resolveTitle();
    final matchedCategories = widget.query == null || widget.query!.isEmpty
        ? <ActivityCategory>[]
        : MockDatabase.searchCategories(widget.query!);
    final availableSubcategories = _resolveSubcategories();
    final matchedActivities = _resolveActivities();
    final matchedVenues = _resolveVenues();

    return Scaffold(
      appBar: AppBar(title: Text(resolvedTitle)),
      body: ListView(
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
          if (_showsCategoryFilters) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _SubcategoryChip(
                    label: 'Tum alt kategoriler',
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
          if (matchedCategories.isNotEmpty) ...[
            const SizedBox(height: 16),
            const _SectionTitle(title: 'Eslesen Kategoriler'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: matchedCategories.map((category) {
                return _FilterPill(
                  label: category.name,
                  onTap: () => _openCategory(context, category),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 18),
          const _SectionTitle(title: 'Mekanlar'),
          const SizedBox(height: 12),
          if (matchedVenues.isEmpty)
            const AppEmptyState(
              icon: Icons.travel_explore,
              message: 'Bu filtreye uygun mekan bulunamadi.',
            )
          else
            ...matchedVenues.map((venue) {
              return VenueCard(
                venue: venue,
                dense: true,
                onTap: () => context.push('/venues/${venue.id}'),
              );
            }),
          if (matchedActivities.isNotEmpty && widget.activityId == null) ...[
            const SizedBox(height: 18),
            const _SectionTitle(title: 'Ilgili Aktiviteler'),
            const SizedBox(height: 10),
            SizedBox(
              height: 112,
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
      return '"${widget.query}" aramasi';
    }
    return 'Kesif Sonuclari';
  }

  List<ActivitySubcategory> _resolveSubcategories() {
    if (widget.categoryId != null) {
      return MockDatabase.getSubcategoriesForCategory(widget.categoryId!);
    }
    return [];
  }

  List<Activity> _resolveActivities() {
    if (widget.activityId != null) {
      return [MockDatabase.getActivityById(widget.activityId!)];
    }
    if (_selectedSubcategoryId != null) {
      return MockDatabase.getActivitiesForSubcategory(_selectedSubcategoryId!);
    }
    if (widget.subcategoryId != null) {
      return MockDatabase.getActivitiesForSubcategory(widget.subcategoryId!);
    }
    if (widget.categoryId != null) {
      return MockDatabase.getActivitiesForCategory(widget.categoryId!);
    }
    if (widget.query != null && widget.query!.isNotEmpty) {
      return MockDatabase.searchActivities(widget.query!);
    }
    return [];
  }

  List<Venue> _resolveVenues() {
    if (widget.activityId != null) {
      return MockDatabase.getVenuesForActivity(widget.activityId!);
    }
    if (_selectedSubcategoryId != null) {
      return MockDatabase.getVenuesForSubcategory(_selectedSubcategoryId!);
    }
    if (widget.subcategoryId != null) {
      return MockDatabase.getVenuesForSubcategory(widget.subcategoryId!);
    }
    if (widget.categoryId != null) {
      return MockDatabase.getVenuesForCategory(widget.categoryId!);
    }
    if (widget.query != null && widget.query!.isNotEmpty) {
      return MockDatabase.searchVenues(widget.query!);
    }
    return MockDatabase.venues;
  }

  void _openCategory(BuildContext context, ActivityCategory category) {
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {'categoryId': category.id, 'title': category.name},
      ).toString(),
    );
  }

  void _openActivity(BuildContext context, Activity activity) {
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
        fontFamily: 'Outfit',
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FilterPill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: BiCikalimTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: BiCikalimTheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
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
  final Activity activity;
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
                activity.icon,
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

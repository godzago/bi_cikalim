import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/venue_card.dart';

class DiscoverResultsScreen extends StatelessWidget {
  final String? query;
  final String? categoryId;
  final String? activityId;
  final String? title;

  const DiscoverResultsScreen({
    super.key,
    this.query,
    this.categoryId,
    this.activityId,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = _resolveTitle();
    final matchedCategories = query == null || query!.isEmpty
        ? <ActivityCategory>[]
        : MockDatabase.searchCategories(query!);
    final matchedActivities = _resolveActivities();
    final matchedVenues = _resolveVenues();

    return Scaffold(
      appBar: AppBar(title: Text(resolvedTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(
            '${matchedVenues.length} mekan · ${matchedActivities.length} aktivite',
            style: const TextStyle(
              color: BiCikalimTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (matchedCategories.isNotEmpty) ...[
            const _SectionTitle(title: 'Eslesen Kategoriler'),
            const SizedBox(height: 12),
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
            const SizedBox(height: 24),
          ],
          if (matchedActivities.isNotEmpty) ...[
            const _SectionTitle(title: 'Aktivite Envanteri'),
            const SizedBox(height: 12),
            ...matchedActivities.map((activity) {
              final subcategory = MockDatabase.getSubcategoryById(
                activity.subcategoryId,
              );
              final venueCount = MockDatabase.getVenuesForActivity(
                activity.id,
              ).length;

              return _ActivityListTile(
                activity: activity,
                subtitle: subcategory?.name ?? 'Genel aktivite',
                trailingText: '$venueCount mekan',
                onTap: () => _openActivity(context, activity),
              );
            }),
            const SizedBox(height: 24),
          ],
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
        ],
      ),
    );
  }

  String _resolveTitle() {
    if (title != null && title!.isNotEmpty) {
      return title!;
    }
    if (activityId != null) {
      return MockDatabase.getActivityById(activityId!).name;
    }
    if (categoryId != null) {
      return MockDatabase.getCategoryById(categoryId!).name;
    }
    if (query != null && query!.isNotEmpty) {
      return '"$query" aramasi';
    }
    return 'Kesif Sonuclari';
  }

  List<Activity> _resolveActivities() {
    if (activityId != null) {
      return [MockDatabase.getActivityById(activityId!)];
    }
    if (categoryId != null) {
      return MockDatabase.getActivitiesForCategory(categoryId!);
    }
    if (query != null && query!.isNotEmpty) {
      return MockDatabase.searchActivities(query!);
    }
    return [];
  }

  List<Venue> _resolveVenues() {
    if (activityId != null) {
      return MockDatabase.getVenuesForActivity(activityId!);
    }
    if (categoryId != null) {
      return MockDatabase.getVenuesForCategory(categoryId!);
    }
    if (query != null && query!.isNotEmpty) {
      return MockDatabase.searchVenues(query!);
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

class _ActivityListTile extends StatelessWidget {
  final Activity activity;
  final String subtitle;
  final String trailingText;
  final VoidCallback onTap;

  const _ActivityListTile({
    required this.activity,
    required this.subtitle,
    required this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
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
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: BiCikalimTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: BiCikalimTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                trailingText,
                style: const TextStyle(
                  color: BiCikalimTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

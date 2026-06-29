import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';

/// Aktivite bazlı keşif listesi.
/// Kullanıcı aktiviteyi seçer → o aktiviteyi sunan mekanları görür.
class ActivityListTab extends StatefulWidget {
  const ActivityListTab({super.key});

  @override
  State<ActivityListTab> createState() => _ActivityListTabState();
}

class _ActivityListTabState extends State<ActivityListTab> {
  String? _selectedCategoryId;

  List<ActivityCategory> get _categories => MockDatabase.categories;

  List<Activity> get _filteredActivities {
    if (_selectedCategoryId == null) {
      return MockDatabase.activities;
    }
    return MockDatabase.activities
        .where((a) => a.categoryId == _selectedCategoryId)
        .toList();
  }

  int _venueCountFor(String activityId) {
    return MockDatabase.venueActivities
        .where((va) => va.activityId == activityId)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori filtre bar
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFilterChip('Tümü', null);
              }
              final cat = _categories[index - 1];
              return _buildFilterChip(cat.name, cat.id);
            },
          ),
        ),
        const SizedBox(height: 8),

        // Aktivite listesi
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            itemCount: _filteredActivities.length,
            separatorBuilder: (context, i) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final activity = _filteredActivities[index];
              final venueCount = _venueCountFor(activity.id);
              final category = MockDatabase.getCategoryById(activity.categoryId);

              return _ActivityItemCard(
                activity: activity,
                category: category,
                venueCount: venueCount,
                onTap: () {
                  context.push(
                    Uri(
                      path: '/discover/results',
                      queryParameters: {
                        'activityId': activity.id,
                        'title': activity.name,
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

  Widget _buildFilterChip(String label, String? categoryId) {
    final isSelected = _selectedCategoryId == categoryId;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = categoryId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? BiCikalimTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? BiCikalimTheme.primary : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : BiCikalimTheme.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aktivite Item Kartı
// ---------------------------------------------------------------------------

class _ActivityItemCard extends StatelessWidget {
  final Activity activity;
  final ActivityCategory category;
  final int venueCount;
  final VoidCallback onTap;

  const _ActivityItemCard({
    required this.activity,
    required this.category,
    required this.venueCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // İkon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                activity.icon,
                color: BiCikalimTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // İçerik
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
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        category.icon,
                        size: 11,
                        color: BiCikalimTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 11,
                          color: BiCikalimTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('·',
                          style: TextStyle(color: BiCikalimTheme.textLight)),
                      const SizedBox(width: 8),
                      Text(
                        '${activity.minPeople}–${activity.maxPeople} kişi',
                        style: const TextStyle(
                          fontSize: 11,
                          color: BiCikalimTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mekan sayısı badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: venueCount > 0
                        ? BiCikalimTheme.primary.withValues(alpha: 0.08)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    venueCount > 0 ? '$venueCount mekan' : 'Yakında',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: venueCount > 0
                          ? BiCikalimTheme.primary
                          : BiCikalimTheme.textLight,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: BiCikalimTheme.textLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

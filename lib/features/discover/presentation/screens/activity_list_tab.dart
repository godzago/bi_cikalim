import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';

/// Aktivite bazlı keşif listesi.
/// Kullanıcı aktiviteyi seçer → o aktiviteyi sunan mekanları görür.
class ActivityListTab extends ConsumerStatefulWidget {
  const ActivityListTab({super.key});

  @override
  ConsumerState<ActivityListTab> createState() => _ActivityListTabState();
}

class _ActivityListTabState extends ConsumerState<ActivityListTab> {
  String? _selectedCategoryId;

  Future<void> _refreshActivities() async {
    ref
      ..invalidate(categoriesProvider)
      ..invalidate(activitiesProvider);
    await Future.wait([
      ref.read(categoriesProvider.future),
      ref.read(activitiesProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final activitiesAsync = ref.watch(activitiesProvider);

    return categoriesAsync.when(
      loading: () => AppRefreshableContent(
        onRefresh: _refreshActivities,
        child: const Center(
          child: CircularProgressIndicator(color: BiCikalimTheme.primary),
        ),
      ),
      error: (error, _) => AppRefreshableContent(
        onRefresh: _refreshActivities,
        child: Center(child: Text('Hata: $error')),
      ),
      data: (categories) {
        return activitiesAsync.when(
          loading: () => AppRefreshableContent(
            onRefresh: _refreshActivities,
            child: const Center(
              child: CircularProgressIndicator(color: BiCikalimTheme.primary),
            ),
          ),
          error: (error, _) => AppRefreshableContent(
            onRefresh: _refreshActivities,
            child: Center(child: Text('Hata: $error')),
          ),
          data: (activities) {
            final filteredActivities = _selectedCategoryId == null
                ? activities
                : activities
                      .where((a) => a.categoryId == _selectedCategoryId)
                      .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kategori filtre bar
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildFilterChip('Tümü', null);
                      }
                      final cat = categories[index - 1];
                      return _buildFilterChip(cat.name, cat.id);
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Aktivite listesi
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: const Offset(0.02, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: filteredActivities.isEmpty
                        ? AppEmptyState(
                            key: ValueKey('empty-$_selectedCategoryId'),
                            icon: Icons.local_activity_outlined,
                            message: _selectedCategoryId == null
                                ? 'Henüz aktivite bulunmuyor.'
                                : 'Bu kategoride aktivite bulunmuyor.',
                          )
                        : ListView.separated(
                            key: ValueKey(_selectedCategoryId),
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                            itemCount: filteredActivities.length,
                            separatorBuilder: (context, i) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final activity = filteredActivities[index];
                              ApiCategory? category;
                              for (final candidate in categories) {
                                if (candidate.id == activity.categoryId) {
                                  category = candidate;
                                  break;
                                }
                              }

                              return ActivityItemCard(
                                activity: activity,
                                category: category,
                                onTap: () {
                                  context.push(
                                    Uri(
                                      path: '/discover/results',
                                      queryParameters: {
                                        'activitySlug': activity.slug,
                                        'title': activity.name,
                                      },
                                    ).toString(),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? categoryId) {
    final isSelected = _selectedCategoryId == categoryId;

    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = categoryId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
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

class ActivityItemCard extends StatelessWidget {
  final ApiActivity activity;
  final ApiCategory? category;
  final VoidCallback onTap;

  const ActivityItemCard({
    super.key,
    required this.activity,
    required this.category,
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
                activity.iconData,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: BiCikalimTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (category != null) ...[
                        Icon(
                          category!.icon,
                          size: 11,
                          color: BiCikalimTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          [
                            if (category != null) category!.name,
                            activity.minPeople != null &&
                                    activity.maxPeople != null
                                ? '${activity.minPeople}–${activity.maxPeople} kişi'
                                : activity.minPeople != null
                                ? '${activity.minPeople}+ kişi'
                                : 'Katılımcı bilgisi yok',
                          ].join('  ·  '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: BiCikalimTheme.textSecondary,
                          ),
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
                  constraints: const BoxConstraints(maxWidth: 96),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Mekanları gör',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: BiCikalimTheme.primary,
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

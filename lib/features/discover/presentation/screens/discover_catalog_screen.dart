import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';

class DiscoverCatalogScreen extends StatelessWidget {
  const DiscoverCatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tum Kategoriler')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const Text(
            'Kategori, alt kategori ve aktivite bazli bir kesif duzeni. Buradan daha detayli listelemelere gecilebilir.',
            style: TextStyle(
              color: BiCikalimTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ...MockDatabase.categories.map((category) {
            final activities = MockDatabase.getActivitiesForCategory(
              category.id,
            );
            final subcategories = MockDatabase.getSubcategoriesForCategory(
              category.id,
            );
            final venues = MockDatabase.getVenuesForCategory(category.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: Colors.grey.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => context.push(
                        Uri(
                          path: '/discover/results',
                          queryParameters: {
                            'categoryId': category.id,
                            'title': category.name,
                          },
                        ).toString(),
                      ),
                      borderRadius: BorderRadius.circular(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: BiCikalimTheme.primary.withValues(
                                alpha: 0.08,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category.icon,
                              color: BiCikalimTheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${venues.length} mekan · ${subcategories.length} alt kategori · ${activities.length} aktivite',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: BiCikalimTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subcategories.map((subcategory) {
                        final venueCount = MockDatabase.getVenuesForSubcategory(
                          subcategory.id,
                        ).length;
                        return InkWell(
                          onTap: () => context.push(
                            Uri(
                              path: '/discover/results',
                              queryParameters: {
                                'categoryId': category.id,
                                'subcategoryId': subcategory.id,
                                'title': subcategory.name,
                              },
                            ).toString(),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${subcategory.name} ($venueCount)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: BiCikalimTheme.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: activities.take(4).map((activity) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: BiCikalimTheme.primary.withValues(
                              alpha: 0.08,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            activity.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: BiCikalimTheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

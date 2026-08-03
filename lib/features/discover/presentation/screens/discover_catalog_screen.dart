import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';

class DiscoverCatalogScreen extends ConsumerWidget {
  const DiscoverCatalogScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(categoriesProvider)
      ..invalidate(subcategoriesProvider);
    await ref.read(categoriesProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Tüm Kategoriler')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: categoriesAsync.when(
          loading: () => AppRefreshableContent(
            key: const ValueKey('categories-loading'),
            onRefresh: () => _refresh(ref),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => AppRefreshableContent(
            key: const ValueKey('categories-error'),
            onRefresh: () => _refresh(ref),
            child: AppEmptyState(
              icon: Icons.cloud_off,
              message: 'Kategoriler yüklenemedi.\n$error',
            ),
          ),
          data: (categories) => RefreshIndicator(
            key: const ValueKey('categories-content'),
            color: BiCikalimTheme.primary,
            onRefresh: () => _refresh(ref),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                context.layout.screenPadding,
                8,
                context.layout.screenPadding,
                context.layout.sectionGap,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Card(
                  margin: EdgeInsets.only(bottom: context.layout.cardGap),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(
                      horizontal: context.layout.cardPadding,
                    ),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: BiCikalimTheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      child: Icon(
                        category.iconData,
                        color: BiCikalimTheme.primary,
                      ),
                    ),
                    title: Text(
                      category.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: category.description == null
                        ? null
                        : Text(
                            category.description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    children: [
                      ListTile(
                        leading: const Icon(Icons.storefront_outlined),
                        title: const Text('Bu kategorideki tüm mekanlar'),
                        onTap: () => _openResults(
                          context,
                          'categorySlug',
                          category.slug,
                          category.name,
                        ),
                      ),
                      _Subcategories(category: category),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  static void _openResults(
    BuildContext context,
    String key,
    String slug,
    String title,
  ) {
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {key: slug, 'title': title},
      ).toString(),
    );
  }
}

class _Subcategories extends ConsumerWidget {
  final ApiCategory category;

  const _Subcategories({required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(subcategoriesProvider(category.slug));
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      child: asyncValue.when(
        loading: () => const Padding(
          key: ValueKey('subcategories-loading'),
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
        error: (_, _) => const ListTile(
          key: ValueKey('subcategories-error'),
          title: Text('Alt kategoriler yüklenemedi'),
        ),
        data: (items) => Column(
          key: const ValueKey('subcategories-content'),
          children: items
              .map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.only(
                    left: context.layout.isCompact ? 48 : 56,
                    right: context.layout.cardPadding,
                  ),
                  title: Text(item.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => DiscoverCatalogScreen._openResults(
                    context,
                    'subcategorySlug',
                    item.slug,
                    item.name,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

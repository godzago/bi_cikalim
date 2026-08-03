import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';

class CitySelectScreen extends ConsumerStatefulWidget {
  const CitySelectScreen({super.key});

  @override
  ConsumerState<CitySelectScreen> createState() => _CitySelectScreenState();
}

class _CitySelectScreenState extends ConsumerState<CitySelectScreen> {
  String? _savingCityId;

  Future<void> _refreshCities() async {
    ref.invalidate(citiesProvider);
    await ref.read(citiesProvider.future);
  }

  Future<void> _selectCity(ApiCity city) async {
    if (!city.hasContent || _savingCityId != null) return;
    setState(() => _savingCityId = city.id);
    try {
      await ref.read(selectedCityProvider.notifier).select(city);
      ref.invalidate(venuesListProvider);
      ref.invalidate(eventsListProvider);
      if (mounted) context.go(AppConstants.discoverRoute);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Şehir kaydedilemedi: $error')));
      }
    } finally {
      if (mounted) setState(() => _savingCityId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Şehrini Seç')),
      body: citiesAsync.when(
        loading: () => AppRefreshableContent(
          onRefresh: _refreshCities,
          child: const Center(
            child: CircularProgressIndicator(color: BiCikalimTheme.primary),
          ),
        ),
        error: (error, _) => AppRefreshableContent(
          onRefresh: _refreshCities,
          child: AppEmptyState(
            icon: Icons.cloud_off,
            message: 'Şehirler yüklenemedi.\n$error',
            actionLabel: 'Tekrar Dene',
            onAction: () => ref.invalidate(citiesProvider),
          ),
        ),
        data: (cities) {
          if (cities.isEmpty) {
            return AppRefreshableContent(
              onRefresh: _refreshCities,
              child: const AppEmptyState(
                icon: Icons.location_city_outlined,
                message: 'Henüz kullanılabilir şehir bulunmuyor.',
              ),
            );
          }
          return RefreshIndicator(
            color: BiCikalimTheme.primary,
            onRefresh: _refreshCities,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(context.layout.screenPadding),
              children: [
                Text(
                  'Mekanları, aktiviteleri ve etkinlikleri seçtiğin şehre göre göstereceğiz.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: context.layout.sectionGap),
                ...cities.map(_buildCityCard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCityCard(ApiCity city) {
    final isSaving = _savingCityId == city.id;
    final layout = context.layout;
    return Card(
      margin: EdgeInsets.only(bottom: layout.cardGap),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        enabled: city.hasContent && _savingCityId == null,
        onTap: () => _selectCity(city),
        minTileHeight: AppLayout.minTouchTarget,
        contentPadding: EdgeInsets.symmetric(
          horizontal: layout.cardPadding,
          vertical: 6,
        ),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: BiCikalimTheme.primary.withValues(alpha: 0.1),
          child: const Icon(
            Icons.location_on_outlined,
            color: BiCikalimTheme.primary,
          ),
        ),
        title: Text(
          city.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          city.hasContent
              ? 'İçerikleri keşfet'
              : city.emptyStateDescription ?? 'Yakında içerik eklenecek',
        ),
        trailing: isSaving
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : city.hasContent
            ? const Icon(Icons.chevron_right)
            : const Chip(
                visualDensity: VisualDensity.compact,
                label: Text('YAKINDA'),
              ),
      ),
    );
  }
}

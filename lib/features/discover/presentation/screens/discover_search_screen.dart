import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class DiscoverSearchScreen extends ConsumerStatefulWidget {
  const DiscoverSearchScreen({super.key});

  @override
  ConsumerState<DiscoverSearchScreen> createState() =>
      _DiscoverSearchScreenState();
}

class _DiscoverSearchScreenState extends ConsumerState<DiscoverSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) setState(() => _query = value.trim());
    });
    setState(() {});
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

    return Scaffold(
      appBar: AppBar(title: const Text('Ara')),
      body: RefreshIndicator(
        color: BiCikalimTheme.primary,
        onRefresh: () async {
          if (provider != null) {
            ref.invalidate(provider);
            await ref.read(provider.future);
          } else {
            ref.invalidate(selectedCityProvider);
            await ref.read(selectedCityProvider.future);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              decoration: InputDecoration(
                hintText: 'Aktivite, mekan veya etkinlik ara...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _controller.clear();
                          _debounce?.cancel();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
              ),
            ),
            const SizedBox(height: 18),
            if (_query.length < 2)
              const Text(
                'Aramak için en az iki karakter yaz.',
                style: TextStyle(color: BiCikalimTheme.textSecondary),
              )
            else
              resultAsync!.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => AppEmptyState(
                  icon: Icons.cloud_off,
                  message: 'Arama yapılamadı.\n$error',
                ),
                data: _buildResults,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ApiSearchResult result) {
    if (result.total == 0) {
      return const AppEmptyState(
        icon: Icons.search_off,
        message: 'Aramana uygun sonuç bulunamadı.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.taxonomy.isNotEmpty) ...[
          const _SectionTitle('Aktiviteler ve kategoriler'),
          ...result.taxonomy.map(_buildTaxonomyRow),
          const SizedBox(height: 16),
        ],
        if (result.venues.isNotEmpty) ...[
          const _SectionTitle('Mekanlar'),
          ...result.venues.map(
            (venue) => ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(venue.name),
              subtitle: Text(
                venue.shortDescription ?? venue.city.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => context.push('/venues/${venue.slug}'),
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (result.events.isNotEmpty) ...[
          const _SectionTitle('Etkinlikler'),
          ...result.events.map(
            (event) => ListTile(
              leading: const Icon(Icons.event_outlined),
              title: Text(event.title),
              subtitle: Text(event.city.name),
              onTap: () => context.push('/events/${event.slug}'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTaxonomyRow(ApiSearchTaxonomyItem item) {
    final scope = switch (item.type) {
      'category' => 'categorySlug',
      'sub_category' || 'subcategory' => 'subcategorySlug',
      _ => 'activitySlug',
    };
    return ListTile(
      leading: Icon(
        scope == 'activitySlug'
            ? Icons.sports_esports
            : Icons.category_outlined,
      ),
      title: Text(item.name),
      subtitle: Text(item.type),
      onTap: () => context.push(
        Uri(
          path: '/discover/results',
          queryParameters: {scope: item.slug, 'title': item.name},
        ).toString(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class DiscoverSearchScreen extends ConsumerStatefulWidget {
  final String initialQuery;

  const DiscoverSearchScreen({super.key, this.initialQuery = ''});

  @override
  ConsumerState<DiscoverSearchScreen> createState() =>
      _DiscoverSearchScreenState();
}

class _DiscoverSearchScreenState extends ConsumerState<DiscoverSearchScreen> {
  late final TextEditingController _controller;
  Timer? _debounce;
  late String _query;

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
          padding: EdgeInsets.fromLTRB(
            context.layout.screenPadding,
            8,
            context.layout.screenPadding,
            MediaQuery.viewInsetsOf(context).bottom + context.layout.sectionGap,
          ),
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              autocorrect: false,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                setState(() => _query = value.trim());
              },
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
            const SizedBox(height: 10),
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
              minTileHeight: context.layout.fluid(86, 90, 98),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.layout.cardPadding,
              ),
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
              minTileHeight: context.layout.fluid(88, 94, 102),
              contentPadding: EdgeInsets.symmetric(
                horizontal: context.layout.cardPadding,
              ),
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
      minTileHeight: context.layout.fluid(72, 78, 84),
      contentPadding: EdgeInsets.symmetric(
        horizontal: context.layout.cardPadding,
      ),
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
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: context.layout.sectionTitleSize,
        ),
      ),
    );
  }
}

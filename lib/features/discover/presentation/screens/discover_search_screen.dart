import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_empty_state.dart';

class DiscoverSearchScreen extends StatefulWidget {
  const DiscoverSearchScreen({super.key});

  @override
  State<DiscoverSearchScreen> createState() => _DiscoverSearchScreenState();
}

class _DiscoverSearchScreenState extends State<DiscoverSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _controller.text.trim();
    final categories = query.isEmpty
        ? <ActivityCategory>[]
        : MockDatabase.searchCategories(query);
    final activities = query.isEmpty
        ? <Activity>[]
        : MockDatabase.searchActivities(query);
    final venues = query.isEmpty
        ? <Venue>[]
        : MockDatabase.searchVenues(query).take(6).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Ara')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) => _openQueryResults(context, value),
            decoration: InputDecoration(
              hintText: 'Mekan, kategori veya aktivite ara...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _controller.clear,
                    ),
            ),
          ),
          const SizedBox(height: 18),
          if (query.isEmpty) ...[
            const Text(
              'Denemek icin: Catan, karaoke, padel, FRP, bilardo',
              style: TextStyle(
                color: BiCikalimTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            _QuickSearchGrid(
              onTap: (label) {
                _controller.text = label;
                _controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: _controller.text.length),
                );
              },
            ),
          ] else if (categories.isEmpty &&
              activities.isEmpty &&
              venues.isEmpty) ...[
            const AppEmptyState(
              icon: Icons.search_off,
              message: 'Aramana uygun sonuc bulunamadi.',
            ),
          ] else ...[
            if (categories.isNotEmpty) ...[
              const _SearchSectionTitle(title: 'Kategoriler'),
              const SizedBox(height: 10),
              ...categories.map((category) {
                return _SearchRow(
                  icon: category.icon,
                  title: category.name,
                  subtitle:
                      '${MockDatabase.getVenuesForCategory(category.id).length} mekan',
                  onTap: () {
                    context.push(
                      Uri(
                        path: '/discover/results',
                        queryParameters: {
                          'categoryId': category.id,
                          'title': category.name,
                        },
                      ).toString(),
                    );
                  },
                );
              }),
              const SizedBox(height: 16),
            ],
            if (activities.isNotEmpty) ...[
              const _SearchSectionTitle(title: 'Aktiviteler'),
              const SizedBox(height: 10),
              ...activities.take(8).map((activity) {
                final venuesForActivity = MockDatabase.getVenuesForActivity(
                  activity.id,
                );
                return _SearchRow(
                  icon: activity.icon,
                  title: activity.name,
                  subtitle: '${venuesForActivity.length} mekanda var',
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
              }),
              const SizedBox(height: 16),
            ],
            if (venues.isNotEmpty) ...[
              const _SearchSectionTitle(title: 'Mekanlar'),
              const SizedBox(height: 10),
              ...venues.map((venue) {
                return _SearchRow(
                  icon: Icons.storefront,
                  title: venue.name,
                  subtitle:
                      '${venue.district} · ${venue.activityTags.take(2).join(' · ')}',
                  onTap: () => context.push('/venues/${venue.id}'),
                );
              }),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => _openQueryResults(context, query),
              child: Text('"$query" icin tum sonuclari gor'),
            ),
          ],
        ],
      ),
    );
  }

  void _openQueryResults(BuildContext context, String rawQuery) {
    final value = rawQuery.trim();
    if (value.isEmpty) return;
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {'query': value, 'title': '"$value" aramasi'},
      ).toString(),
    );
  }
}

class _QuickSearchGrid extends StatelessWidget {
  final ValueChanged<String> onTap;

  const _QuickSearchGrid({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const items = ['Masaustu', 'Bilardo', 'Karaoke', 'Padel', 'VR', 'FRP'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return InkWell(
          onTap: () => onTap(item),
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: BiCikalimTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              item,
              style: const TextStyle(
                color: BiCikalimTheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SearchSectionTitle extends StatelessWidget {
  final String title;

  const _SearchSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        fontFamily: 'Outfit',
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SearchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: BiCikalimTheme.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: BiCikalimTheme.primary, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }
}

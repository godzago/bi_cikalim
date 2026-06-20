import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/services/mock_data.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _selectedFilter = 'Tümü';
  final TextEditingController _searchController = TextEditingController();
  List<Venue> _displayedVenues = List.from(MockDatabase.venues);
  List<Event> _displayedEvents = List.from(MockDatabase.events);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedVenues = MockDatabase.venues.where((v) {
        return v.name.toLowerCase().contains(query) ||
            v.description.toLowerCase().contains(query) ||
            v.activityTags.any((t) => t.toLowerCase().contains(query));
      }).toList();
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'Tümü') {
        _displayedVenues = List.from(MockDatabase.venues);
      } else if (filter == '4 Kişi') {
        _displayedVenues = MockDatabase.venues.where((v) {
          return v.activityTags.contains('Masa Oyunları');
        }).toList();
      } else if (filter == 'Bugün Açık') {
        _displayedVenues = List.from(MockDatabase.venues);
      } else if (filter == 'Yakınımda') {
        _displayedVenues = MockDatabase.venues.take(2).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BiÇıkalım',
                          style: TextStyle(
                            color: BiCikalimTheme.primary,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: BiCikalimTheme.primary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Eskişehir',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down, color: BiCikalimTheme.primary, size: 16),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Mekan, oyun veya aktivite ara...',
                    prefixIcon: const Icon(Icons.search, color: BiCikalimTheme.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                        : const Icon(Icons.tune, color: BiCikalimTheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Filter Chips
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildFilterChip('Tümü'),
                    _buildFilterChip('Bugün Açık'),
                    _buildFilterChip('Bu Akşam'),
                    _buildFilterChip('4 Kişi'),
                    _buildFilterChip('Yakınımda'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Categories Grid Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Aktivite Kategorileri',
                  style: TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Categories Grid
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: MockDatabase.categories.length,
                  itemBuilder: (context, index) {
                    final cat = MockDatabase.categories[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.text = cat.name;
                        });
                      },
                      child: Container(
                        width: 90,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          border: Border.all(color: Colors.grey.shade100),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: BiCikalimTheme.primary.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(cat.icon, color: BiCikalimTheme.primary, size: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cat.name,
                              style: const TextStyle(
                                color: BiCikalimTheme.textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Events Tonight Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Bu Akşam Ne Var?',
                      style: TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Tümünü Gör', style: TextStyle(color: BiCikalimTheme.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _displayedEvents.length,
                  itemBuilder: (context, index) {
                    final event = _displayedEvents[index];
                    final venue = MockDatabase.venues.firstWhere((v) => v.id == event.venueId);
                    return GestureDetector(
                      onTap: () {
                        context.push('/venues/${venue.id}');
                      },
                      child: Container(
                        width: 280,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: NetworkImage(event.imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.85),
                                Colors.black.withOpacity(0.2),
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: BiCikalimTheme.warning,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  event.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                event.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.store, color: Colors.white70, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    venue.name,
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Popular Venues
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Popüler Mekanlar',
                  style: TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _displayedVenues.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text('Aramanıza uygun mekan bulunamadı.', style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _displayedVenues.length,
                      itemBuilder: (context, index) {
                        final venue = _displayedVenues[index];
                        return GestureDetector(
                          onTap: () {
                            context.push('/venues/${venue.id}');
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), // Border top radius
                                      child: Image.network(
                                        venue.coverImageUrl,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 12,
                                      right: 12,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.bookmark_border, color: BiCikalimTheme.primary, size: 20),
                                      ),
                                    ),
                                    if (venue.verificationStatus == 'verified')
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: BiCikalimTheme.success,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.verified, color: Colors.white, size: 10),
                                              SizedBox(width: 4),
                                              Text(
                                                'ONAYLI MEKAN',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            venue.name,
                                            style: const TextStyle(
                                              color: BiCikalimTheme.textPrimary,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: BiCikalimTheme.primary.withOpacity(0.08),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.star, color: BiCikalimTheme.primary, size: 14),
                                                const SizedBox(width: 2),
                                                Text(
                                                  '${venue.averageRating}',
                                                  style: const TextStyle(
                                                    color: BiCikalimTheme.primary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, color: Colors.grey.shade400, size: 14),
                                          const SizedBox(width: 2),
                                          Text(
                                            '${venue.district}, ${venue.city}',
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        children: venue.activityTags.map((tag) {
                                          return Chip(
                                            labelPadding: EdgeInsets.zero,
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                            backgroundColor: Colors.grey.shade100,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              side: BorderSide(color: Colors.grey.shade100),
                                            ),
                                            label: Text(
                                              tag,
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (_) => _applyFilter(label),
        backgroundColor: Colors.white,
        selectedColor: BiCikalimTheme.primary.withOpacity(0.12),
        labelStyle: TextStyle(
          color: isSelected ? BiCikalimTheme.primary : BiCikalimTheme.textSecondary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? BiCikalimTheme.primary : Colors.grey.shade200),
        ),
        showCheckmark: false,
      ),
    );
  }
}

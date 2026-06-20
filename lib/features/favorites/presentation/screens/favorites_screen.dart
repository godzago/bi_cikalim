import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/services/mock_data.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedTab = 0; // 0 for Venues, 1 for Events

  @override
  Widget build(BuildContext context) {
    // Show a selection of mock saved data
    final savedVenues = [MockDatabase.venues[0], MockDatabase.venues[2]];
    final savedEvents = [MockDatabase.events[0]];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaydedilenler'),
      ),
      body: Column(
        children: [
          // Saved Type Toggle Tab
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildToggleTab(0, 'Mekanlar (${savedVenues.length})'),
                  _buildToggleTab(1, 'Etkinlikler (${savedEvents.length})'),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: _selectedTab == 0
                ? _buildSavedVenuesList(savedVenues)
                : _buildSavedEventsList(savedEvents),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? BiCikalimTheme.primary : BiCikalimTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedVenuesList(List<Venue> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final venue = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: InkWell(
            onTap: () {
              context.push('/venues/${venue.id}');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      venue.coverImageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: BiCikalimTheme.primary, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              '${venue.averageRating}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              venue.district,
                              style: const TextStyle(color: BiCikalimTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 4,
                          children: venue.activityTags.take(2).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: BiCikalimTheme.primary),
                    onPressed: () {
                      // Action to remove
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSavedEventsList(List<Event> list) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final event = list[index];
        final venue = MockDatabase.venues.firstWhere((v) => v.id == event.venueId);
        
        final dateStr = '${event.startDate.day} / ${event.startDate.month}';
        final timeStr = '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade100),
          ),
          child: InkWell(
            onTap: () {
              context.push('/venues/${venue.id}');
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      event.imageUrl,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: BiCikalimTheme.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.category,
                            style: const TextStyle(color: BiCikalimTheme.primary, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          event.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$dateStr | Saat: $timeStr',
                          style: const TextStyle(color: BiCikalimTheme.textSecondary, fontSize: 11),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          venue.name,
                          style: const TextStyle(color: BiCikalimTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: BiCikalimTheme.primary),
                    onPressed: () {
                      // Action to remove
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

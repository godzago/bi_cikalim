import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/services/mock_data.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _selectedDateFilter = 'Tümü';

  List<Event> _getFilteredEvents() {
    if (_selectedDateFilter == 'Bugün') {
      return MockDatabase.events.where((e) {
        final now = DateTime.now();
        return e.startDate.day == now.day && e.startDate.month == now.month && e.startDate.year == now.year;
      }).toList();
    } else if (_selectedDateFilter == 'Yarın') {
      return MockDatabase.events.where((e) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return e.startDate.day == tomorrow.day && e.startDate.month == tomorrow.month && e.startDate.year == tomorrow.year;
      }).toList();
    }
    return MockDatabase.events;
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = _getFilteredEvents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Etkinlikler'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Filter Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildDateSegment('Tümü'),
                const SizedBox(width: 8),
                _buildDateSegment('Bugün'),
                const SizedBox(width: 8),
                _buildDateSegment('Yarın'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Events List
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Bu tarih için etkinlik bulunmuyor.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];
                      final venue = MockDatabase.venues.firstWhere((v) => v.id == event.venueId);
                      
                      // Format date
                      final dateStr = '${event.startDate.day} / ${event.startDate.month}';
                      final timeStr = '${event.startDate.hour.toString().padLeft(2, '0')}:${event.startDate.minute.toString().padLeft(2, '0')}';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 20),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image and tags
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      event.imageUrl,
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            dateStr,
                                            style: const TextStyle(
                                              color: BiCikalimTheme.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            timeStr,
                                            style: const TextStyle(
                                              color: BiCikalimTheme.textSecondary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
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
                                ],
                              ),
                              
                              // Content
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: BiCikalimTheme.primary.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            event.category,
                                            style: const TextStyle(
                                              color: BiCikalimTheme.primary,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          event.priceInfo,
                                          style: const TextStyle(
                                            color: BiCikalimTheme.success,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      event.title,
                                      style: const TextStyle(
                                        color: BiCikalimTheme.textPrimary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      event.description,
                                      style: const TextStyle(
                                        color: BiCikalimTheme.textSecondary,
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(height: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                              image: NetworkImage(venue.coverImageUrl),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                venue.name,
                                                style: const TextStyle(
                                                  color: BiCikalimTheme.textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${venue.district}, Eskişehir',
                                                style: const TextStyle(
                                                  color: BiCikalimTheme.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                      ],
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
          ),
        ],
      ),
    );
  }

  Widget _buildDateSegment(String label) {
    final isSelected = _selectedDateFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedDateFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? BiCikalimTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? BiCikalimTheme.primary : Colors.grey.shade200,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : BiCikalimTheme.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

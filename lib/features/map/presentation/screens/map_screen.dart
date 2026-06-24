import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Venue? _selectedVenue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Harita Kesfi')),
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: MapGridPainter())),
          ...MockDatabase.venues.map((venue) {
            final xOffset = 200 + (venue.longitude - 30.52) * 4000;
            final yOffset = 300 - (venue.latitude - 39.77) * 4000;
            final isSelected = _selectedVenue?.id == venue.id;

            return Positioned(
              left: xOffset,
              top: yOffset,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVenue = venue;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BiCikalimTheme.primary
                            : Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : BiCikalimTheme.primary,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getVenueIcon(venue.activityTags.first),
                        color: isSelected
                            ? Colors.white
                            : BiCikalimTheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        venue.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_selectedVenue != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _selectedVenue!.coverImageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedVenue!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: BiCikalimTheme.primary,
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${_selectedVenue!.averageRating}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedVenue!.district,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: BiCikalimTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                context.push('/venues/${_selectedVenue!.id}');
                              },
                              child: const Row(
                                children: [
                                  Text(
                                    'Detayli Incele',
                                    style: TextStyle(
                                      color: BiCikalimTheme.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: BiCikalimTheme.primary,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedVenue = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getVenueIcon(String firstTag) {
    if (firstTag.contains('Masaustu') || firstTag.contains('FRP')) {
      return Icons.casino;
    }
    if (firstTag.contains('Bilardo') || firstTag.contains('Snooker')) {
      return Icons.sports;
    }
    if (firstTag.contains('Dijital') || firstTag.contains('VR')) {
      return Icons.sports_esports;
    }
    if (firstTag.contains('Karaoke')) return Icons.mic;
    if (firstTag.contains('Saha')) return Icons.sports_soccer;
    return Icons.store;
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintRoad = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 24
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintRiver = Paint()
      ..color = Colors.lightBlue.shade100
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintBackground = Paint()..color = const Color(0xFFF1EFE9);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paintBackground,
    );

    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.45);
    riverPath.cubicTo(
      size.width * 0.25,
      size.height * 0.35,
      size.width * 0.5,
      size.height * 0.65,
      size.width,
      size.height * 0.55,
    );
    canvas.drawPath(riverPath, paintRiver);

    canvas.drawLine(
      Offset(size.width * 0.15, 0),
      Offset(size.width * 0.85, size.height),
      paintRoad,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.7),
      paintRoad,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.5, size.height),
      paintRoad,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

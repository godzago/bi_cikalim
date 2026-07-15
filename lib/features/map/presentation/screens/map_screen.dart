import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/mock_data.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/app_network_image.dart';

/// Gerçek OpenStreetMap (Google Maps Yol görünümü tasarımı ile) entegre edilmiş harita ekranı.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Venue? _selectedVenue;
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Harita Keşfi')),
      body: Stack(
        children: [
          // FlutterMap ile gerçek harita çizimi (Google Maps Stili ile)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(39.7767, 30.5206), // Eskişehir pilot şehri koordinatları
              initialZoom: 14.0,
              minZoom: 10.0,
              maxZoom: 18.0,
              onTap: (tapPosition, point) {
                if (_selectedVenue != null) {
                  setState(() {
                    _selectedVenue = null;
                  });
                }
              },
            ),
            children: [
              // Google Maps Yol Görünümü Kiremitleri (Tile Layer)
              TileLayer(
                urlTemplate: 'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.godzago.bi_cikalim',
              ),
              // Mekan Pinleri (Marker Layer)
              MarkerLayer(
                markers: MockDatabase.venues.map((venue) {
                  final isSelected = _selectedVenue?.id == venue.id;
                  final latLng = LatLng(venue.latitude, venue.longitude);

                  return Marker(
                    point: latLng,
                    width: 100,
                    height: 80,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedVenue = venue;
                        });
                        // Haritayı seçilen mekana ortala
                        _mapController.move(latLng, _mapController.camera.zoom);
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
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              venue.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                }).toList(),
              ),
            ],
          ),
          
          // Üst Bilgilendirme Bandı
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.explore_outlined, color: BiCikalimTheme.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Haritada gezerek yakındaki mekanları keşfedin.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: BiCikalimTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Alt Mekan Detay Kartı (Mekan seçildiğinde açılır)
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppNetworkImage(
                          imageUrl: _selectedVenue!.coverImageUrl,
                          width: 80,
                          height: 80,
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
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                    'Detaylı İncele',
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

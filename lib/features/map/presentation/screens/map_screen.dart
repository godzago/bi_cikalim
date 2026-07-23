import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_network_image.dart';

/// Gerçek OpenStreetMap (Google Maps Yol görünümü tasarımı ile) entegre edilmiş harita ekranı.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  ApiVenue? _selectedVenue;
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestLocation();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _checkAndRequestLocation({bool isRetry = false}) async {
    if (_dialogOpen) return;

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showLocationPermissionDialog(
          title: 'Konum Servisi Kapalı 📍',
          message:
              'Lütfen yakınınızdaki eğlenceli aktiviteleri ve mekanları haritada görebilmek için cihazınızın GPS (konum) servisini açın.',
          isServiceError: true,
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (mounted) {
        _showLocationPermissionDialog(
          title: 'Yakındaki Eğlenceyi Kaçırma! 📍',
          message:
              'Sana en yakın mekanları ve bu akşamki etkinlikleri harita üzerinde gösterebilmemiz için konum iznine ihtiyacımız var.',
        );
      }
    } else if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showLocationPermissionDialog(
          title: 'Konum İzni Gerekli 📍',
          message:
              'Konum iznini kalıcı olarak reddettiniz. Lütfen uygulama ayarlarından konuma izin verin.',
          isPermanent: true,
        );
      }
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
        // Haritayı kullanıcının konumuna kaydır
        _mapController.move(_currentLocation!, 14.0);
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _showLocationPermissionDialog({
    required String title,
    required String message,
    bool isServiceError = false,
    bool isPermanent = false,
  }) {
    if (_dialogOpen) return;
    setState(() => _dialogOpen = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 8,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: BiCikalimTheme.primary,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: BiCikalimTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _dialogOpen = false);
                          _schedulePermissionRetry();
                        },
                        child: const Text(
                          'Şimdi Değil',
                          style: TextStyle(
                            color: BiCikalimTheme.textLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: BiCikalimTheme.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() => _dialogOpen = false);
                          if (isServiceError) {
                            await Geolocator.openLocationSettings();
                          } else if (isPermanent) {
                            await Geolocator.openAppSettings();
                          } else {
                            final permission =
                                await Geolocator.requestPermission();
                            if (permission == LocationPermission.whileInUse ||
                                permission == LocationPermission.always) {
                              _getCurrentLocation();
                            } else {
                              _schedulePermissionRetry();
                            }
                          }
                        },
                        child: const Text(
                          'İzin Ver',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _schedulePermissionRetry() {
    Future.delayed(const Duration(seconds: 20), () {
      if (mounted && _currentLocation == null) {
        _checkAndRequestLocation(isRetry: true);
      }
    });
  }

  Future<void> _refreshMap() async {
    final citySlug = ref.read(selectedCityProvider).value?.slug;
    final provider = venuesListProvider(
      VenueFilters(citySlug: citySlug, hasCoordinates: true),
    );
    ref.invalidate(provider);

    final futures = <Future<void>>[ref.read(provider.future).then((_) {})];
    if (_currentLocation != null) {
      futures.add(_getCurrentLocation());
    } else {
      futures.add(_checkAndRequestLocation(isRetry: true));
    }
    await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
    final citySlug = ref.watch(selectedCityProvider).value?.slug;
    final venuesAsync = ref.watch(
      venuesListProvider(
        VenueFilters(citySlug: citySlug, hasCoordinates: true),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harita Keşfi'),
        actions: [
          IconButton(
            tooltip: 'Haritayı yenile',
            onPressed: _refreshMap,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          // FlutterMap ile gerçek harita çizimi
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentLocation ??
                  const LatLng(
                    39.7767,
                    30.5206,
                  ), // Eskişehir pilot şehri koordinatları varsayılan
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
              TileLayer(
                urlTemplate:
                    'https://mt1.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
                userAgentPackageName: 'com.godzago.bi_cikalim',
              ),
              venuesAsync.when(
                loading: () => const MarkerLayer(markers: []),
                error: (err, _) => const MarkerLayer(markers: []),
                data: (venues) {
                  final validVenues = venues
                      .where((v) => v.latitude != null && v.longitude != null)
                      .toList();

                  return MarkerLayer(
                    markers: [
                      ...validVenues.map((venue) {
                        final isSelected = _selectedVenue?.id == venue.id;
                        final latLng = LatLng(
                          venue.latitude!,
                          venue.longitude!,
                        );
                        final firstTag = venue.activityTags.isNotEmpty
                            ? venue.activityTags.first
                            : '';

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
                              _mapController.move(
                                latLng,
                                _mapController.camera.zoom,
                              );
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
                                        color: Colors.black.withValues(
                                          alpha: 0.15,
                                        ),
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
                                    _getVenueIcon(firstTag),
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
                      }),
                    ],
                  );
                },
              ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 42,
                      height: 42,
                      child: Semantics(
                        label: 'Konumum',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 25,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade600,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.18),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.navigation_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Harita kaydırma hareketiyle çakışmayan üst pull-to-refresh alanı.
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 96,
            child: RefreshIndicator(
              color: BiCikalimTheme.primary,
              onRefresh: _refreshMap,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 97)],
              ),
            ),
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

          // Alt Mekan Detay Kartı
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
                                Expanded(
                                  child: Text(
                                    _selectedVenue!.districtName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: BiCikalimTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                context.push('/venues/${_selectedVenue!.slug}');
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
          Positioned(
            bottom: _selectedVenue != null ? 155 : 30,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'my_location',
                  backgroundColor: Colors.white,
                  foregroundColor: BiCikalimTheme.primary,
                  onPressed: () {
                    if (_currentLocation != null) {
                      _mapController.move(_currentLocation!, 14);
                    } else {
                      _checkAndRequestLocation(isRetry: true);
                    }
                  },
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: BiCikalimTheme.primary,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    if (currentZoom < 18.0) {
                      _mapController.move(
                        _mapController.camera.center,
                        currentZoom + 1.0,
                      );
                    }
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: BiCikalimTheme.primary,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    if (currentZoom > 10.0) {
                      _mapController.move(
                        _mapController.camera.center,
                        currentZoom - 1.0,
                      );
                    }
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getVenueIcon(String firstTag) {
    final tag = firstTag.toLowerCase();
    if (tag.contains('masaustu') || tag.contains('frp')) {
      return Icons.casino;
    }
    if (tag.contains('bilardo') || tag.contains('snooker')) {
      return Icons.sports;
    }
    if (tag.contains('dijital') || tag.contains('vr')) {
      return Icons.sports_esports;
    }
    if (tag.contains('karaoke')) return Icons.mic;
    if (tag.contains('saha')) return Icons.sports_soccer;
    return Icons.store;
  }
}

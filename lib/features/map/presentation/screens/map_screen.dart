import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/utils/app_url_launcher.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_network_image.dart';

/// Gerçek OpenStreetMap (Google Maps Yol görünümü tasarımı ile) entegre edilmiş harita ekranı.
class MapScreen extends ConsumerStatefulWidget {
  final String? citySlug;
  final String? districtSlug;
  final String? neighborhoodSlug;
  final String? activityCategorySlug;
  final String? activitySubCategorySlug;
  final String? activitySlug;
  final String? tagSlug;
  final String? q;
  final bool? isVerified;

  const MapScreen({
    super.key,
    this.citySlug,
    this.districtSlug,
    this.neighborhoodSlug,
    this.activityCategorySlug,
    this.activitySubCategorySlug,
    this.activitySlug,
    this.tagSlug,
    this.q,
    this.isVerified,
  });

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  ApiVenue? _selectedVenue;
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _dialogOpen = false;
  bool _mapReady = false;
  bool _userMovedMap = false;
  bool _loadingLocation = false;
  bool _refreshingMap = false;
  String? _lastAutoFitKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocationIfAlreadyAllowed();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadLocationIfAlreadyAllowed() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        await _getCurrentLocation();
      }
    } on Object catch (error) {
      debugPrint('Error checking location permission: $error');
    }
  }

  Future<void> _checkAndRequestLocation() async {
    if (_dialogOpen || _loadingLocation) return;

    bool serviceEnabled;
    LocationPermission permission;

    setState(() => _loadingLocation = true);
    try {
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
        await _getCurrentLocation(moveCamera: true, manageLoading: false);
      }
    } finally {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _getCurrentLocation({
    bool moveCamera = false,
    bool manageLoading = true,
  }) async {
    if (manageLoading && mounted) setState(() => _loadingLocation = true);
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
        if (moveCamera && _mapReady) {
          _mapController.move(_currentLocation!, 14.0);
        }
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      if (manageLoading && mounted) setState(() => _loadingLocation = false);
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
          insetPadding: EdgeInsets.symmetric(
            horizontal: context.layout.screenPadding,
            vertical: context.layout.sectionGap,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.layout.cardRadius),
          ),
          elevation: 8,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.layout.screenPadding),
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
                SizedBox(height: context.layout.sectionGap),
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
                              _getCurrentLocation(moveCamera: true);
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

  String? _clean(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  VenueFilters _buildVenueFilters(ApiCity? selectedCity) {
    return VenueFilters(
      citySlug: _clean(widget.citySlug) ?? selectedCity?.slug,
      districtSlug: _clean(widget.districtSlug),
      neighborhoodSlug: _clean(widget.neighborhoodSlug),
      activityCategorySlug: _clean(widget.activityCategorySlug),
      activitySubCategorySlug: _clean(widget.activitySubCategorySlug),
      activitySlug: _clean(widget.activitySlug),
      tagSlug: _clean(widget.tagSlug),
      q: _clean(widget.q),
      hasCoordinates: true,
      isVerified: widget.isVerified,
    );
  }

  String _filterKey(VenueFilters filters) {
    return [
      filters.citySlug,
      filters.districtSlug,
      filters.neighborhoodSlug,
      filters.activityCategorySlug,
      filters.activitySubCategorySlug,
      filters.activitySlug,
      filters.tagSlug,
      filters.q,
      filters.isVerified,
    ].map((value) => value?.toString() ?? '').join('|');
  }

  Future<void> _refreshMap() async {
    if (_refreshingMap) return;
    final filters = _buildVenueFilters(ref.read(selectedCityProvider).value);
    final provider = mapVenuesProvider(filters);
    setState(() => _refreshingMap = true);
    try {
      ref.invalidate(provider);
      await ref.read(provider.future);
    } finally {
      if (mounted) setState(() => _refreshingMap = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final mediaQuery = MediaQuery.of(context);
    final textScale = mediaQuery.textScaler.scale(16) / 16;
    final textHeightAllowance = (textScale - 1).clamp(0.0, 1.0) * 48;
    final baseSheetHeight = (mediaQuery.size.height * .24)
        .clamp(126.0, layout.collapsedMapSheetHeight)
        .toDouble();
    // The visual target remains 126–148 px at the default text size. Larger
    // accessibility text gets bounded extra room instead of overflowing the
    // fixed collapsed-sheet constraint.
    final sheetHeight = (baseSheetHeight + textHeightAllowance)
        .clamp(126.0, mediaQuery.size.height * .34)
        .toDouble();
    final selectedCity = ref.watch(selectedCityProvider).value;
    final filters = _buildVenueFilters(selectedCity);
    final filterKey = _filterKey(filters);
    final venuesAsync = ref.watch(mapVenuesProvider(filters));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harita Keşfi'),
        actions: [
          IconButton(
            tooltip: 'Haritayı yenile',
            onPressed: _refreshingMap ? null : _refreshMap,
            icon: _refreshingMap
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.refresh),
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
              keepAlive: true,
              onMapReady: () {
                if (mounted) setState(() => _mapReady = true);
              },
              onPositionChanged: (camera, hasGesture) {
                if (hasGesture) _userMovedMap = true;
              },
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
                data: (result) {
                  final validVenues = result.venues
                      .where((venue) => venue.hasValidCoordinates)
                      .toList(growable: false);
                  _syncSelectedVenue(validVenues);
                  _scheduleFitToVenues(validVenues, filterKey);
                  return MarkerLayer(markers: _buildVenueMarkers(validVenues));
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
            height: 72,
            child: RefreshIndicator(
              color: BiCikalimTheme.primary,
              onRefresh: _refreshMap,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 73)],
              ),
            ),
          ),

          // Üst Bilgilendirme Bandı
          Positioned(
            top: 8,
            left: layout.screenPadding,
            right: layout.screenPadding,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(layout.cardRadius),
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
          Positioned(
            top: 62,
            left: layout.screenPadding,
            right: layout.screenPadding,
            child: venuesAsync.when(
              loading: () => _buildMapInfoCard(
                icon: Icons.hourglass_top_rounded,
                title: 'Mekânlar yükleniyor',
                message: 'Koordinatlı mekânlar haritaya ekleniyor.',
              ),
              error: (error, _) => _buildMapErrorCard(error, filters),
              data: (result) {
                if (result.venues.isEmpty) return _buildMapEmptyCard(filters);
                return _buildMapInfoCard(
                  icon: Icons.location_on_outlined,
                  title: '${result.venues.length} mekân haritada',
                  message: result.loadedCount == result.venues.length
                      ? 'Seçili filtrelere uygun koordinatlı mekânlar gösteriliyor.'
                      : '${result.loadedCount - result.venues.length} mekân geçersiz koordinat nedeniyle gösterilmedi.',
                  compact: true,
                );
              },
            ),
          ),

          if (_loadingLocation || _refreshingMap || venuesAsync.isLoading)
            Positioned(
              top: 76,
              left: layout.screenPadding,
              right: layout.screenPadding,
              child: _MapLoadingBanner(
                message: _loadingLocation
                    ? 'Konumun alınıyor...'
                    : _refreshingMap
                    ? 'Harita yenileniyor...'
                    : 'Mekanlar yükleniyor...',
              ),
            ),

          if (_selectedVenue != null)
            Positioned(
              bottom: 8,
              left: layout.screenPadding,
              right: layout.screenPadding,
              height: sheetHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(layout.cardRadius),
                ),
                child: Padding(
                  padding: EdgeInsets.all(layout.cardPadding),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(layout.cardRadius),
                        child: AppNetworkImage(
                          imageUrl: _selectedVenue!.coverImageUrl,
                          width: layout.fluid(64, 70, 76),
                          height: double.infinity,
                          semanticLabel:
                              '${_selectedVenue!.name} kapak görseli',
                        ),
                      ),
                      SizedBox(width: layout.cardGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedVenue!.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: layout.cardTitleSize,
                                      height: 1.15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: AppLayout.minTouchTarget,
                                  height: AppLayout.minTouchTarget,
                                  child: IconButton(
                                    tooltip: 'Kapat',
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close, size: 17),
                                    onPressed: () =>
                                        setState(() => _selectedVenue = null),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: BiCikalimTheme.primary,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                                Flexible(
                                  child: Text(
                                    _ratingText(_selectedVenue!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: layout.metadataSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _shortLocation(_selectedVenue!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: layout.metadataSize,
                                      color: BiCikalimTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: Size(
                                        0,
                                        layout.compactControlHeight,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: layout.isCompact ? 6 : 10,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.padded,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () => context.push(
                                      '/venues/${_selectedVenue!.slug}',
                                    ),
                                    child: Text(
                                      'Detay',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: layout.metadataSize,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      minimumSize: Size(
                                        0,
                                        layout.compactControlHeight,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: layout.isCompact ? 6 : 10,
                                      ),
                                      tapTargetSize:
                                          MaterialTapTargetSize.padded,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    onPressed: () =>
                                        _openDirections(_selectedVenue!),
                                    child: Text(
                                      'Yol Tarifi',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: layout.metadataSize,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: _selectedVenue != null ? sheetHeight + 16 : 16,
            right: layout.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'my_location',
                  backgroundColor: Colors.white,
                  foregroundColor: BiCikalimTheme.primary,
                  onPressed: _loadingLocation
                      ? null
                      : () {
                          if (_currentLocation != null) {
                            _mapController.move(_currentLocation!, 14);
                          } else {
                            _checkAndRequestLocation();
                          }
                        },
                  child: _loadingLocation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.2),
                        )
                      : const Icon(Icons.my_location),
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

  List<Marker> _buildVenueMarkers(List<ApiVenue> venues) {
    return venues
        .map((venue) {
          final point = _venuePoint(venue)!;
          final isSelected = _selectedVenue?.id == venue.id;
          final firstTag = venue.activityTags.isNotEmpty
              ? venue.activityTags.first
              : venue.activitySummary.isNotEmpty
              ? venue.activitySummary.first.activityName
              : '';

          return Marker(
            point: point,
            width: 96,
            height: 78,
            alignment: Alignment.topCenter,
            child: Semantics(
              button: true,
              label: '${venue.name} marker',
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedVenue = venue);
                  _mapController.move(point, _mapController.camera.zoom);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      key: ValueKey('map-marker-${venue.id}'),
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BiCikalimTheme.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
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
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 92),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.76),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        venue.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        })
        .toList(growable: false);
  }

  LatLng? _venuePoint(ApiVenue venue) {
    if (!venue.hasValidCoordinates) return null;
    return LatLng(venue.latitude!, venue.longitude!);
  }

  void _scheduleFitToVenues(List<ApiVenue> venues, String filterKey) {
    if (!_mapReady || venues.isEmpty) return;
    if (_lastAutoFitKey == filterKey && _userMovedMap) return;
    if (_lastAutoFitKey == filterKey) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_mapReady || _lastAutoFitKey == filterKey) return;
      _fitToVenues(venues);
      _lastAutoFitKey = filterKey;
      _userMovedMap = false;
    });
  }

  void _fitToVenues(List<ApiVenue> venues) {
    final points = venues
        .map(_venuePoint)
        .whereType<LatLng>()
        .toList(growable: false);
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: EdgeInsets.fromLTRB(
          48,
          130,
          48,
          _selectedVenue != null ? 230 : 110,
        ),
        maxZoom: 15,
      ),
    );
  }

  void _syncSelectedVenue(List<ApiVenue> venues) {
    final selected = _selectedVenue;
    if (selected == null) return;
    final stillVisible = venues.any((venue) => venue.id == selected.id);
    if (stillVisible) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedVenue?.id == selected.id) {
        setState(() => _selectedVenue = null);
      }
    });
  }

  Widget _buildMapInfoCard({
    required IconData icon,
    required String title,
    required String message,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: compact ? 10 : 12,
      ),
      decoration: _overlayDecoration(),
      child: Row(
        children: [
          Icon(icon, color: BiCikalimTheme.primary, size: compact ? 19 : 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (!compact) ...[
                  const SizedBox(height: 3),
                  Text(
                    message,
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapErrorCard(Object error, VenueFilters filters) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _overlayDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: BiCikalimTheme.warning,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  friendlyErrorMessage(
                    error,
                    fallback: 'Harita mekânları şu anda yüklenemedi.',
                  ),
                  style: const TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: _refreshMap,
              child: const Text('Tekrar Dene'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapEmptyCard(VenueFilters filters) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _overlayDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Haritada gösterilebilecek mekân bulunamadı',
            style: TextStyle(
              color: BiCikalimTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Koordinatı olan mekânları gösterebiliriz. Filtreleri azaltmayı deneyebilirsin.',
            style: TextStyle(
              color: BiCikalimTheme.textSecondary,
              fontSize: 12,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openVenueList(filters),
                icon: const Icon(Icons.list_alt_rounded, size: 18),
                label: const Text('Listeyi Gör'),
              ),
              FilledButton.icon(
                onPressed: () => _clearMapFilters(filters),
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('Filtreleri Temizle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _overlayDecoration() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: .96),
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // Kept for the expanded marker presentation used by larger surfaces.
  // ignore: unused_element
  Widget _buildActivityPreview(ApiVenue venue) {
    final names = venue.activitySummary
        .map((item) => item.activityName)
        .where((name) => name.trim().isNotEmpty)
        .take(3)
        .toList(growable: false);
    if (names.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: names
          .map(
            (name) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BiCikalimTheme.primary.withValues(alpha: .09),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                name,
                style: const TextStyle(
                  color: BiCikalimTheme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  String _ratingText(ApiVenue venue) {
    final rating = venue.ratingAverage;
    if (rating == null || rating <= 0 || venue.reviewCount <= 0) {
      return 'Henüz değerlendirme yok';
    }
    return '${rating.toStringAsFixed(1).replaceAll('.', ',')} · ${venue.reviewCount} yorum';
  }

  String _shortLocation(ApiVenue venue) {
    final parts = [
      venue.neighborhood?.name,
      venue.district?.name,
      venue.cityName,
    ].where((part) => part != null && part.trim().isNotEmpty).cast<String>();
    return parts.take(2).join(', ');
  }

  void _openVenueList(VenueFilters filters) {
    final params = _queryParamsForFilters(filters)
      ..['type'] = 'venues'
      ..['hasCoordinates'] = 'true';
    context.push(
      Uri(path: '/discover/results', queryParameters: params).toString(),
    );
  }

  void _clearMapFilters(VenueFilters filters) {
    final params = <String, String>{};
    if (filters.citySlug != null) params['citySlug'] = filters.citySlug!;
    context.go(
      params.isEmpty
          ? '/map'
          : Uri(path: '/map', queryParameters: params).toString(),
    );
  }

  Map<String, String> _queryParamsForFilters(VenueFilters filters) {
    return {
      if (filters.citySlug != null) 'citySlug': filters.citySlug!,
      if (filters.districtSlug != null) 'districtSlug': filters.districtSlug!,
      if (filters.neighborhoodSlug != null)
        'neighborhoodSlug': filters.neighborhoodSlug!,
      if (filters.activityCategorySlug != null)
        'activityCategorySlug': filters.activityCategorySlug!,
      if (filters.activitySubCategorySlug != null)
        'activitySubCategorySlug': filters.activitySubCategorySlug!,
      if (filters.activitySlug != null) 'activitySlug': filters.activitySlug!,
      if (filters.tagSlug != null) 'tagSlug': filters.tagSlug!,
      if (filters.q != null) 'query': filters.q!,
      if (filters.isVerified == true) 'isVerified': 'true',
    };
  }

  Future<void> _openDirections(ApiVenue venue) async {
    final url = venue.googleMapsUrl?.trim().isNotEmpty == true
        ? venue.googleMapsUrl!.trim()
        : venue.latitude != null && venue.longitude != null
        ? 'https://www.google.com/maps/search/?api=1&query='
              '${venue.latitude},${venue.longitude}'
        : null;
    await launchAppExternalUrl(
      context: context,
      rawUrl: url,
      allowedSchemes: webUrlSchemes,
      failureMessage: 'Yol tarifi açılamadı.',
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

class _MapLoadingBanner extends StatelessWidget {
  final String message;

  const _MapLoadingBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .96),
          borderRadius: BorderRadius.circular(context.layout.cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: BiCikalimTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

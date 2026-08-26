import 'dart:async';
import 'package:flutter/foundation.dart';
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
import '../../../../shared/widgets/app_filter_chip.dart';
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
  ApiEvent? _selectedEvent;
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  LatLng? _currentLocation;
  Timer? _searchDebounce;
  Timer? _cameraIdleDebounce;
  bool _dialogOpen = false;
  bool _mapReady = false;
  bool _userMovedMap = false;
  bool _loadingLocation = false;
  bool _refreshingMap = false;
  bool _searchOverlayOpen = false;
  String _searchQuery = '';
  String? _activityCategorySlug;
  String? _activitySlug;
  String? _activityLabel;
  String? _lastAutoFitKey;
  String? _lastCameraRefreshKey;
  String? _cachedMarkerKey;
  List<Marker> _cachedMarkers = const [];

  @override
  void initState() {
    super.initState();
    _activityCategorySlug = _clean(widget.activityCategorySlug);
    _activitySlug = _clean(widget.activitySlug);
    _activityLabel = _activitySlug;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLocationIfAlreadyAllowed();
    });
  }

  @override
  void didUpdateWidget(covariant MapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activityCategorySlug != widget.activityCategorySlug ||
        oldWidget.activitySlug != widget.activitySlug) {
      _activityCategorySlug = _clean(widget.activityCategorySlug);
      _activitySlug = _clean(widget.activitySlug);
      _activityLabel = _activitySlug;
      _selectedVenue = null;
      _selectedEvent = null;
      _lastAutoFitKey = null;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _cameraIdleDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
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
      if (kDebugMode) {
        debugPrint('Error checking location permission: $error');
      }
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
      if (kDebugMode) {
        debugPrint('Error getting location: $e');
      }
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
      activityCategorySlug: _activityCategorySlug,
      activitySubCategorySlug: _clean(widget.activitySubCategorySlug),
      activitySlug: _activitySlug,
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

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    setState(() => _searchOverlayOpen = true);
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final query = value.trim();
      if (query != _searchQuery) setState(() => _searchQuery = query);
    });
  }

  void _closeSearchOverlay({bool clear = false}) {
    _searchDebounce?.cancel();
    _searchFocusNode.unfocus();
    setState(() {
      _searchOverlayOpen = false;
      if (clear) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _selectActivity(ApiSearchTaxonomyItem activity) {
    _searchDebounce?.cancel();
    _searchFocusNode.unfocus();
    _searchController.clear();
    setState(() {
      _searchOverlayOpen = false;
      _searchQuery = '';
      _activityCategorySlug = null;
      _activitySlug = activity.slug;
      _activityLabel = activity.name;
      _selectedVenue = null;
      _selectedEvent = null;
      _lastAutoFitKey = null;
    });
  }

  void _selectCategory(ApiCategory? category) {
    _searchFocusNode.unfocus();
    setState(() {
      _searchOverlayOpen = false;
      _activityCategorySlug = category?.slug;
      _activitySlug = null;
      _activityLabel = null;
      _selectedVenue = null;
      _selectedEvent = null;
      _lastAutoFitKey = null;
    });
  }

  Future<void> _selectVenueResult(ApiSearchVenueItem result) async {
    _closeSearchOverlay(clear: true);
    try {
      final venue = await ref.read(venueDetailProvider(result.slug).future);
      if (!mounted) return;
      final point = _venuePoint(venue);
      if (point == null) {
        _showMapMessage('Bu mekanın harita konumu bulunmuyor.');
        return;
      }
      setState(() {
        _selectedVenue = venue;
        _selectedEvent = null;
      });
      _mapController.move(point, 15);
    } on Object catch (error) {
      if (mounted) {
        _showMapMessage(
          friendlyErrorMessage(
            error,
            fallback: 'Mekan bilgisi şu anda yüklenemedi.',
          ),
        );
      }
    }
  }

  Future<void> _selectEventResult(ApiSearchEventItem result) async {
    _closeSearchOverlay(clear: true);
    try {
      final event = await ref.read(eventDetailProvider(result.slug).future);
      final venueSummary = event.venue;
      if (venueSummary == null || venueSummary.slug.isEmpty) {
        if (mounted) _showMapMessage('Bu etkinliğin mekan bilgisi bulunmuyor.');
        return;
      }
      final venue = await ref.read(
        venueDetailProvider(venueSummary.slug).future,
      );
      if (!mounted) return;
      final point = _venuePoint(venue);
      if (point == null) {
        _showMapMessage('Etkinlik mekanının harita konumu bulunmuyor.');
        return;
      }
      setState(() {
        _selectedVenue = venue;
        _selectedEvent = event;
      });
      _mapController.move(point, 15);
    } on Object catch (error) {
      if (mounted) {
        _showMapMessage(
          friendlyErrorMessage(
            error,
            fallback: 'Etkinlik bilgisi şu anda yüklenemedi.',
          ),
        );
      }
    }
  }

  void _showMapMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _scheduleCameraRefresh(LatLng center, double zoom) {
    _cameraIdleDebounce?.cancel();
    _cameraIdleDebounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      if (_refreshingMap) {
        _scheduleCameraRefresh(center, zoom);
        return;
      }
      final key =
          '${(center.latitude * 500).round()}|'
          '${(center.longitude * 500).round()}|${(zoom * 2).round()}';
      if (_lastCameraRefreshKey == key) return;
      _lastCameraRefreshKey = key;
      _refreshMap();
    });
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
    final previewDetailAllowance =
        (_activitySlug != null || _selectedEvent != null)
        ? 20 + ((textScale - 1).clamp(0.0, .5) * 20)
        : 0;
    final sheetHeight =
        (baseSheetHeight + textHeightAllowance + previewDetailAllowance)
            .clamp(126.0, mediaQuery.size.height * .34)
            .toDouble();
    final selectedCity = ref.watch(selectedCityProvider).value;
    final filters = _buildVenueFilters(selectedCity);
    final filterKey = _filterKey(filters);
    final venuesAsync = ref.watch(mapVenuesProvider(filters));
    final categoriesAsync = ref.watch(categoriesProvider);
    final categories = categoriesAsync.when(
      data: (items) => items,
      error: (_, _) => const <ApiCategory>[],
      loading: () => const <ApiCategory>[],
    );
    final searchProvider = _searchQuery.length < 2
        ? null
        : searchResultsProvider(
            SearchFilters(
              query: _searchQuery,
              citySlug: selectedCity?.slug,
              limit: 8,
            ),
          );
    final searchAsync = searchProvider == null
        ? null
        : ref.watch(searchProvider);

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
                if (hasGesture) {
                  _userMovedMap = true;
                  _scheduleCameraRefresh(camera.center, camera.zoom);
                }
              },
              onTap: (tapPosition, point) {
                if (_selectedVenue != null || _searchOverlayOpen) {
                  _searchFocusNode.unfocus();
                  setState(() {
                    _selectedVenue = null;
                    _selectedEvent = null;
                    _searchOverlayOpen = false;
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
                  final validVenues = _withSelectedVenue(result.venues)
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

          // Compact map search and category filters.
          Positioned(
            top: 8,
            left: layout.screenPadding,
            right: layout.screenPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: layout.searchHeight,
                  child: TextField(
                    key: const ValueKey('map-search-field'),
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autocorrect: false,
                    textInputAction: TextInputAction.search,
                    onTap: () {
                      if (!_searchOverlayOpen) {
                        setState(() => _searchOverlayOpen = true);
                      }
                    },
                    onChanged: _onSearchChanged,
                    onSubmitted: (value) {
                      _searchDebounce?.cancel();
                      setState(() {
                        _searchQuery = value.trim();
                        _searchOverlayOpen = true;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search activity, venue or event',
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 40,
                      ),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Aramayı temizle',
                              onPressed: () {
                                _searchDebounce?.cancel();
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _searchOverlayOpen = true;
                                });
                              },
                              icon: const Icon(Icons.close, size: 18),
                            ),
                      suffixIconConstraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 40,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: AppLayout.minTouchTarget,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      AppFilterChip(
                        label: 'All',
                        isSelected:
                            _activityCategorySlug == null &&
                            _activitySlug == null,
                        onTap: () => _selectCategory(null),
                      ),
                      if (_activitySlug != null)
                        AppFilterChip(
                          key: const ValueKey('map-active-activity-filter'),
                          label: '${_activityLabel ?? _activitySlug} ×',
                          isSelected: true,
                          onTap: () => _selectCategory(null),
                        ),
                      ...categories.map(
                        (category) => AppFilterChip(
                          label: category.name,
                          isSelected: _activityCategorySlug == category.slug,
                          onTap: () => _selectCategory(category),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (venuesAsync.hasError ||
              (venuesAsync.hasValue && venuesAsync.value!.venues.isEmpty))
            Positioned(
              top: layout.searchHeight + 62,
              left: layout.screenPadding,
              right: layout.screenPadding,
              child: venuesAsync.hasError
                  ? _buildMapErrorCard(venuesAsync.error!, filters)
                  : _buildMapEmptyCard(filters),
            ),

          if (_loadingLocation || _refreshingMap || venuesAsync.isLoading)
            Positioned(
              top: layout.searchHeight + 62,
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
                                    _selectedEvent?.title ??
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
                                    onPressed: () => setState(() {
                                      _selectedVenue = null;
                                      _selectedEvent = null;
                                    }),
                                  ),
                                ),
                              ],
                            ),
                            _selectedEvent == null
                                ? Row(
                                    children: [
                                      const Icon(
                                        Icons.star,
                                        color: BiCikalimTheme.primary,
                                        size: 13,
                                      ),
                                      const SizedBox(width: 2),
                                      Flexible(
                                        child: Text(
                                          _compactRatingText(_selectedVenue!),
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
                                          _distanceOrLocation(_selectedVenue!),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: layout.metadataSize,
                                            color: BiCikalimTheme.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    _selectedVenue!.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: layout.metadataSize,
                                      fontWeight: FontWeight.w700,
                                      color: BiCikalimTheme.textSecondary,
                                    ),
                                  ),
                            if (_activitySlug != null &&
                                _selectedEvent == null) ...[
                              const SizedBox(height: 2),
                              Text(
                                _activityVenueText(_selectedVenue!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: layout.metadataSize,
                                  color: BiCikalimTheme.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ] else if (_selectedEvent != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                _eventPreviewText(_selectedEvent!),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: layout.metadataSize,
                                  color: BiCikalimTheme.textSecondary,
                                ),
                              ),
                            ],
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
                                      _selectedEvent == null
                                          ? '/venues/${_selectedVenue!.slug}'
                                          : '/events/${_selectedEvent!.slug}',
                                    ),
                                    child: Text(
                                      _selectedEvent == null
                                          ? 'Detay'
                                          : 'Etkinlik',
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
                                    onPressed: _selectedEvent == null
                                        ? () => _openDirections(_selectedVenue!)
                                        : () => context.push(
                                            '/venues/${_selectedVenue!.slug}',
                                          ),
                                    child: Text(
                                      _selectedEvent == null
                                          ? 'Yol Tarifi'
                                          : 'Mekan',
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
          if (_searchOverlayOpen)
            Positioned(
              top: layout.searchHeight + 58,
              left: layout.screenPadding,
              right: layout.screenPadding,
              child: _buildSearchOverlay(searchAsync),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay(AsyncValue<ApiSearchResult>? searchAsync) {
    final maxHeight = (MediaQuery.sizeOf(context).height * .46)
        .clamp(180.0, 340.0)
        .toDouble();
    return Container(
      key: const ValueKey('map-search-overlay'),
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: _overlayDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: searchAsync == null
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: Text(
                  'Aramak için en az iki karakter yaz.',
                  style: TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              )
            : searchAsync.when(
                loading: () => const SizedBox(
                  height: 76,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    friendlyErrorMessage(
                      error,
                      fallback: 'Arama şu anda yapılamadı.',
                    ),
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                data: _buildSearchResults,
              ),
      ),
    );
  }

  Widget _buildSearchResults(ApiSearchResult result) {
    final activities = result.taxonomy
        .where((item) {
          final type = item.type.toLowerCase();
          return type != 'category' &&
              type != 'activity_category' &&
              type != 'sub_category' &&
              type != 'subcategory' &&
              type != 'activity_sub_category';
        })
        .toList(growable: false);
    if (activities.isEmpty && result.venues.isEmpty && result.events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: Text(
          'Aramana uygun sonuç bulunamadı.',
          style: TextStyle(color: BiCikalimTheme.textSecondary, fontSize: 12),
        ),
      );
    }

    return ListView(
      key: const ValueKey('map-search-results'),
      padding: const EdgeInsets.symmetric(vertical: 6),
      shrinkWrap: true,
      children: [
        if (activities.isNotEmpty) ...[
          const _MapSearchSectionTitle('Activities'),
          ...activities.map(
            (activity) => _MapSearchResultTile(
              icon: Icons.local_activity_outlined,
              title: activity.name,
              onTap: () => _selectActivity(activity),
            ),
          ),
        ],
        if (result.venues.isNotEmpty) ...[
          const _MapSearchSectionTitle('Venues'),
          ...result.venues.map(
            (venue) => _MapSearchResultTile(
              icon: Icons.storefront_outlined,
              title: venue.name,
              subtitle: venue.shortDescription ?? venue.city.name,
              onTap: () => _selectVenueResult(venue),
            ),
          ),
        ],
        if (result.events.isNotEmpty) ...[
          const _MapSearchSectionTitle('Events'),
          ...result.events.map(
            (event) => _MapSearchResultTile(
              icon: Icons.event_outlined,
              title: event.title,
              subtitle: event.city.name,
              onTap: () => _selectEventResult(event),
            ),
          ),
        ],
      ],
    );
  }

  List<ApiVenue> _withSelectedVenue(List<ApiVenue> venues) {
    final selected = _selectedVenue;
    if (selected == null ||
        !selected.hasValidCoordinates ||
        venues.any((venue) => venue.id == selected.id)) {
      return venues;
    }
    return [...venues, selected];
  }

  List<Marker> _buildVenueMarkers(List<ApiVenue> venues) {
    final markerKey = [
      _selectedVenue?.id ?? '',
      for (final venue in venues)
        '${venue.id}:${venue.latitude}:${venue.longitude}:${venue.name}:'
            '${venue.activitySummary.isEmpty ? '' : venue.activitySummary.first.activitySlug}:'
            '${venue.tags.isEmpty ? '' : venue.tags.first.slug}',
    ].join('|');
    if (_cachedMarkerKey == markerKey) return _cachedMarkers;

    _cachedMarkerKey = markerKey;
    _cachedMarkers = venues
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
                  setState(() {
                    _selectedVenue = venue;
                    _selectedEvent = null;
                  });
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
    return _cachedMarkers;
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

  String _compactRatingText(ApiVenue venue) {
    final rating = venue.ratingAverage;
    if (rating == null || rating <= 0) return 'Yeni';
    return rating.toStringAsFixed(1).replaceAll('.', ',');
  }

  String _distanceOrLocation(ApiVenue venue) {
    final current = _currentLocation;
    if (current == null || !venue.hasValidCoordinates) {
      return _shortLocation(venue);
    }
    final meters = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      venue.latitude!,
      venue.longitude!,
    );
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
  }

  String _activityVenueText(ApiVenue venue) {
    ApiVenueActivitySummary? activity;
    for (final item in venue.activitySummary) {
      if (item.activitySlug == _activitySlug) {
        activity = item;
        break;
      }
    }
    final name = activity?.activityName.trim().isNotEmpty == true
        ? activity!.activityName
        : (_activityLabel ?? _activitySlug ?? 'Aktivite');
    if (activity == null) return name;
    final String? availability = switch (activity.availability.toLowerCase()) {
      'available' || 'active' => 'Uygun',
      'unavailable' || 'inactive' => 'Uygun değil',
      'reservation_required' => null,
      _ => activity.availability.trim().isEmpty ? null : activity.availability,
    };
    final price = activity.price == null
        ? activity.isFree
              ? 'Ücretsiz'
              : null
        : '${_formatPrice(activity.price!)} ${activity.priceUnit ?? 'TRY'}';
    return [name, availability, ?price].join(' · ');
  }

  String _formatPrice(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _eventPreviewText(ApiEvent event) {
    final date = event.startAt.toLocal();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final dateLabel = '${date.day}.${date.month} $hour:$minute';
    if (!event.hasPublicPriceInfo) return dateLabel;
    return '$dateLabel · ${event.priceInfo}';
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

class _MapSearchSectionTitle extends StatelessWidget {
  final String title;

  const _MapSearchSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: BiCikalimTheme.textPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MapSearchResultTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MapSearchResultTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      minTileHeight: AppLayout.minTouchTarget,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: Icon(icon, color: BiCikalimTheme.primary, size: 20),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
      subtitle: subtitle == null || subtitle!.trim().isEmpty
          ? null
          : Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5),
            ),
      onTap: onTap,
    );
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

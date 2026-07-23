import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';
import '../../../../shared/widgets/event_list_card.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTogglingFavorite = false;
  bool? _favoriteOverride;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(ApiVenue venue) async {
    if (_isTogglingFavorite) return;
    final previous = _favoriteOverride ?? venue.isFavorite;
    setState(() {
      _isTogglingFavorite = true;
      _favoriteOverride = !previous;
    });

    try {
      final service = ref.read(venueApiServiceProvider);
      final result = previous
          ? await service.removeFavoriteVenue(venue.id)
          : await service.addFavoriteVenue(venue.id);
      _favoriteOverride = result;
      ref
          .read(analyticsApiServiceProvider)
          .track(
            eventName: AnalyticsEventName.favorite,
            venueId: venue.id,
            properties: {
              'target_type': 'venue',
              'action': result ? 'add' : 'remove',
            },
          );
      if (!mounted) return;
      if (previous) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mekan kaydedilenlerden çıkarıldı.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mekan kaydedilenlere eklendi.')),
        );
      }
      ref.invalidate(venueDetailProvider(widget.venueId));
      ref.invalidate(favoriteVenuesProvider);
    } catch (e) {
      _favoriteOverride = previous;
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('İşlem başarısız oldu: $e')));
    } finally {
      if (mounted) setState(() => _isTogglingFavorite = false);
    }
  }

  void _showAddReviewDialog(ApiVenue venue) {
    int rating = 5;
    String? activityId;
    var isSubmitting = false;
    final commentController = TextEditingController();
    final pageContext = context;

    showDialog<void>(
      context: pageContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Yorum Yaz'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Puanın:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: rating,
                      isExpanded: true,
                      items: List.generate(5, (index) => 5 - index).map((val) {
                        return DropdownMenuItem<int>(
                          value: val,
                          child: Row(
                            children: List.generate(
                              5,
                              (starIndex) => Icon(
                                starIndex < val
                                    ? Icons.star
                                    : Icons.star_border,
                                color: BiCikalimTheme.primary,
                                size: 18,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: isSubmitting
                          ? null
                          : (val) {
                              if (val != null) {
                                setDialogState(() => rating = val);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    if (venue.activitySummary.isNotEmpty) ...[
                      DropdownButtonFormField<String?>(
                        initialValue: activityId,
                        decoration: const InputDecoration(
                          labelText: 'Aktivite bağlamı (opsiyonel)',
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Genel mekan yorumu'),
                          ),
                          ...venue.activitySummary.map(
                            (item) => DropdownMenuItem<String?>(
                              value: item.activityId,
                              child: Text(item.activityName),
                            ),
                          ),
                        ],
                        onChanged: isSubmitting
                            ? null
                            : (value) =>
                                  setDialogState(() => activityId = value),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'Yorumun:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      enabled: !isSubmitting,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Mekan hakkındaki görüşlerinizi yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text(
                    'İptal',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BiCikalimTheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          var reviewCreated = false;
                          try {
                            final service = ref.read(
                              interactionApiServiceProvider,
                            );
                            await service.createReview(
                              venue.id,
                              rating,
                              commentController.text,
                              activityId: activityId,
                            );
                            reviewCreated = true;
                            if (!mounted || !dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              const SnackBar(
                                content: Text('Yorumunuz başarıyla eklendi.'),
                              ),
                            );
                            ref.invalidate(venueReviewsProvider(venue.id));
                            ref.invalidate(venueDetailProvider(widget.venueId));
                          } catch (e) {
                            if (!mounted || !dialogContext.mounted) return;
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              SnackBar(
                                content: Text('Yorum eklenirken hata: $e'),
                              ),
                            );
                          } finally {
                            if (!reviewCreated && dialogContext.mounted) {
                              setDialogState(() => isSubmitting = false);
                            }
                          }
                        },
                  child: const Text(
                    'Gönder',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(commentController.dispose);
  }

  void _showReportDialog(ApiVenue venue) {
    var reason = 'incorrect_info';
    final descriptionController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Mekanı Bildir'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: reason,
                decoration: const InputDecoration(labelText: 'Neden'),
                items: const [
                  DropdownMenuItem(
                    value: 'incorrect_info',
                    child: Text('Yanlış bilgi'),
                  ),
                  DropdownMenuItem(value: 'spam', child: Text('Spam')),
                  DropdownMenuItem(
                    value: 'offensive',
                    child: Text('Uygunsuz içerik'),
                  ),
                  DropdownMenuItem(value: 'fake', child: Text('Sahte kayıt')),
                  DropdownMenuItem(value: 'other', child: Text('Diğer')),
                ],
                onChanged: (value) =>
                    setDialogState(() => reason = value ?? 'other'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Açıklama'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Vazgeç'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref
                      .read(interactionApiServiceProvider)
                      .createContentReport(
                        targetType: 'venue',
                        targetId: venue.id,
                        reason: reason,
                        description: descriptionController.text.trim().isEmpty
                            ? null
                            : descriptionController.text.trim(),
                      );
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bildiriminiz admin ekibine gönderildi.'),
                    ),
                  );
                } catch (error) {
                  if (dialogContext.mounted) {
                    ScaffoldMessenger.of(
                      dialogContext,
                    ).showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                }
              },
              child: const Text('Gönder'),
            ),
          ],
        ),
      ),
    ).whenComplete(descriptionController.dispose);
  }

  Future<void> _launchExternal(String? rawUrl) async {
    if (rawUrl == null || rawUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bu bilgi mekan için eklenmemiş.')),
      );
      return;
    }
    final uri = Uri.tryParse(rawUrl);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Bağlantı açılamadı.')));
      }
    }
  }

  Future<void> _launchDirections(ApiVenue venue) async {
    final mapsUrl =
        venue.googleMapsUrl ??
        (venue.latitude != null && venue.longitude != null
            ? 'https://www.google.com/maps/search/?api=1&query='
                  '${venue.latitude},${venue.longitude}'
            : null);
    await _launchExternal(mapsUrl);
  }

  @override
  Widget build(BuildContext context) {
    final detailProvider = venueDetailProvider(widget.venueId);
    final venueAsync = ref.watch(detailProvider);

    Future<void> refreshDetail() async {
      ref.invalidate(detailProvider);
      await ref.read(detailProvider.future);
    }

    return Scaffold(
      body: venueAsync.when(
        loading: () => AppRefreshableContent(
          onRefresh: refreshDetail,
          child: const Center(
            child: CircularProgressIndicator(color: BiCikalimTheme.primary),
          ),
        ),
        error: (error, _) => AppRefreshableContent(
          onRefresh: refreshDetail,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Mekan detayları yüklenemedi: $error',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        data: (venue) {
          final eventsProvider = eventsListProvider(
            EventFilters(venueSlug: venue.slug),
          );
          final reviewsProvider = venueReviewsProvider(venue.id);
          final activitiesProvider = venueActivitiesProvider(venue.slug);
          final eventsAsync = ref.watch(eventsProvider);
          final reviewsAsync = ref.watch(reviewsProvider);
          final activitiesAsync = ref.watch(activitiesProvider);
          final isFavorite = _favoriteOverride ?? venue.isFavorite;

          Future<void> refreshVenuePage() async {
            ref
              ..invalidate(detailProvider)
              ..invalidate(eventsProvider)
              ..invalidate(reviewsProvider)
              ..invalidate(activitiesProvider);
            await Future.wait([
              ref.read(detailProvider.future),
              ref.read(eventsProvider.future),
              ref.read(reviewsProvider.future),
              ref.read(activitiesProvider.future),
            ]);
            if (mounted) {
              setState(() => _favoriteOverride = null);
            }
          }

          return RefreshIndicator(
            color: BiCikalimTheme.primary,
            onRefresh: refreshVenuePage,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.vertical &&
                notification.depth <= 2,
            child: NestedScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 240,
                    pinned: true,
                    backgroundColor: BiCikalimTheme.primary,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: AppNetworkImage(
                              imageUrl: venue.coverImageUrl,
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.85),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildMetaPill(
                              Icons.star_rounded,
                              '${venue.averageRating} puan',
                            ),
                            _buildMetaPill(
                              Icons.chat_bubble_outline,
                              '${venue.reviewCount} yorum',
                            ),
                            _buildMetaPill(
                              Icons.category_outlined,
                              '${venue.activitySummary.length} aktivite',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: venue.verificationStatus == 'verified'
                                  ? BiCikalimTheme.success.withValues(
                                      alpha: 0.1,
                                    )
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  venue.verificationStatus == 'verified'
                                      ? Icons.verified
                                      : Icons.help_outline,
                                  color: venue.verificationStatus == 'verified'
                                      ? BiCikalimTheme.success
                                      : Colors.grey,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    venue.verificationStatus == 'verified'
                                        ? 'Onaylı Mekan'
                                        : 'Doğrulanmamış',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          venue.verificationStatus == 'verified'
                                          ? BiCikalimTheme.success
                                          : Colors.grey.shade700,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: BiCikalimTheme.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                venue.address ??
                                    '${venue.districtName}, ${venue.cityName}',
                                style: const TextStyle(
                                  color: BiCikalimTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildQuickAction(
                              Icons.directions,
                              'Yol Tarifi',
                              () => _launchDirections(venue),
                            ),
                            _buildQuickAction(
                              Icons.phone,
                              'Ara',
                              () => _launchExternal(
                                venue.phone == null
                                    ? null
                                    : 'tel:${venue.phone}',
                              ),
                            ),
                            _buildQuickAction(
                              Icons.camera_alt,
                              'Instagram',
                              () => _launchExternal(venue.instagramUrl),
                            ),
                            _buildQuickAction(
                              isFavorite
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              isFavorite ? 'Kaydedildi' : 'Kaydet',
                              () => _toggleFavorite(venue),
                            ),
                            _buildQuickAction(
                              Icons.flag_outlined,
                              'Bildir',
                              () => _showReportDialog(venue),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: BiCikalimTheme.primary,
                    unselectedLabelColor: BiCikalimTheme.textSecondary,
                    indicatorColor: BiCikalimTheme.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Genel'),
                      Tab(text: 'Aktiviteler'),
                      Tab(text: 'Etkinlikler'),
                      Tab(text: 'Yorumlar'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildGeneralTab(venue),
                        activitiesAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => AppEmptyState(
                            icon: Icons.sports_esports_outlined,
                            message: 'Aktiviteler yüklenemedi.\n$error',
                          ),
                          data: _buildActivitiesTab,
                        ),
                        eventsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(
                            child: Text('Etkinlikler yüklenemedi: $err'),
                          ),
                          data: (events) => _buildEventsTab(events, venue),
                        ),
                        reviewsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) =>
                              Center(child: Text('Yorumlar yüklenemedi: $err')),
                          data: (reviews) => _buildReviewsTab(reviews, venue),
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
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Icon(icon, color: BiCikalimTheme.primary, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BiCikalimTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: BiCikalimTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: BiCikalimTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ApiVenue venue) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hakkında',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            venue.description ?? 'Açıklama bulunmuyor.',
            style: const TextStyle(
              color: BiCikalimTheme.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Çalışma Saatleri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (venue.openingHours.isEmpty)
            const Text(
              'Hafta İçi & Hafta Sonu: 09:00 - 23:00 (Varsayılan)',
              style: TextStyle(color: BiCikalimTheme.textSecondary),
            )
          else
            ...venue.openingHours.map((oh) {
              final days = [
                'Pazartesi',
                'Salı',
                'Çarşamba',
                'Perşembe',
                'Cuma',
                'Cumartesi',
                'Pazar',
              ];
              final dayName = oh.dayOfWeek >= 1 && oh.dayOfWeek <= 7
                  ? days[oh.dayOfWeek - 1]
                  : 'Gün';
              final timeStr = oh.isClosed
                  ? 'Kapalı'
                  : '${oh.opensAt ?? "09:00"} - ${oh.closesAt ?? "23:00"}';
              return _buildInfoRow(dayName, timeStr);
            }),
          const SizedBox(height: 24),
          const Text(
            'Mekan Özellikleri',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: venue.tags.isEmpty
                ? [
                    _buildFeatureChip('Grup dostu'),
                    _buildFeatureChip('Rezervasyon uygun'),
                  ]
                : venue.tags.map((t) => _buildFeatureChip(t.name)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: BiCikalimTheme.textSecondary),
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Chip(
      backgroundColor: Colors.grey.shade50,
      side: BorderSide(color: Colors.grey.shade200),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: BiCikalimTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildActivitiesTab(List<ApiVenueActivitySummary> activities) {
    if (activities.isEmpty) {
      return const AppEmptyState(
        icon: Icons.notes,
        message: 'Bu mekana ait aktivite envanteri henüz eklenmemiş.',
        padding: EdgeInsets.all(32),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: activities.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _buildCompactInventoryRow(activities[index]),
    );
  }

  Widget _buildCompactInventoryRow(ApiVenueActivitySummary item) {
    final availabilityLabel = switch (item.availability) {
      'unavailable' => 'Kullanılamıyor',
      'seasonal' => 'Sezonluk',
      'coming_soon' => 'Yakında',
      _ => 'Mevcut',
    };
    final priceLabel = item.isFree
        ? 'Ücretsiz'
        : item.price == null
        ? 'Ücretli'
        : '${item.price!.toStringAsFixed(0)} TRY'
              '${item.priceUnit == null ? '' : ' / ${item.priceUnit}'}';
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.sports_esports_outlined)),
        title: Text(
          item.activityName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          [
            availabilityLabel,
            priceLabel,
            if (item.shortDescription != null) item.shortDescription!,
          ].join(' • '),
        ),
      ),
    );
  }

  Widget _buildEventsTab(List<ApiEvent> events, ApiVenue venue) {
    if (events.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_busy,
        message: 'Yakın zamanda planlanmış etkinlik bulunmuyor.',
        padding: EdgeInsets.all(32),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return EventListCard(
          event: event,
          venue: venue,
          onTap: () => context.push('/events/${event.slug}'),
        );
      },
    );
  }

  Widget _buildReviewsTab(List<ApiReview> reviews, ApiVenue venue) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '${venue.averageRating}',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: BiCikalimTheme.primary,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < venue.averageRating.floor()
                            ? Icons.star
                            : Icons.star_border,
                        color: BiCikalimTheme.primary,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${venue.reviewCount} yorum',
                    style: const TextStyle(
                      color: BiCikalimTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar(
                      5,
                      reviews.where((r) => r.rating == 5).length /
                          (reviews.isEmpty ? 1 : reviews.length),
                    ),
                    _buildRatingBar(
                      4,
                      reviews.where((r) => r.rating == 4).length /
                          (reviews.isEmpty ? 1 : reviews.length),
                    ),
                    _buildRatingBar(
                      3,
                      reviews.where((r) => r.rating == 3).length /
                          (reviews.isEmpty ? 1 : reviews.length),
                    ),
                    _buildRatingBar(
                      2,
                      reviews.where((r) => r.rating == 2).length /
                          (reviews.isEmpty ? 1 : reviews.length),
                    ),
                    _buildRatingBar(
                      1,
                      reviews.where((r) => r.rating == 1).length /
                          (reviews.isEmpty ? 1 : reviews.length),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kullanıcı Yorumları',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                icon: const Icon(
                  Icons.rate_review,
                  size: 16,
                  color: BiCikalimTheme.primary,
                ),
                label: const Text(
                  'Yorum Yaz',
                  style: TextStyle(color: BiCikalimTheme.primary),
                ),
                onPressed: () => _showAddReviewDialog(venue),
              ),
            ],
          ),
        ),
        Expanded(
          child: reviews.isEmpty
              ? const AppEmptyState(
                  icon: Icons.rate_review_outlined,
                  message: 'Bu mekan için henüz yorum yapılmamış.',
                  padding: EdgeInsets.all(32),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: BiCikalimTheme.primary
                                    .withValues(alpha: 0.08),
                                radius: 18,
                                child: Text(
                                  review.userDisplayName[0],
                                  style: const TextStyle(
                                    color: BiCikalimTheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.userDisplayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    Row(
                                      children: List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < review.rating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: BiCikalimTheme.primary,
                                          size: 12,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            review.comment ?? '',
                            style: const TextStyle(
                              color: BiCikalimTheme.textSecondary,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: Colors.grey.shade100),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double ratio) {
    return Row(
      children: [
        Text(
          '$stars',
          style: const TextStyle(
            fontSize: 11,
            color: BiCikalimTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                BiCikalimTheme.primary,
              ),
              minHeight: 6,
            ),
          ),
        ),
      ],
    );
  }
}

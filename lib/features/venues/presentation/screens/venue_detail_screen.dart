import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/utils/app_url_launcher.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';
import '../../../../shared/widgets/event_list_card.dart';
import '../../../auth/presentation/providers/user_session_provider.dart';

class VenueDetailScreen extends ConsumerStatefulWidget {
  final String venueId;

  const VenueDetailScreen({super.key, required this.venueId});

  @override
  ConsumerState<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends ConsumerState<VenueDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _inventorySearchController = TextEditingController();
  bool _isTogglingFavorite = false;
  bool? _favoriteOverride;
  String _inventoryQuery = '';
  bool _showAllInventoryActivities = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _inventorySearchController.dispose();
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

  void _showAddReviewDialog(
    ApiVenue venue, {
    ApiReview? existing,
    String? initialActivityId,
  }) {
    int rating = existing?.rating ?? 5;
    String? activityId = existing?.activityId ?? initialActivityId;
    var isSubmitting = false;
    final commentController = TextEditingController(
      text: existing?.comment ?? '',
    );
    final pageContext = context;

    showDialog<void>(
      context: pageContext,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(
                horizontal: context.layout.screenPadding,
                vertical: context.layout.sectionGap,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.layout.cardRadius),
              ),
              title: Text(existing == null ? 'Yorum Yaz' : 'Yorumunu Düzenle'),
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
                            if (existing == null) {
                              await service.createReview(
                                venue.id,
                                rating,
                                commentController.text,
                                activityId: activityId,
                              );
                            } else {
                              await service.updateMyReview(
                                venue.id,
                                rating,
                                commentController.text,
                                activityId: existing.activityId,
                              );
                            }
                            reviewCreated = true;
                            if (!mounted || !dialogContext.mounted) return;
                            Navigator.pop(dialogContext);
                            ScaffoldMessenger.of(pageContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  existing == null
                                      ? 'Yorumunuz başarıyla eklendi.'
                                      : 'Yorumunuz güncellendi.',
                                ),
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
          insetPadding: EdgeInsets.symmetric(
            horizontal: context.layout.screenPadding,
            vertical: context.layout.sectionGap,
          ),
          title: const Text('Mekanı Bildir'),
          content: SingleChildScrollView(
            child: Column(
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
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text(friendlyErrorMessage(error))),
                    );
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

  Future<void> _reportReview(ApiReview review) async {
    try {
      await ref
          .read(interactionApiServiceProvider)
          .createContentReport(
            targetType: 'review',
            targetId: review.id,
            reason: 'offensive',
            description: 'Bu yorumun incelenmesini istiyorum.',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorum incelemeye gönderildi.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
      }
    }
  }

  Future<void> _launchExternal(
    String? rawUrl, {
    bool allowPhone = false,
  }) async {
    await launchAppExternalUrl(
      context: context,
      rawUrl: rawUrl,
      allowedSchemes: allowPhone ? phoneUrlSchemes : webUrlSchemes,
      emptyMessage: 'Bu bilgi mekan için eklenmemiş.',
      failureMessage: 'Bağlantı açılamadı.',
    );
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

  ({String label, Color color, IconData icon}) _todayOpeningStatus(
    ApiVenue venue,
  ) {
    final weekday = DateTime.now().weekday;
    ApiVenueOpeningHour? today;
    for (final item in venue.openingHours) {
      if (item.dayOfWeek == weekday) {
        today = item;
        break;
      }
    }

    if (today == null) {
      return (
        label: 'Saat bilgisi yok',
        color: BiCikalimTheme.textSecondary,
        icon: Icons.schedule_outlined,
      );
    }
    if (today.isClosed) {
      return (
        label: 'Bugün kapalı',
        color: BiCikalimTheme.error,
        icon: Icons.schedule_outlined,
      );
    }

    final opensAt = today.opensAt;
    final closesAt = today.closesAt;
    final hours = opensAt == null || closesAt == null
        ? 'Bugün açık'
        : 'Bugün $opensAt–$closesAt';
    return (
      label: hours,
      color: BiCikalimTheme.success,
      icon: Icons.schedule_rounded,
    );
  }

  List<String> _validVenueMediaUrls(ApiVenue venue) {
    return venue.media
        .map((item) => item.publicUrl?.trim())
        .whereType<String>()
        .where((url) => url.isNotEmpty)
        .toList(growable: false);
  }

  Widget _buildPremiumSurface({
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color color = BiCikalimTheme.surface,
    Color? borderColor,
    double radius = BiCikalimTheme.radiusLarge,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(context.layout.cardPadding + 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? BiCikalimTheme.primary.withValues(alpha: .075),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .032),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStatusPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: context.layout.width - (context.layout.screenPadding * 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: .14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeading(
    String title, {
    String? subtitle,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: BiCikalimTheme.textPrimary,
                  fontSize: context.layout.sectionTitleSize,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: 11.5,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 10), trailing],
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: BiCikalimTheme.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BiCikalimTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BiCikalimTheme.textLight,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
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
              padding: EdgeInsets.all(context.layout.screenPadding),
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
          final openingStatus = _todayOpeningStatus(venue);
          final mediaUrls = _validVenueMediaUrls(venue);

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
                    expandedHeight: context.layout.fluid(168, 180, 196),
                    pinned: true,
                    backgroundColor: BiCikalimTheme.primary,
                    foregroundColor: Colors.white,
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
                          if (mediaUrls.isNotEmpty)
                            Positioned(
                              left: context.layout.screenPadding,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: .56),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .22),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.photo_library_outlined,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${mediaUrls.length} fotoğraf',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (venue.isVerified)
                            Positioned(
                              right: context.layout.screenPadding,
                              bottom: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: BiCikalimTheme.success.withValues(
                                    alpha: .92,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Onaylı Mekân',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
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
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(context.layout.cardPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  venue.name,
                                  style: TextStyle(
                                    color: BiCikalimTheme.textPrimary,
                                    fontSize: context.layout.pageTitleSize,
                                    height: 1.13,
                                    letterSpacing: -.25,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              if (venue.isVerified) ...[
                                const SizedBox(width: 8),
                                const Padding(
                                  padding: EdgeInsets.only(top: 3),
                                  child: Tooltip(
                                    message: 'Onaylı mekân',
                                    child: Icon(
                                      Icons.verified_rounded,
                                      color: BiCikalimTheme.success,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 9),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: [
                              _buildStatusPill(
                                icon: openingStatus.icon,
                                label: openingStatus.label,
                                color: openingStatus.color,
                              ),
                              _buildStatusPill(
                                icon: venue.isVerified
                                    ? Icons.verified_outlined
                                    : Icons.help_outline_rounded,
                                label: venue.isVerified
                                    ? 'Bilgileri doğrulandı'
                                    : 'Henüz doğrulanmadı',
                                color: venue.isVerified
                                    ? BiCikalimTheme.success
                                    : BiCikalimTheme.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: BiCikalimTheme.primary.withValues(
                                    alpha: .08,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: BiCikalimTheme.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'KONUM',
                                      style: TextStyle(
                                        color: BiCikalimTheme.textLight,
                                        fontSize: 10,
                                        letterSpacing: .5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      venue.address ??
                                          '${venue.districtName}, ${venue.cityName}',
                                      style: const TextStyle(
                                        color: BiCikalimTheme.textSecondary,
                                        fontSize: 12.5,
                                        height: 1.35,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 11),
                          _buildPremiumSurface(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 11,
                            ),
                            child: Row(
                              children: [
                                _buildStatItem(
                                  Icons.star_rounded,
                                  '${venue.averageRating}',
                                  'Puan',
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.shade100,
                                ),
                                _buildStatItem(
                                  Icons.chat_bubble_outline_rounded,
                                  '${venue.reviewCount}',
                                  'Yorum',
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: Colors.grey.shade100,
                                ),
                                _buildStatItem(
                                  Icons.local_activity_outlined,
                                  '${venue.activitySummary.length}',
                                  'Aktivite',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildActivityFocusPanel(venue),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: AppLayout.minTouchTarget,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                if (venue.googleMapsUrl != null ||
                                    (venue.latitude != null &&
                                        venue.longitude != null))
                                  _buildQuickAction(
                                    Icons.directions,
                                    'Yol Tarifi',
                                    () => _launchDirections(venue),
                                    emphasized: true,
                                  ),
                                if (venue.phone != null &&
                                    venue.phone!.isNotEmpty)
                                  _buildQuickAction(
                                    Icons.phone,
                                    'Ara',
                                    () => _launchExternal(
                                      'tel:${venue.phone}',
                                      allowPhone: true,
                                    ),
                                  ),
                                if (venue.websiteUrl != null &&
                                    venue.websiteUrl!.isNotEmpty)
                                  _buildQuickAction(
                                    Icons.language,
                                    'Web Sitesi',
                                    () => _launchExternal(venue.websiteUrl),
                                  ),
                                if (venue.instagramUrl != null &&
                                    venue.instagramUrl!.isNotEmpty)
                                  _buildQuickAction(
                                    Icons.camera_alt,
                                    'Instagram',
                                    () => _launchExternal(venue.instagramUrl),
                                  ),
                                _buildQuickAction(
                                  isFavorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  isFavorite ? 'Favoride' : 'Favorile',
                                  () => _toggleFavorite(venue),
                                  selected: isFavorite,
                                ),
                                _buildQuickAction(
                                  Icons.flag_outlined,
                                  'Bildir',
                                  () => _showReportDialog(venue),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: false,
                    delegate: _VenueTabBarDelegate(
                      child: SizedBox(
                        height: AppLayout.minTouchTarget,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          labelColor: BiCikalimTheme.primary,
                          unselectedLabelColor: BiCikalimTheme.textSecondary,
                          indicatorColor: BiCikalimTheme.primary,
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          tabs: const [
                            Tab(text: 'Aktiviteler'),
                            Tab(text: 'Genel'),
                            Tab(text: 'Etkinlikler'),
                            Tab(text: 'Yorumlar'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        activitiesAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (error, _) => AppErrorState(
                            error: error,
                            title: 'Aktiviteler yüklenemedi',
                            onRetry: () => ref.invalidate(
                              venueActivitiesProvider(venue.slug),
                            ),
                          ),
                          data: (activities) =>
                              _buildActivitiesTab(activities, venue),
                        ),
                        _buildGeneralTab(venue),
                        eventsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => AppErrorState(
                            error: err,
                            title: 'Etkinlikler yüklenemedi',
                            onRetry: () => ref.invalidate(
                              eventsListProvider(
                                EventFilters(venueSlug: venue.slug),
                              ),
                            ),
                          ),
                          data: (events) => _buildEventsTab(events, venue),
                        ),
                        reviewsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, _) => AppErrorState(
                            error: err,
                            title: 'Yorumlar yüklenemedi',
                            onRetry: () =>
                                ref.invalidate(venueReviewsProvider(venue.id)),
                          ),
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

  Widget _buildQuickAction(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool emphasized = false,
    bool selected = false,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(
              minHeight: AppLayout.minTouchTarget,
              minWidth: AppLayout.minTouchTarget,
            ),
            margin: EdgeInsets.only(right: context.layout.cardGap),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: emphasized || selected
                  ? BiCikalimTheme.primary.withValues(alpha: .085)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: emphasized || selected
                    ? BiCikalimTheme.primary.withValues(alpha: .18)
                    : Colors.grey.shade100,
              ),
              boxShadow: emphasized
                  ? [
                      BoxShadow(
                        color: BiCikalimTheme.primary.withValues(alpha: .08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: BiCikalimTheme.primary, size: 17),
                const SizedBox(width: 5),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: BiCikalimTheme.textPrimary,
                    height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityFocusPanel(ApiVenue venue) {
    final activities = venue.activitySummary
        .map((item) => item.activityName)
        .where((name) => name.trim().isNotEmpty)
        .take(5)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(context.layout.cardPadding),
      decoration: BoxDecoration(
        color: BiCikalimTheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(context.layout.cardRadius),
        border: Border.all(
          color: BiCikalimTheme.primary.withValues(alpha: .12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: BiCikalimTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_activity_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bu mekanda ne yapabilirsin?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      activities.isEmpty
                          ? 'Aktivite bilgileri eklenince burada görünecek.'
                          : '${activities.length} aktivite öne çıkıyor.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: BiCikalimTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (activities.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: activities
                  .map(
                    (name) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: BiCikalimTheme.primary.withValues(alpha: .14),
                        ),
                      ),
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BiCikalimTheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  _inventorySearchController.clear();
                  setState(() {
                    _inventoryQuery = '';
                    _showAllInventoryActivities = false;
                  });
                  _tabController.animateTo(0);
                },
                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                label: const Text('Aktiviteleri incele'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneralTab(ApiVenue venue) {
    final mediaUrls = _validVenueMediaUrls(venue);
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.layout.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeading(
            'Mekân hakkında',
            subtitle: 'Atmosfer, hizmetler ve temel bilgiler',
          ),
          const SizedBox(height: 9),
          _buildPremiumSurface(
            child: Text(
              venue.description ?? 'Açıklama bulunmuyor.',
              style: TextStyle(
                color: BiCikalimTheme.textPrimary,
                fontSize: context.layout.bodySize,
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (mediaUrls.isNotEmpty) ...[
            SizedBox(height: context.layout.sectionGap),
            _buildSectionHeading(
              'Galeri',
              subtitle: '${mediaUrls.length} mekân fotoğrafı',
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: context.layout.fluid(118, 124, 132),
              child: ListView.separated(
                clipBehavior: Clip.none,
                scrollDirection: Axis.horizontal,
                itemCount: mediaUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  return Container(
                    width: context.layout.fluid(164, 174, 188),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: BiCikalimTheme.primary.withValues(alpha: .08),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AppNetworkImage(
                        imageUrl: mediaUrls[index],
                        height: context.layout.fluid(118, 124, 132),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          SizedBox(height: context.layout.sectionGap),
          _buildSectionHeading(
            'Çalışma Saatleri',
            subtitle: 'Haftalık açılış ve kapanış bilgileri',
          ),
          const SizedBox(height: 9),
          _buildPremiumSurface(
            child: venue.openingHours.isEmpty
                ? const Text(
                    'Çalışma saatleri henüz eklenmemiş.',
                    style: TextStyle(color: BiCikalimTheme.textSecondary),
                  )
                : Column(
                    children: venue.openingHours.map((oh) {
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
                          : '${oh.opensAt ?? "09:00"} – ${oh.closesAt ?? "23:00"}';
                      return _buildInfoRow(dayName, timeStr);
                    }).toList(),
                  ),
          ),
          SizedBox(height: context.layout.sectionGap),
          _buildSectionHeading(
            'Mekân Özellikleri',
            subtitle: 'Atmosfer, imkânlar ve öne çıkan detaylar',
          ),
          const SizedBox(height: 9),
          _buildPremiumSurface(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: venue.tags.isEmpty
                  ? [
                      const Text(
                        'Mekân özellikleri henüz eklenmemiş.',
                        style: TextStyle(color: BiCikalimTheme.textSecondary),
                      ),
                    ]
                  : venue.tags.map((t) => _buildFeatureChip(t.name)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
      avatar: const Icon(
        Icons.check_circle_outline_rounded,
        size: 16,
        color: BiCikalimTheme.primary,
      ),
      backgroundColor: BiCikalimTheme.primary.withValues(alpha: .045),
      side: BorderSide(color: BiCikalimTheme.primary.withValues(alpha: .11)),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: BiCikalimTheme.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildActivitiesTab(
    List<ApiVenueActivitySummary> activities,
    ApiVenue venue,
  ) {
    if (activities.isEmpty) {
      return AppEmptyState(
        icon: Icons.notes,
        title: 'Bu mekânın aktivite bilgileri henüz eklenmemiş',
        message:
            'Eksik veya yanlış bir bilgi fark ettiysen bize bildirebilirsin.',
        actionLabel: 'Bilgi Bildir',
        onAction: () => _showReportDialog(venue),
        padding: EdgeInsets.all(32),
      );
    }

    final query = _inventoryQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? activities
        : activities.where((item) {
            final text = [
              item.activityName,
              item.shortDescription ?? '',
              item.availability,
              item.priceUnit ?? '',
            ].join(' ').toLowerCase();
            return text.contains(query);
          }).toList();
    final visibleActivities = _showAllInventoryActivities
        ? filtered
        : filtered.take(5).toList();
    final canLoadMore = visibleActivities.length < filtered.length;

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        context.layout.screenPadding,
        8,
        context.layout.screenPadding,
        context.layout.screenPadding,
      ),
      itemCount: visibleActivities.length + 1 + (canLoadMore ? 1 : 0),
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildPremiumSurface(
            color: BiCikalimTheme.primary.withValues(alpha: .035),
            borderColor: BiCikalimTheme.primary.withValues(alpha: .11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeading(
                  'Aktivite Envanteri',
                  subtitle: 'Fiyat, uygunluk ve güncellik bilgileri',
                  trailing: _buildInventoryPill(
                    '${activities.length} seçenek',
                    BiCikalimTheme.primary,
                  ),
                ),
                const SizedBox(height: 11),
                SizedBox(
                  height: context.layout.searchHeight,
                  child: TextField(
                    controller: _inventorySearchController,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      isDense: true,
                      hintText: 'Ne yapmak istiyorsun?',
                      prefixIcon: Icon(Icons.search_rounded, size: 19),
                      prefixIconConstraints: BoxConstraints(minWidth: 40),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) => setState(() {
                      _inventoryQuery = value;
                      _showAllInventoryActivities = false;
                    }),
                  ),
                ),
                if (filtered.isEmpty) ...[
                  const SizedBox(height: 14),
                  const AppEmptyState(
                    icon: Icons.search_off,
                    title: 'Aramana uygun aktivite bulunamadı',
                    message:
                        'Farklı bir kelime deneyebilir veya arama metnini temizleyebilirsin.',
                    padding: EdgeInsets.all(16),
                  ),
                ],
              ],
            ),
          );
        }
        if (canLoadMore && index == visibleActivities.length + 1) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  setState(() => _showAllInventoryActivities = true),
              icon: const Icon(Icons.expand_more_rounded),
              label: Text(
                '${filtered.length - visibleActivities.length} tane daha göster',
              ),
            ),
          );
        }
        return _buildInventoryCard(visibleActivities[index - 1], venue);
      },
    );
  }

  // ignore: unused_element
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

  Widget _buildInventoryCard(ApiVenueActivitySummary item, ApiVenue venue) {
    final priceLabel = _formatInventoryPrice(item);
    final verifiedLabel = _formatVerifiedAt(item.lastVerifiedAt);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: BiCikalimTheme.primary.withValues(alpha: .085)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openVenuesForInventoryActivity(item, venue),
        child: Padding(
          padding: EdgeInsets.all(context.layout.cardPadding + 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: BiCikalimTheme.primary.withValues(alpha: .085),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.local_activity_outlined,
                      color: BiCikalimTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.activityName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: context.layout.cardTitleSize,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: BiCikalimTheme.textLight,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  _buildInventoryPill(
                    _availabilityLabel(item.availability),
                    _availabilityColor(item.availability),
                  ),
                  _buildInventoryPill(
                    priceLabel,
                    item.isFree
                        ? BiCikalimTheme.success
                        : BiCikalimTheme.primary,
                  ),
                ],
              ),
              if (item.shortDescription != null &&
                  item.shortDescription!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  item.shortDescription!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: BiCikalimTheme.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (verifiedLabel != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: BiCikalimTheme.textLight,
                      size: 15,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        verifiedLabel,
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: 10.5,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Divider(
                  height: 1,
                  color: BiCikalimTheme.primary.withValues(alpha: .07),
                ),
              ),
              Wrap(
                spacing: 2,
                runSpacing: 2,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _openVenuesForInventoryActivity(item, venue),
                    style: _compactInventoryActionStyle(),
                    icon: const Icon(Icons.explore_outlined, size: 15),
                    label: const Text('Diğer Mekânlar'),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddReviewDialog(
                      venue,
                      initialActivityId: item.activityId,
                    ),
                    style: _compactInventoryActionStyle(),
                    icon: const Icon(Icons.rate_review_outlined, size: 15),
                    label: const Text('Yorum Yaz'),
                  ),
                  TextButton.icon(
                    onPressed: () => _reportInventoryItem(venue, item),
                    style: _compactInventoryActionStyle(),
                    icon: const Icon(Icons.flag_outlined, size: 15),
                    label: const Text('Bilgi Bildir'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ButtonStyle _compactInventoryActionStyle() {
    return TextButton.styleFrom(
      minimumSize: const Size(0, AppLayout.minTouchTarget),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
    );
  }

  Widget _buildInventoryPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _availabilityLabel(String value) {
    return switch (value) {
      'available' => 'Mevcut',
      'unavailable' => 'Şu anda kullanılamıyor',
      'seasonal' => 'Sezonluk',
      'coming_soon' => 'Yakında',
      _ => 'Durum bilgisi var',
    };
  }

  Color _availabilityColor(String value) {
    return switch (value) {
      'available' => BiCikalimTheme.success,
      'unavailable' => BiCikalimTheme.error,
      'seasonal' => BiCikalimTheme.warning,
      'coming_soon' => BiCikalimTheme.textSecondary,
      _ => BiCikalimTheme.textSecondary,
    };
  }

  String _formatInventoryPrice(ApiVenueActivitySummary item) {
    if (item.isFree) return 'Ücretsiz';
    final price = item.price;
    if (price == null) return 'Ücretli';
    final number = price.truncateToDouble() == price
        ? price.toStringAsFixed(0)
        : price.toStringAsFixed(2).replaceFirst(RegExp(r'0$'), '');
    final unit = item.priceUnit == null || item.priceUnit!.isEmpty
        ? ''
        : ' / ${_priceUnitLabel(item.priceUnit!)}';
    return '$number TL$unit';
  }

  String _priceUnitLabel(String value) {
    return switch (value) {
      'hour' || 'per_hour' => 'saat',
      'person' || 'per_person' => 'kişi',
      'game' || 'per_game' => 'oyun',
      'session' || 'per_session' => 'seans',
      _ => value,
    };
  }

  String? _formatVerifiedAt(DateTime? value) {
    if (value == null) return null;
    const months = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    final local = value.toLocal();
    final label = '${local.day} ${months[local.month - 1]} ${local.year}';
    final stale = DateTime.now().difference(local).inDays > 180;
    if (stale) {
      return 'Son doğrulama: $label. Bu bilgi bir süredir doğrulanmadı.';
    }
    return 'Son doğrulama: $label';
  }

  void _openVenuesForInventoryActivity(
    ApiVenueActivitySummary item,
    ApiVenue venue,
  ) {
    final citySlug = ref.read(selectedCityProvider).value?.slug;
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {
          'scope': 'activity',
          'activitySlug': item.activitySlug,
          'title': '${item.activityName} Yapabileceğin Mekanlar',
          'currentVenueId': venue.id,
          'citySlug': ?citySlug,
        },
      ).toString(),
    );
  }

  Future<void> _reportInventoryItem(
    ApiVenue venue,
    ApiVenueActivitySummary item,
  ) async {
    try {
      await ref
          .read(interactionApiServiceProvider)
          .createContentReport(
            targetType: 'venue',
            targetId: venue.id,
            reason: 'incorrect_info',
            description:
                'Aktivite envanteri bilgisi kontrol edilsin: '
                '${item.activityName} (${item.activityId}).',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bildirimin için teşekkürler. Ekibimiz bilgiyi kontrol edecek.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
    }
  }

  Widget _buildEventsTab(List<ApiEvent> events, ApiVenue venue) {
    if (events.isEmpty) {
      return const AppEmptyState(
        icon: Icons.event_busy,
        title: 'Şu anda yayınlanmış bir etkinlik bulunmuyor',
        message:
            'Yine de bu mekânda yapabileceğin aktiviteleri inceleyebilirsin.',
        padding: EdgeInsets.all(32),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(context.layout.screenPadding),
      itemCount: events.length + 1,
      separatorBuilder: (_, index) =>
          SizedBox(height: index == 0 ? 10 : context.layout.cardGap),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildPremiumSurface(
            color: BiCikalimTheme.primary.withValues(alpha: .035),
            borderColor: BiCikalimTheme.primary.withValues(alpha: .1),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.event_available_outlined,
                    color: BiCikalimTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildSectionHeading(
                    'Yaklaşan Etkinlikler',
                    subtitle: '${events.length} yayınlanmış etkinlik',
                  ),
                ),
              ],
            ),
          );
        }
        final event = events[index - 1];
        return EventListCard(
          event: event,
          venue: venue,
          onTap: () => context.push('/events/${event.slug}'),
        );
      },
    );
  }

  Widget _buildReviewsTab(List<ApiReview> reviews, ApiVenue venue) {
    final currentUser = ref.watch(currentUserProvider);
    ApiReview? myReview;
    if (currentUser != null) {
      for (final review in reviews) {
        if (review.userId == currentUser.id && review.activityId == null) {
          myReview = review;
          break;
        }
      }
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            context.layout.screenPadding,
            8,
            context.layout.screenPadding,
            6,
          ),
          child: _buildPremiumSurface(
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
        ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.layout.screenPadding,
            vertical: 8,
          ),
          child: _buildSectionHeading(
            'Kullanıcı Yorumları',
            subtitle: reviews.isEmpty
                ? 'İlk deneyimini sen paylaş'
                : '${reviews.length} değerlendirme',
            trailing: TextButton.icon(
              icon: const Icon(
                Icons.rate_review,
                size: 16,
                color: BiCikalimTheme.primary,
              ),
              label: Text(
                myReview == null ? 'Yorum Yaz' : 'Yorumunu Düzenle',
                style: const TextStyle(color: BiCikalimTheme.primary),
              ),
              onPressed: () => _showAddReviewDialog(venue, existing: myReview),
            ),
          ),
        ),
        Expanded(
          child: reviews.isEmpty
              ? const AppEmptyState(
                  icon: Icons.rate_review_outlined,
                  message: 'Bu mekan için henüz yorum yapılmamış.',
                  padding: EdgeInsets.all(32),
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    context.layout.screenPadding,
                    8,
                    context.layout.screenPadding,
                    context.layout.screenPadding,
                  ),
                  itemCount: reviews.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _buildPremiumSurface(
                      padding: EdgeInsets.all(context.layout.cardPadding + 2),
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
                              if (currentUser?.id != review.userId)
                                IconButton(
                                  tooltip: 'Yorumu bildir',
                                  onPressed: () => _reportReview(review),
                                  icon: const Icon(
                                    Icons.flag_outlined,
                                    size: 19,
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

class _VenueTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _VenueTabBarDelegate({required this.child});

  @override
  double get minExtent => AppLayout.minTouchTarget;

  @override
  double get maxExtent => AppLayout.minTouchTarget;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(color: BiCikalimTheme.background, child: child);
  }

  @override
  bool shouldRebuild(covariant _VenueTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/utils/app_url_launcher.dart';
import '../../../../shared/widgets/app_error_state.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventSlug;

  const EventDetailScreen({super.key, required this.eventSlug});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  bool? _favorite;
  String? _attendance;
  bool _busy = false;

  Future<void> _toggleFavorite(ApiEvent event) async {
    if (_busy) return;
    final previous = _favorite ?? event.isFavorite;
    setState(() {
      _favorite = !previous;
      _busy = true;
    });
    try {
      final service = ref.read(eventApiServiceProvider);
      final result = !previous
          ? await service.addFavoriteEvent(event.id)
          : await service.removeFavoriteEvent(event.id);
      _favorite = result;
      ref
          .read(analyticsApiServiceProvider)
          .track(
            eventName: AnalyticsEventName.favorite,
            eventRefId: event.id,
            properties: {
              'target_type': 'event',
              'action': result ? 'add' : 'remove',
            },
          );
      ref.invalidate(favoriteEventsProvider);
    } catch (error) {
      _favorite = previous;
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _setAttendance(ApiEvent event, String? status) async {
    if (_busy) return;
    final previous = _attendance ?? event.attendanceStatus;
    setState(() {
      _attendance = status;
      _busy = true;
    });
    try {
      if (status == null) {
        await ref.read(eventApiServiceProvider).deleteAttendance(event.id);
      } else {
        await ref.read(eventApiServiceProvider).setAttendance(event.id, status);
      }
    } catch (error) {
      _attendance = previous;
      _showError(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(friendlyErrorMessage(error))));
  }

  Future<void> _openUrl(String? value) async {
    await launchAppExternalUrl(
      context: context,
      rawUrl: value,
      allowedSchemes: webUrlSchemes,
      failureMessage: 'Bağlantı açılamadı.',
    );
  }

  Future<void> _reportEvent(ApiEvent event) async {
    try {
      await ref
          .read(interactionApiServiceProvider)
          .createContentReport(
            targetType: 'event',
            targetId: event.id,
            reason: 'incorrect_info',
            description: 'Etkinlik bilgilerinin kontrol edilmesini istiyorum.',
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik incelemeye gönderildi.')),
        );
      }
    } catch (error) {
      _showError(error);
    }
  }

  void _openActivityVenues(ApiEventActivitySummary activity, ApiEvent event) {
    final citySlug = ref.read(selectedCityProvider).value?.slug;
    context.push(
      Uri(
        path: '/discover/results',
        queryParameters: {
          'scope': 'activity',
          'activitySlug': activity.slug,
          'citySlug': citySlug ?? event.city.slug,
          'title': '${activity.name} Yapabileceğin Mekânlar',
        },
      ).toString(),
    );
  }

  String _formatEventDateTime(BuildContext context, DateTime value) {
    final local = value.toLocal();
    const months = [
      'Oca',
      'Şub',
      'Mar',
      'Nis',
      'May',
      'Haz',
      'Tem',
      'Ağu',
      'Eyl',
      'Eki',
      'Kas',
      'Ara',
    ];
    final time = TimeOfDay.fromDateTime(local).format(context);
    return '${local.day} ${months[local.month - 1]} $time';
  }

  Widget _buildHero(BuildContext context, ApiEvent event) {
    if (event.coverUrl == null) return const SizedBox.shrink();

    final layout = context.layout;
    final galleryCount = event.media
        .where((item) => item.publicUrl?.trim().isNotEmpty ?? false)
        .length;
    final radius = BorderRadius.circular(BiCikalimTheme.radiusLarge + 2);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        layout.screenPadding,
        4,
        layout.screenPadding,
        0,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: SizedBox(
            height: layout.fluid(176, 188, 204),
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppNetworkImage(
                  imageUrl: event.coverUrl!,
                  semanticLabel: '${event.title} etkinlik görseli',
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x8A000000)],
                      stops: [.52, 1],
                    ),
                  ),
                ),
                if (event.activities.isNotEmpty)
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _buildImageBadge(
                      Icons.local_activity_outlined,
                      event.activities.first.name,
                    ),
                  ),
                if (galleryCount > 0)
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _buildImageBadge(
                      Icons.photo_library_outlined,
                      '$galleryCount fotoğraf',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageBadge(IconData icon, String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 170),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: .58),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurface(
    BuildContext context, {
    required Widget child,
    EdgeInsetsGeometry? padding,
    Color color = BiCikalimTheme.surface,
    Color? borderColor,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(context.layout.cardPadding + 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(BiCikalimTheme.radiusLarge),
        border: Border.all(
          color: borderColor ?? BiCikalimTheme.primary.withValues(alpha: .075),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    String? eyebrow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow.toUpperCase(),
            style: const TextStyle(
              color: BiCikalimTheme.primary,
              fontSize: 10.5,
              letterSpacing: .8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Text(
          title,
          style: TextStyle(
            color: BiCikalimTheme.textPrimary,
            fontSize: context.layout.sectionTitleSize,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color iconColor = BiCikalimTheme.primary,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: iconColor),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: BiCikalimTheme.textLight,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: BiCikalimTheme.textPrimary,
                  fontSize: 13.5,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVenueCard(BuildContext context, ApiEvent event) {
    final venue = event.venue;
    if (venue == null) {
      return _buildSurface(
        context,
        child: _buildDetailRow(
          icon: Icons.location_on_outlined,
          label: 'KONUM',
          value: event.city.name,
        ),
      );
    }

    final radius = BorderRadius.circular(BiCikalimTheme.radiusLarge);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .035),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: BiCikalimTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: BiCikalimTheme.primary.withValues(alpha: .075),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/venues/${venue.slug}'),
          child: Padding(
            padding: EdgeInsets.all(context.layout.cardPadding + 4),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: BiCikalimTheme.primary.withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: BiCikalimTheme.primary,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MEKÂN',
                        style: TextStyle(
                          color: BiCikalimTheme.textLight,
                          fontSize: 10.5,
                          letterSpacing: .5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        venue.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BiCikalimTheme.textPrimary,
                          fontSize: 14,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        event.city.name,
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: BiCikalimTheme.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = eventDetailProvider(widget.eventSlug);
    final eventAsync = ref.watch(provider);

    Future<void> refreshEvent() async {
      ref.invalidate(provider);
      await ref.read(provider.future);
      if (mounted) {
        setState(() {
          _favorite = null;
          _attendance = null;
        });
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Etkinlik Detayı')),
      body: eventAsync.when(
        loading: () => AppRefreshableContent(
          onRefresh: refreshEvent,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (error, _) => AppRefreshableContent(
          onRefresh: refreshEvent,
          child: AppErrorState(
            error: error,
            title: 'Etkinlik yüklenemedi',
            onRetry: refreshEvent,
            showHomeAction: true,
          ),
        ),
        data: (event) {
          final isFavorite = _favorite ?? event.isFavorite;
          final attendance = _attendance ?? event.attendanceStatus;
          final description =
              (event.description ?? event.shortDescription ?? '').trim();
          final hasSupplementalInfo =
              event.ageLimit != null || event.doorsOpenAt != null;
          final mediaUrls = event.media
              .map((item) => item.publicUrl?.trim())
              .whereType<String>()
              .where((url) => url.isNotEmpty)
              .toList(growable: false);
          return RefreshIndicator(
            color: BiCikalimTheme.primary,
            onRefresh: refreshEvent,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: context.layout.sectionGap),
              children: [
                _buildHero(context, event),
                Padding(
                  padding: EdgeInsets.all(context.layout.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          color: BiCikalimTheme.textPrimary,
                          fontSize: context.layout.pageTitleSize,
                          height: 1.14,
                          letterSpacing: -.3,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSurface(
                        context,
                        child: Column(
                          children: [
                            _buildDetailRow(
                              icon: Icons.calendar_month_rounded,
                              label: 'TARİH VE SAAT',
                              value: _formatEventDateTime(
                                context,
                                event.startAt,
                              ),
                            ),
                            if (event.hasPublicPriceInfo) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 11,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: BiCikalimTheme.primary.withValues(
                                    alpha: .08,
                                  ),
                                ),
                              ),
                              _buildDetailRow(
                                icon: event.priceType.toLowerCase() == 'free'
                                    ? Icons.celebration_outlined
                                    : Icons.payments_outlined,
                                label: 'KATILIM',
                                value: event.priceInfo,
                                iconColor:
                                    event.priceType.toLowerCase() == 'free'
                                    ? BiCikalimTheme.success
                                    : BiCikalimTheme.primary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildVenueCard(context, event),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: context.layout.sectionGap),
                        _buildSectionTitle(
                          context,
                          'Etkinlik hakkında',
                          eyebrow: 'Detaylar',
                        ),
                        const SizedBox(height: 9),
                        _buildSurface(
                          context,
                          child: Text(
                            description,
                            style: TextStyle(
                              color: BiCikalimTheme.textPrimary,
                              fontSize: context.layout.bodySize,
                              height: 1.55,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      if (hasSupplementalInfo) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (event.ageLimit != null)
                              Chip(
                                avatar: const Icon(
                                  Icons.person_outline,
                                  size: 17,
                                  color: BiCikalimTheme.primary,
                                ),
                                label: Text('${event.ageLimit}+ yaş'),
                                backgroundColor: BiCikalimTheme.primary
                                    .withValues(alpha: .055),
                              ),
                            if (event.doorsOpenAt != null)
                              Chip(
                                avatar: const Icon(
                                  Icons.door_front_door_outlined,
                                  size: 17,
                                  color: BiCikalimTheme.primary,
                                ),
                                label: Text(
                                  'Kapı: ${TimeOfDay.fromDateTime(event.doorsOpenAt!.toLocal()).format(context)}',
                                ),
                                backgroundColor: BiCikalimTheme.primary
                                    .withValues(alpha: .055),
                              ),
                          ],
                        ),
                      ],
                      if (event.activities.isNotEmpty) ...[
                        SizedBox(height: context.layout.sectionGap),
                        _buildSectionTitle(context, 'Aktiviteler'),
                        const SizedBox(height: 9),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: event.activities
                              .map(
                                (activity) => Chip(
                                  label: Text(activity.name),
                                  avatar: const Icon(
                                    Icons.local_activity_outlined,
                                    size: 16,
                                    color: BiCikalimTheme.primary,
                                  ),
                                  backgroundColor: BiCikalimTheme.primary
                                      .withValues(alpha: .055),
                                  side: BorderSide(
                                    color: BiCikalimTheme.primary.withValues(
                                      alpha: .13,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        _buildSurface(
                          context,
                          color: BiCikalimTheme.primary.withValues(alpha: .045),
                          borderColor: BiCikalimTheme.primary.withValues(
                            alpha: .12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: BiCikalimTheme.primary.withValues(
                                        alpha: .1,
                                      ),
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                    child: const Icon(
                                      Icons.explore_outlined,
                                      color: BiCikalimTheme.primary,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Bunu başka nerede yapabilirsin?',
                                      style: TextStyle(
                                        color: BiCikalimTheme.textPrimary,
                                        fontSize: 14,
                                        height: 1.25,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: event.activities
                                    .map(
                                      (activity) => OutlinedButton.icon(
                                        onPressed: () => _openActivityVenues(
                                          activity,
                                          event,
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          backgroundColor: Colors.white,
                                          minimumSize: const Size(44, 40),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.storefront_outlined,
                                          size: 16,
                                        ),
                                        label: Text(
                                          '${activity.name} mekânları',
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (mediaUrls.isNotEmpty) ...[
                        SizedBox(height: context.layout.sectionGap),
                        _buildSectionTitle(
                          context,
                          'Etkinlikten kareler',
                          eyebrow: 'Galeri',
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: context.layout.fluid(118, 124, 132),
                          child: ListView.separated(
                            clipBehavior: Clip.none,
                            scrollDirection: Axis.horizontal,
                            itemCount: mediaUrls.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 10),
                            itemBuilder: (_, index) {
                              final url = mediaUrls[index];
                              return Container(
                                width: context.layout.fluid(164, 174, 188),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: BiCikalimTheme.primary.withValues(
                                      alpha: .08,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: .055,
                                      ),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AppNetworkImage(
                                    imageUrl: url,
                                    height: context.layout.fluid(118, 124, 132),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      SizedBox(height: context.layout.sectionGap),
                      _buildSectionTitle(
                        context,
                        'Katılım durumun',
                        eyebrow: 'Planın',
                      ),
                      const SizedBox(height: 9),
                      _buildSurface(
                        context,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bu etkinlik için planını seç',
                              style: TextStyle(
                                color: BiCikalimTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                FilterChip(
                                  selected: attendance == 'interested',
                                  avatar: const Icon(
                                    Icons.star_border_rounded,
                                    size: 17,
                                  ),
                                  label: const Text('İlgileniyorum'),
                                  onSelected: _busy
                                      ? null
                                      : (selected) => _setAttendance(
                                          event,
                                          selected ? 'interested' : null,
                                        ),
                                ),
                                FilterChip(
                                  selected: attendance == 'going',
                                  avatar: const Icon(
                                    Icons.check_circle_outline_rounded,
                                    size: 17,
                                  ),
                                  label: const Text('Katılıyorum'),
                                  onSelected: _busy
                                      ? null
                                      : (selected) => _setAttendance(
                                          event,
                                          selected ? 'going' : null,
                                        ),
                                ),
                                FilterChip(
                                  selected: attendance == 'not_going',
                                  avatar: const Icon(
                                    Icons.event_busy_outlined,
                                    size: 17,
                                  ),
                                  label: const Text('Katılamıyorum'),
                                  onSelected: _busy
                                      ? null
                                      : (selected) => _setAttendance(
                                          event,
                                          selected ? 'not_going' : null,
                                        ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Divider(
                                height: 1,
                                color: BiCikalimTheme.primary.withValues(
                                  alpha: .08,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _busy
                                        ? null
                                        : () => _toggleFavorite(event),
                                    icon: Icon(
                                      isFavorite
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 19,
                                    ),
                                    label: Text(
                                      isFavorite ? 'Kaydedildi' : 'Kaydet',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: _busy
                                        ? null
                                        : () => _reportEvent(event),
                                    icon: const Icon(
                                      Icons.flag_outlined,
                                      size: 18,
                                    ),
                                    label: const Text('Bildir'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (event.ticketUrl != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: BiCikalimTheme.primary.withValues(
                                  alpha: .2,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 7),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: FilledButton.icon(
                              onPressed: () => _openUrl(event.ticketUrl),
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.confirmation_number_outlined,
                              ),
                              label: const Text('Bilet detaylarını aç'),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

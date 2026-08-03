import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/app_density.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
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
    final uri = value == null ? null : Uri.tryParse(value);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showError('Bağlantı açılamadı.');
    }
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
          return RefreshIndicator(
            color: BiCikalimTheme.primary,
            onRefresh: refreshEvent,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              children: [
                if (event.coverUrl != null)
                  AppNetworkImage(
                    imageUrl: event.coverUrl!,
                    width: double.infinity,
                    height: AppDensity.value(
                      context,
                      compact: 176,
                      standard: 194,
                      wide: 208,
                    ),
                  ),
                Padding(
                  padding: AppDensity.screenInsets(
                    context,
                    top: 14,
                    bottom: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: AppDensity.value(
                                context,
                                compact: 24,
                                standard: 26,
                                wide: 27,
                              ),
                              height: 1.12,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${event.startAt.toLocal()} • ${event.city.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (event.venue != null) ...[
                        const SizedBox(height: 6),
                        ListTile(
                          dense: true,
                          minVerticalPadding: 6,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.storefront_outlined),
                          title: Text(
                            event.venue!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () =>
                              context.push('/venues/${event.venue!.slug}'),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        event.description ?? event.shortDescription ?? '',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(height: 1.34),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Chip(
                            visualDensity: VisualDensity.compact,
                            avatar: const Icon(
                              Icons.payments_outlined,
                              size: 18,
                            ),
                            label: Text(event.priceInfo),
                          ),
                          if (event.ageLimit != null)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              avatar: const Icon(
                                Icons.person_outline,
                                size: 18,
                              ),
                              label: Text('${event.ageLimit}+ yaş'),
                            ),
                          if (event.doorsOpenAt != null)
                            Chip(
                              visualDensity: VisualDensity.compact,
                              avatar: const Icon(
                                Icons.door_front_door_outlined,
                                size: 18,
                              ),
                              label: Text(
                                'Kapı: ${TimeOfDay.fromDateTime(event.doorsOpenAt!.toLocal()).format(context)}',
                              ),
                            ),
                        ],
                      ),
                      if (event.activities.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: event.activities
                              .map(
                                (activity) => Chip(
                                  visualDensity: VisualDensity.compact,
                                  label: Text(activity.name),
                                  avatar: const Icon(
                                    Icons.local_activity_outlined,
                                    size: 17,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: BiCikalimTheme.primary.withValues(
                              alpha: .06,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bunu başka nerede yapabilirsin?',
                                style: TextStyle(
                                  color: BiCikalimTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: event.activities
                                    .map(
                                      (activity) => OutlinedButton.icon(
                                        onPressed: () => _openActivityVenues(
                                          activity,
                                          event,
                                        ),
                                        icon: const Icon(
                                          Icons.storefront_outlined,
                                          size: 17,
                                        ),
                                        label: Text(
                                          '${activity.name} mekanları',
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (event.ticketUrl != null ||
                          event.reservationUrl != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (event.ticketUrl != null)
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _openUrl(event.ticketUrl),
                                  icon: const Icon(
                                    Icons.confirmation_number_outlined,
                                  ),
                                  label: const Text('Bilet'),
                                ),
                              ),
                            if (event.ticketUrl != null &&
                                event.reservationUrl != null)
                              const SizedBox(width: 10),
                            if (event.reservationUrl != null)
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _openUrl(event.reservationUrl),
                                  icon: const Icon(Icons.event_available),
                                  label: const Text('Rezervasyon'),
                                ),
                              ),
                          ],
                        ),
                      ],
                      if (event.media.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Etkinlikten kareler',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: AppDensity.value(
                            context,
                            compact: 112,
                            standard: 124,
                            wide: 132,
                          ),
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: event.media.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, index) {
                              final url = event.media[index].publicUrl;
                              return url == null
                                  ? const SizedBox.shrink()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: AppNetworkImage(
                                        imageUrl: url,
                                        width: AppDensity.value(
                                          context,
                                          compact: 158,
                                          standard: 176,
                                          wide: 188,
                                        ),
                                        height: AppDensity.value(
                                          context,
                                          compact: 112,
                                          standard: 124,
                                          wide: 132,
                                        ),
                                      ),
                                    );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          FilterChip(
                            visualDensity: VisualDensity.compact,
                            selected: attendance == 'interested',
                            label: const Text('İlgileniyorum'),
                            onSelected: _busy
                                ? null
                                : (selected) => _setAttendance(
                                    event,
                                    selected ? 'interested' : null,
                                  ),
                          ),
                          FilterChip(
                            visualDensity: VisualDensity.compact,
                            selected: attendance == 'going',
                            label: const Text('Katılıyorum'),
                            onSelected: _busy
                                ? null
                                : (selected) => _setAttendance(
                                    event,
                                    selected ? 'going' : null,
                                  ),
                          ),
                          FilterChip(
                            visualDensity: VisualDensity.compact,
                            selected: attendance == 'not_going',
                            label: const Text('Katılamıyorum'),
                            onSelected: _busy
                                ? null
                                : (selected) => _setAttendance(
                                    event,
                                    selected ? 'not_going' : null,
                                  ),
                          ),
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            avatar: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : null,
                            ),
                            label: Text(isFavorite ? 'Kaydedildi' : 'Kaydet'),
                            onPressed: _busy
                                ? null
                                : () => _toggleFavorite(event),
                          ),
                          ActionChip(
                            visualDensity: VisualDensity.compact,
                            avatar: const Icon(Icons.flag_outlined),
                            label: const Text('Bildir'),
                            onPressed: _busy ? null : () => _reportEvent(event),
                          ),
                        ],
                      ),
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

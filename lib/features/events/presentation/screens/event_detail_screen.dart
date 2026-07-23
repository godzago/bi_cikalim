import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
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
    ).showSnackBar(SnackBar(content: Text(error.toString())));
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
          child: AppEmptyState(
            icon: Icons.event_busy,
            message: 'Etkinlik yüklenemedi.\n$error',
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
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                if (event.coverUrl != null)
                  AppNetworkImage(
                    imageUrl: event.coverUrl!,
                    width: double.infinity,
                    height: 240,
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${event.startAt.toLocal()} • ${event.city.name}',
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
                        ),
                      ),
                      if (event.venue != null) ...[
                        const SizedBox(height: 8),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.storefront_outlined),
                          title: Text(event.venue!.name),
                          onTap: () =>
                              context.push('/venues/${event.venue!.slug}'),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(event.description ?? event.shortDescription ?? ''),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          FilterChip(
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
                            selected: attendance == 'going',
                            label: const Text('Katılıyorum'),
                            onSelected: _busy
                                ? null
                                : (selected) => _setAttendance(
                                    event,
                                    selected ? 'going' : null,
                                  ),
                          ),
                          ActionChip(
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

import 'package:flutter/material.dart';

import '../../../../core/theme/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_pressable_scale.dart';

class TonightEventCard extends StatelessWidget {
  final ApiEvent event;
  final bool isFavorite;
  final String? attendanceStatus;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final ValueChanged<String> onAttendanceTap;

  const TonightEventCard({
    super.key,
    required this.event,
    required this.isFavorite,
    required this.attendanceStatus,
    required this.isBusy,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onAttendanceTap,
  });

  @override
  Widget build(BuildContext context) {
    final layout = context.layout;
    final venueName = event.venue?.name;
    final location = [
      if (venueName != null && venueName.isNotEmpty) venueName,
      if (event.city.name.isNotEmpty) event.city.name,
    ].join(' • ');
    final local = event.startDate;
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final semanticLabel =
        '${event.title}, $day/$month saat $time${location.isEmpty ? '' : ', $location'}. Etkinlik detayını aç.';

    return Semantics(
      button: true,
      label: semanticLabel,
      child: AppPressableScale(
        child: Padding(
          padding: EdgeInsets.only(bottom: layout.cardGap),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: layout.fluid(390, 430, 500),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _EventBackdrop(event: event),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            BiCikalimTheme.primaryDark.withValues(alpha: .08),
                            BiCikalimTheme.primaryDark.withValues(alpha: .24),
                            const Color(0xFF6B220F).withValues(alpha: .88),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 14,
                      left: 14,
                      right: 14,
                      child: Row(
                        children: [
                          Flexible(
                            child: _DateGlass(
                              day: day,
                              month: month,
                              time: time,
                            ),
                          ),
                          const Spacer(),
                          _GlassIconButton(
                            tooltip: isFavorite
                                ? 'Favoriden çıkar'
                                : 'Favoriye ekle',
                            icon: isFavorite
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            onPressed: isBusy ? null : onFavoriteTap,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              const _EventBadge(),
                              _SmallPill(label: event.priceInfo),
                              if (attendanceStatus != null &&
                                  attendanceStatus!.isNotEmpty)
                                _SmallPill(
                                  label: _attendanceLabel(attendanceStatus!),
                                  filled: true,
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            event.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              height: 1.03,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ne zaman ve nerede?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .62),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            location.isEmpty ? '$day/$month $time' : location,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .76),
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final interested = OutlinedButton(
                                onPressed: isBusy
                                    ? null
                                    : () => onAttendanceTap('interested'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(
                                    color: Colors.white.withValues(alpha: .34),
                                  ),
                                  backgroundColor: Colors.white.withValues(
                                    alpha: .08,
                                  ),
                                ),
                                child: const Text('İlgileniyorum'),
                              );
                              final going = FilledButton(
                                onPressed: isBusy
                                    ? null
                                    : () => onAttendanceTap('going'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: BiCikalimTheme.textPrimary,
                                ),
                                child: const Text('Katıl'),
                              );

                              if (constraints.maxWidth < 220) {
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    interested,
                                    const SizedBox(height: 8),
                                    going,
                                  ],
                                );
                              }

                              return Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [interested, going],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _attendanceLabel(String value) {
    return switch (value) {
      'going' => 'Katılıyorum',
      'interested' => 'İlgileniyorum',
      'not_going' => 'Katılmıyorum',
      _ => value,
    };
  }
}

class _EventBackdrop extends StatelessWidget {
  final ApiEvent event;

  const _EventBackdrop({required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.imageUrl.isNotEmpty) {
      return AppNetworkImage(
        imageUrl: event.imageUrl,
        fit: BoxFit.cover,
        semanticLabel: '${event.title} etkinlik görseli',
      );
    }

    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BiCikalimTheme.primaryDark,
            BiCikalimTheme.primary,
            Color(0xFFFF8A50),
          ],
        ),
      ),
    );
  }
}

class _DateGlass extends StatelessWidget {
  final String day;
  final String month;
  final String time;

  const _DateGlass({
    required this.day,
    required this.month,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: BiCikalimTheme.primaryDark.withValues(alpha: .54),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
      ),
      child: Text(
        '$day/$month  $time',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _GlassIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: BiCikalimTheme.primaryDark.withValues(alpha: .54),
        disabledBackgroundColor: BiCikalimTheme.primaryDark.withValues(
          alpha: .22,
        ),
      ),
    );
  }
}

class _EventBadge extends StatelessWidget {
  const _EventBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: .12)),
      ),
      child: const Text(
        'Etkinlik',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SmallPill extends StatelessWidget {
  final String label;
  final bool filled;

  const _SmallPill({required this.label, this.filled = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: filled
            ? BiCikalimTheme.success.withValues(alpha: .82)
            : Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

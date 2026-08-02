import 'package:flutter/material.dart';

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
        child: Card(
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF0EDE9)),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EventVisual(
                    event: event,
                    day: day,
                    month: month,
                    time: time,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const _EventBadge(),
                            const Spacer(),
                            Semantics(
                              button: true,
                              label: isFavorite
                                  ? '${event.title}, favorilerden çıkar'
                                  : '${event.title}, favorilere ekle',
                              child: IconButton(
                                tooltip: isFavorite
                                    ? 'Favoriden çıkar'
                                    : 'Favoriye ekle',
                                visualDensity: VisualDensity.compact,
                                onPressed: isBusy ? null : onFavoriteTap,
                                icon: Icon(
                                  isFavorite
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: BiCikalimTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          event.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: BiCikalimTheme.textPrimary,
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Ne zaman ve nerede?',
                          style: TextStyle(
                            color: BiCikalimTheme.primary.withValues(alpha: .9),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$day/$month $time${location.isEmpty ? '' : ' • $location'}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: BiCikalimTheme.textSecondary,
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
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
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final interested = OutlinedButton(
                              onPressed: isBusy
                                  ? null
                                  : () => onAttendanceTap('interested'),
                              child: const Text('İlgileniyorum'),
                            );
                            final going = FilledButton(
                              onPressed: isBusy
                                  ? null
                                  : () => onAttendanceTap('going'),
                              child: const Text('Katılıyorum'),
                            );

                            if (constraints.maxWidth < 220) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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

class _EventVisual extends StatelessWidget {
  final ApiEvent event;
  final String day;
  final String month;
  final String time;

  const _EventVisual({
    required this.event,
    required this.day,
    required this.month,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 86,
      height: 128,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (event.imageUrl.isNotEmpty)
              AppNetworkImage(
                imageUrl: event.imageUrl,
                semanticLabel: '${event.title} etkinlik görseli',
              )
            else
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      BiCikalimTheme.primary.withValues(alpha: .86),
                      BiCikalimTheme.primaryDark,
                    ],
                  ),
                ),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: .08),
                    Colors.black.withValues(alpha: .56),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .94),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$day/$month',
                      style: const TextStyle(
                        color: BiCikalimTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: const TextStyle(
                        color: BiCikalimTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
        color: BiCikalimTheme.textPrimary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Text(
        'Etkinlik',
        style: TextStyle(
          color: BiCikalimTheme.textPrimary,
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
            ? BiCikalimTheme.success.withValues(alpha: .12)
            : BiCikalimTheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: filled ? BiCikalimTheme.success : BiCikalimTheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

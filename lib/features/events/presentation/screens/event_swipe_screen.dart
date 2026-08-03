import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/api_providers.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/theme/responsive.dart';
import '../../../../shared/models/api_models.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_network_image.dart';
import '../../../../shared/widgets/app_refreshable_content.dart';
import '../../../../shared/widgets/primary_button.dart';

class EventSwipeScreen extends ConsumerStatefulWidget {
  const EventSwipeScreen({super.key});

  @override
  ConsumerState<EventSwipeScreen> createState() => _EventSwipeScreenState();
}

class _EventSwipeScreenState extends ConsumerState<EventSwipeScreen>
    with SingleTickerProviderStateMixin {
  static const _swipeThreshold = 100.0;

  late final AnimationController _controller;

  Animation<Offset>? _offsetAnimation;
  Offset _dragOffset = Offset.zero;
  bool _isAnimating = false;
  int _currentIndex = 0;
  ApiEvent? _pendingEvent;
  _SwipeDirection? _pendingDirection;

  final List<ApiEvent> _selectedEvents = [];
  final List<_SwipeAction> _history = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    )..addStatusListener(_handleAnimationStatus);
  }

  @override
  void dispose() {
    _controller
      ..removeStatusListener(_handleAnimationStatus)
      ..dispose();
    super.dispose();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;

    final event = _pendingEvent;
    final direction = _pendingDirection;

    setState(() {
      if (event != null && direction != null) {
        final isSelected = direction == _SwipeDirection.right;
        _history.add(
          _SwipeAction(
            event: event,
            direction: direction,
            wasSelected: isSelected,
          ),
        );
        if (isSelected) {
          _selectedEvents.add(event);
        }
        _currentIndex++;
      }

      _dragOffset = Offset.zero;
      _offsetAnimation = null;
      _pendingEvent = null;
      _pendingDirection = null;
      _isAnimating = false;
    });
    _controller.reset();
  }

  void _animateTo(
    Offset target, {
    ApiEvent? event,
    _SwipeDirection? direction,
  }) {
    if (_isAnimating) return;

    _isAnimating = true;
    _pendingEvent = event;
    _pendingDirection = direction;
    _offsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: target,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward(from: 0);
  }

  void _swipe(ApiEvent event, _SwipeDirection direction) {
    if (_isAnimating) return;
    final width = MediaQuery.sizeOf(context).width;
    final sign = direction == _SwipeDirection.right ? 1.0 : -1.0;
    _animateTo(
      Offset(sign * width * 1.35, _dragOffset.dy * 0.35),
      event: event,
      direction: direction,
    );
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() => _dragOffset += details.delta);
  }

  void _handlePanEnd(ApiEvent event, DragEndDetails details) {
    if (_isAnimating) return;

    if (_dragOffset.dx.abs() >= _swipeThreshold) {
      _swipe(
        event,
        _dragOffset.dx > 0 ? _SwipeDirection.right : _SwipeDirection.left,
      );
      return;
    }
    _animateTo(Offset.zero);
  }

  void _undoLast() {
    if (_isAnimating || _history.isEmpty || _currentIndex == 0) return;

    final action = _history.removeLast();
    if (action.wasSelected) {
      _selectedEvents.removeWhere((event) => event.id == action.event.id);
    }

    final width = MediaQuery.sizeOf(context).width;
    final sign = action.direction == _SwipeDirection.right ? 1.0 : -1.0;
    setState(() {
      _currentIndex--;
      _dragOffset = Offset(sign * width, 0);
    });
    _animateTo(Offset.zero);
  }

  void _restart() {
    if (_isAnimating) return;
    setState(() {
      _currentIndex = 0;
      _dragOffset = Offset.zero;
      _selectedEvents.clear();
      _history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final citySlug = ref.watch(selectedCityProvider).value?.slug;
    final filters = EventFilters(citySlug: citySlug);
    final provider = eventsListProvider(filters);
    final eventsAsync = ref.watch(provider);

    Future<void> refreshEvents() async {
      ref.invalidate(provider);
      await ref.read(provider.future);
      if (mounted) _restart();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bu Akşam Ne Yapsak?')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        child: eventsAsync.when(
          loading: () => AppRefreshableContent(
            key: const ValueKey('event-swipe-loading'),
            onRefresh: refreshEvents,
            child: const Center(
              child: CircularProgressIndicator(color: BiCikalimTheme.primary),
            ),
          ),
          error: (error, _) => AppRefreshableContent(
            key: const ValueKey('event-swipe-error'),
            onRefresh: refreshEvents,
            child: AppEmptyState(
              icon: Icons.cloud_off,
              message: 'Etkinlikler yüklenemedi.\n$error',
              actionLabel: 'Tekrar Dene',
              onAction: () => ref.invalidate(provider),
            ),
          ),
          data: (allEvents) {
            final now = DateTime.now();
            final events =
                allEvents.where((event) {
                  final date = event.startAt.toLocal();
                  return date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;
                }).toList()..sort(
                  (left, right) => left.startAt.compareTo(right.startAt),
                );

            if (events.isEmpty) {
              return AppRefreshableContent(
                key: const ValueKey('event-swipe-empty'),
                onRefresh: refreshEvents,
                child: const AppEmptyState(
                  icon: Icons.event_busy_outlined,
                  message: 'Bu akşam için etkinlik bulunamadı.',
                ),
              );
            }

            if (_currentIndex >= events.length) {
              return AppRefreshableContent(
                onRefresh: refreshEvents,
                child: _buildFinishedState(),
              );
            }

            return LayoutBuilder(
              key: const ValueKey('event-swipe-content'),
              builder: (context, constraints) {
                return RefreshIndicator(
                  color: BiCikalimTheme.primary,
                  onRefresh: refreshEvents,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: _buildDeck(events),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDeck(List<ApiEvent> events) {
    final visibleCount = math.min(3, events.length - _currentIndex);
    final visibleEvents = List.generate(
      visibleCount,
      (depth) => events[_currentIndex + depth],
    );

    return SafeArea(
      key: const ValueKey('event-swipe-deck'),
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.layout.screenPadding,
          6,
          context.layout.screenPadding,
          10,
        ),
        child: Column(
          children: [
            const Text(
              'Sağa kaydır: olur  •  Sola kaydır: geç',
              style: TextStyle(
                color: BiCikalimTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      final offset = _offsetAnimation?.value ?? _dragOffset;
                      final progress = (offset.dx.abs() / _swipeThreshold)
                          .clamp(0.0, 1.0);

                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          for (
                            var depth = visibleEvents.length - 1;
                            depth >= 0;
                            depth--
                          )
                            _buildDeckCard(
                              event: visibleEvents[depth],
                              depth: depth,
                              offset: offset,
                              progress: progress,
                              maxHeight: constraints.maxHeight,
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            _buildActions(events[_currentIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckCard({
    required ApiEvent event,
    required int depth,
    required Offset offset,
    required double progress,
    required double maxHeight,
  }) {
    if (depth == 0) {
      final rotation = (offset.dx / MediaQuery.sizeOf(context).width) * 0.16;
      return Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: rotation,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _isAnimating
                ? null
                : () => context.push('/events/${event.slug}'),
            onHorizontalDragUpdate: _handlePanUpdate,
            onHorizontalDragEnd: (details) => _handlePanEnd(event, details),
            onHorizontalDragCancel: () {
              if (!_isAnimating) _animateTo(Offset.zero);
            },
            child: _EventSwipeCard(
              event: event,
              maxHeight: maxHeight,
              horizontalDrag: offset.dx,
            ),
          ),
        ),
      );
    }

    final verticalOffset = (depth * 12.0) * (1 - progress);
    final opacity = (depth == 1 ? .94 : .86) + (progress * .06);

    return IgnorePointer(
      child: Transform.translate(
        offset: Offset(0, verticalOffset),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: _EventSwipeCard(
            event: event,
            maxHeight: maxHeight,
            horizontalDrag: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildActions(ApiEvent event) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SwipeActionButton(
          tooltip: 'Son işlemi geri al',
          icon: Icons.undo_rounded,
          color: BiCikalimTheme.textSecondary,
          enabled: _history.isNotEmpty && !_isAnimating,
          onPressed: _undoLast,
        ),
        const SizedBox(width: 22),
        _SwipeActionButton(
          tooltip: 'Geç',
          icon: Icons.close_rounded,
          color: BiCikalimTheme.primary,
          enabled: !_isAnimating,
          onPressed: () => _swipe(event, _SwipeDirection.left),
        ),
        const SizedBox(width: 22),
        _SwipeActionButton(
          tooltip: 'Olur',
          icon: Icons.favorite_rounded,
          color: BiCikalimTheme.success,
          enabled: !_isAnimating,
          onPressed: () => _swipe(event, _SwipeDirection.right),
        ),
      ],
    );
  }

  Widget _buildFinishedState() {
    return SafeArea(
      key: const ValueKey('event-swipe-finished'),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.layout.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: BiCikalimTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.celebration_outlined,
                  color: BiCikalimTheme.primary,
                  size: 38,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Kartların sonuna geldin',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: BiCikalimTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedEvents.length} etkinlik seçtin.',
                style: const TextStyle(
                  color: BiCikalimTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Seçtiklerini Gör',
                onPressed: _showSelectedEvents,
              ),
              const SizedBox(height: 10),
              SecondaryButton(
                label: 'Baştan Başla',
                prefixIcon: Icons.refresh,
                onPressed: _restart,
              ),
              if (_history.isNotEmpty) ...[
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: _isAnimating ? null : _undoLast,
                  icon: const Icon(Icons.undo_rounded, size: 18),
                  label: const Text('Son işlemi geri al'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showSelectedEvents() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    context.layout.screenPadding,
                    0,
                    context.layout.screenPadding,
                    10,
                  ),
                  child: Text(
                    'Seçtiğin Etkinlikler',
                    style: TextStyle(
                      color: BiCikalimTheme.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: _selectedEvents.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.favorite_border,
                          message: 'Henüz bir etkinlik seçmedin.',
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                            context.layout.screenPadding,
                            4,
                            context.layout.screenPadding,
                            context.layout.sectionGap,
                          ),
                          itemCount: _selectedEvents.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final event = _selectedEvents[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 6,
                              ),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AppNetworkImage(
                                  imageUrl: event.imageUrl,
                                  width: 46,
                                  height: 46,
                                ),
                              ),
                              title: Text(
                                event.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Text(_formatDateTime(event.startAt)),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.of(sheetContext).pop();
                                context.push('/events/${event.slug}');
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

enum _SwipeDirection { left, right }

class _SwipeAction {
  final ApiEvent event;
  final _SwipeDirection direction;
  final bool wasSelected;

  const _SwipeAction({
    required this.event,
    required this.direction,
    required this.wasSelected,
  });
}

class _EventSwipeCard extends StatelessWidget {
  final ApiEvent event;
  final double maxHeight;
  final double horizontalDrag;

  const _EventSwipeCard({
    required this.event,
    required this.maxHeight,
    required this.horizontalDrag,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = maxHeight < 430;
    final category = event.activities.isNotEmpty
        ? event.activities.first.name
        : null;
    final location = [
      if (event.venue?.name.isNotEmpty ?? false) event.venue!.name,
      if (event.city.name.isNotEmpty) event.city.name,
    ].join(', ');
    final description = event.shortDescription;
    final decisionOpacity = (horizontalDrag.abs() / 80).clamp(0.0, 1.0);

    return SizedBox(
      height: maxHeight,
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        elevation: 5,
        shadowColor: Colors.black.withValues(alpha: 0.14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(imageUrl: event.imageUrl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  if (category != null)
                    Positioned(
                      left: 16,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: BiCikalimTheme.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 18,
                    left: horizontalDrag >= 0 ? 18 : null,
                    right: horizontalDrag < 0 ? 18 : null,
                    child: Opacity(
                      opacity: decisionOpacity,
                      child: Transform.rotate(
                        angle: horizontalDrag >= 0 ? -0.08 : 0.08,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: horizontalDrag >= 0
                                ? BiCikalimTheme.success
                                : BiCikalimTheme.primary,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Text(
                            horizontalDrag >= 0 ? 'OLUR' : 'GEÇ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              flex: isCompact ? 3 : 4,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isCompact ? 14 : 18,
                  isCompact ? 10 : 16,
                  isCompact ? 14 : 18,
                  isCompact ? 10 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: BiCikalimTheme.textPrimary,
                        fontSize: isCompact ? 16 : 20,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isCompact ? 6 : 10),
                    _EventInfoRow(
                      icon: Icons.schedule_outlined,
                      text: _formatDateTime(event.startAt),
                    ),
                    if (location.isNotEmpty) ...[
                      SizedBox(height: isCompact ? 4 : 7),
                      _EventInfoRow(
                        icon: Icons.location_on_outlined,
                        text: location,
                      ),
                    ],
                    if (!isCompact &&
                        description != null &&
                        description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: BiCikalimTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
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

class _EventInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EventInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: BiCikalimTheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: BiCikalimTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _SwipeActionButton({
    required this.tooltip,
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: enabled ? onPressed : null,
      iconSize: 28,
      padding: const EdgeInsets.all(14),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        disabledForegroundColor: BiCikalimTheme.textLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        side: BorderSide(color: color.withValues(alpha: enabled ? 0.22 : 0.08)),
      ),
      icon: Icon(icon),
    );
  }
}

String _formatDateTime(DateTime value) {
  final localValue = value.toLocal();
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
  final hour = localValue.hour.toString().padLeft(2, '0');
  final minute = localValue.minute.toString().padLeft(2, '0');
  return '${localValue.day} ${months[localValue.month - 1]} • $hour:$minute';
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_permission_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/primary_button.dart';

class NotificationPermissionScreen extends StatefulWidget {
  final String nextRoute;

  const NotificationPermissionScreen({super.key, required this.nextRoute});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool _isLoading = false;

  Future<void> _allowNotifications() async {
    setState(() => _isLoading = true);
    try {
      await NotificationPermissionService.request();
      if (mounted) context.go(widget.nextRoute);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _notNow() async {
    await NotificationPermissionService.dismiss();
    if (mounted) context.go(widget.nextRoute);
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 650;
    final haloSize = compact ? 152.0 : 208.0;
    final iconSize = compact ? 108.0 : 144.0;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 44,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const Spacer(),
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: haloSize,
                          height: haloSize,
                          decoration: BoxDecoration(
                            color: BiCikalimTheme.primary.withValues(
                              alpha: .10,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: BiCikalimTheme.primary,
                            borderRadius: BorderRadius.circular(
                              compact ? 34 : 44,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: BiCikalimTheme.primary.withValues(
                                  alpha: .28,
                                ),
                                blurRadius: 34,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_active_rounded,
                            color: Colors.white,
                            size: compact ? 50 : 66,
                          ),
                        ),
                        Positioned(
                          right: compact ? 8 : 18,
                          top: compact ? 4 : 12,
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: BiCikalimTheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: .08),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              color: BiCikalimTheme.primary,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: compact ? 24 : 46),
                    Text(
                      'Planları kaçırma!',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: compact ? 8 : 12),
                    Text(
                      'Yeni etkinlikleri, favori mekanlarındaki gelişmeleri ve sana uygun planları tam zamanında haber verelim.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: BiCikalimTheme.textSecondary,
                        height: 1.55,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: compact ? 16 : 24),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: compact ? 10 : 14,
                      ),
                      decoration: BoxDecoration(
                        color: BiCikalimTheme.primary.withValues(alpha: .07),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: BiCikalimTheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Sadece işine yarayan bildirimleri göndeririz.',
                              style: TextStyle(
                                color: BiCikalimTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Bildirimlere İzin Ver',
                      prefixIcon: Icons.notifications_none_rounded,
                      onPressed: _allowNotifications,
                      isLoading: _isLoading,
                    ),
                    SizedBox(height: compact ? 4 : 8),
                    TextButton(
                      onPressed: _isLoading ? null : _notNow,
                      child: const Text('Şimdi değil'),
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
}

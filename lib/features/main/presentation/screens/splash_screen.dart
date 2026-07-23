import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/user_session_provider.dart';

/// Uygulama başlangıç splash ekranı.
///
/// Native splash ile aynı görselden başlar, hafifçe büyür ve sonraki ekrana
/// geçmeden önce yumuşak biçimde kaybolur.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1), weight: 72),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 28,
      ),
    ]).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.035,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    unawaited(_completeSplash());
  }

  Future<void> _completeSplash() async {
    try {
      await Future.wait<void>([
        _controller.forward().orCancel,
        ref.read(userSessionProvider.future),
      ], eagerError: true);
    } on TickerCanceled {
      return;
    }

    if (mounted) {
      _navigate();
    }
  }

  void _navigate() {
    if (!mounted) return;

    final userType = ref.read(userTypeProvider);

    switch (userType) {
      case UserType.normalUser:
        context.go(AppConstants.discoverRoute);
      case UserType.venueOwner:
        context.go('/venue-owner');
      case null:
        context.go(AppConstants.onboardingRoute);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFC4228),
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SizedBox.expand(
            child: Image.asset(
              'assets/splash.png',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      ),
    );
  }
}

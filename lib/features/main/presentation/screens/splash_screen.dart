import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Uygulama başlangıç splash ekranı.
/// Animasyon sonrası auth state'e göre yönlendirir:
/// - Giriş yapılmamış → Onboarding
/// - Giriş yapılmış, şehir seçilmemiş → CitySelect
/// - Giriş yapılmış, şehir seçilmiş → Discover
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) _navigate();
    });
  }

  /// Auth state'e göre yönlendirme kararı verir.
  Future<void> _navigate() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (currentUser == null) {
      // Giriş yapılmamış → Onboarding
      context.go(AppConstants.onboardingRoute);
      return;
    }

    // Giriş yapılmış → Firestore profili kontrol et
    try {
      final repo = ref.read(authRepositoryProvider);
      final userProfile = await repo.getUserProfile(currentUser.uid);

      if (!mounted) return;

      if (userProfile == null || (userProfile.city?.isEmpty ?? true)) {
        // Şehir seçilmemiş → CitySelect
        context.go(AppConstants.citySelectRoute);
      } else {
        // Her şey tamam → Discover
        context.go(AppConstants.discoverRoute);
      }
    } catch (e) {
      if (!mounted) return;
      // Firestore hatası durumunda güvenli yol: onboarding
      context.go(AppConstants.onboardingRoute);
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BiCikalimTheme.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.explore,
                    size: 80,
                    color: BiCikalimTheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'BiÇıkalım',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Şehrindeki Eğlenceyi Keşfet',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/main/presentation/screens/splash_screen.dart';
import '../../features/main/presentation/screens/city_select_screen.dart';
import '../../features/main/presentation/screens/navigation_shell.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/venues/presentation/screens/venue_detail_screen.dart';

/// Auth-aware GoRouter.
/// Riverpod [authStateProvider]'ı dinleyerek otomatik yönlendirme yapar.
GoRouter createRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.uri.toString();

      // Splash ekranında redirect yapma, kendi içinde yönetir
      if (location == '/splash') return null;

      // Auth durumu henüz yükleniyor, bekle
      if (authState.isLoading) return null;

      final user = authState.asData?.value;
      final isLoggedIn = user != null;

      // Auth gerektirmeyen sayfalar
      const publicRoutes = [
        '/onboarding',
        '/sign-in',
        '/sign-up',
        '/forgot-password',
      ];

      final isPublicPage = publicRoutes.any((r) => location.startsWith(r));

      // Giriş yapmamış kullanıcı korumalı sayfaya erişmeye çalışırsa
      if (!isLoggedIn && !isPublicPage) {
        return '/onboarding';
      }

      // Giriş yapmış kullanıcı auth sayfalarına gitmeye çalışırsa
      if (isLoggedIn && isPublicPage) {
        return '/discover';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Auth Rotaları
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Şehir Seçimi (auth sonrası, shell dışında)
      GoRoute(
        path: '/city-select',
        builder: (context, state) => const CitySelectScreen(),
      ),

      // Ana Shell (Bottom Navigation)
      ShellRoute(
        builder: (context, state, child) {
          return NavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoverScreen(),
          ),
          GoRoute(
            path: '/events',
            builder: (context, state) => const EventsScreen(),
          ),
          GoRoute(
            path: '/map',
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Mekan Detay
      GoRoute(
        path: '/venues/:venueId',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId']!;
          return VenueDetailScreen(venueId: venueId);
        },
      ),
    ],
  );
}

/// Statik router (Firebase hazır olmadan önce kullanılır).
/// main.dart'ta Firebase init tamamlandıktan sonra [createRouter] kullanılır.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/city-select',
      builder: (context, state) => const CitySelectScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return NavigationShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/discover',
          builder: (context, state) => const DiscoverScreen(),
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) => const MapScreen(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/venues/:venueId',
      builder: (context, state) {
        final venueId = state.pathParameters['venueId']!;
        return VenueDetailScreen(venueId: venueId);
      },
    ),
  ],
);

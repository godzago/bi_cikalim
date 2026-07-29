import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/notification_permission_screen.dart';
import '../../features/auth/presentation/screens/venue_owner_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/main/presentation/screens/splash_screen.dart';
import '../../features/main/presentation/screens/city_select_screen.dart';
import '../../features/main/presentation/screens/navigation_shell.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/discover/presentation/screens/discover_search_screen.dart';
import '../../features/discover/presentation/screens/discover_catalog_screen.dart';
import '../../features/discover/presentation/screens/discover_results_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/event_swipe_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/submission_screen.dart';
import '../../features/venues/presentation/screens/venue_detail_screen.dart';

/// Uygulama router konfigürasyonu.
/// Gerçek API oturumu ve public misafir akışını kullanan yönlendirme.
/// Redirect mantığı: userTypeProvider üzerinden Riverpod consumer widget'larında yönetilir.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

    GoRoute(
      path: '/notification-permission',
      builder: (context, state) {
        const allowedDestinations = {
          '/onboarding',
          '/discover',
          '/venue-owner',
        };
        final requested = state.uri.queryParameters['next'];
        final nextRoute = allowedDestinations.contains(requested)
            ? requested!
            : '/onboarding';
        return NotificationPermissionScreen(nextRoute: nextRoute);
      },
    ),

    // Onboarding — Kullanıcı tipi seçimi
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Sign In
    GoRoute(
      path: '/sign-in',
      builder: (context, state) {
        final requested = state.uri.queryParameters['accountType'];
        final accountType = requested == 'venue_owner' ? 'venue_owner' : 'user';
        return SignInScreen(accountType: accountType);
      },
    ),

    // Sign Up
    GoRoute(
      path: '/sign-up',
      builder: (context, state) {
        final requested = state.uri.queryParameters['accountType'];
        final accountType = requested == 'venue_owner' ? 'venue_owner' : 'user';
        return SignUpScreen(accountType: accountType);
      },
    ),

    // Mekan Sahibi Panel (Placeholder)
    GoRoute(
      path: '/venue-owner',
      builder: (context, state) => const VenueOwnerScreen(),
    ),

    // Şehir Seçimi (ileride kullanılacak)
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
          routes: [
            GoRoute(
              path: 'search',
              builder: (context, state) => const DiscoverSearchScreen(),
            ),
            GoRoute(
              path: 'catalog',
              builder: (context, state) => const DiscoverCatalogScreen(),
            ),
            GoRoute(
              path: 'results',
              builder: (context, state) {
                final query = state.uri.queryParameters['query'];
                final categoryId = state.uri.queryParameters['categoryId'];
                final subcategoryId =
                    state.uri.queryParameters['subcategoryId'];
                final activityId = state.uri.queryParameters['activityId'];
                final categorySlug = state.uri.queryParameters['categorySlug'];
                final subcategorySlug =
                    state.uri.queryParameters['subcategorySlug'];
                final activitySlug = state.uri.queryParameters['activitySlug'];
                final title = state.uri.queryParameters['title'];

                return DiscoverResultsScreen(
                  query: query,
                  categoryId: categoryId,
                  subcategoryId: subcategoryId,
                  activityId: activityId,
                  categorySlug: categorySlug,
                  subcategorySlug: subcategorySlug,
                  activitySlug: activitySlug,
                  title: title,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
          routes: [
            GoRoute(
              path: 'tonight',
              builder: (context, state) => const EventSwipeScreen(),
            ),
          ],
        ),
        GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
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
    GoRoute(
      path: '/events/:eventSlug',
      builder: (context, state) {
        return EventDetailScreen(eventSlug: state.pathParameters['eventSlug']!);
      },
    ),
    GoRoute(
      path: '/submissions/venue',
      builder: (context, state) =>
          const SubmissionScreen(type: SubmissionType.venueSuggestion),
    ),
    GoRoute(
      path: '/submissions/ownership',
      builder: (context, state) =>
          const SubmissionScreen(type: SubmissionType.ownership),
    ),
    GoRoute(
      path: '/submissions/taxonomy',
      builder: (context, state) =>
          const SubmissionScreen(type: SubmissionType.taxonomy),
    ),
  ],
);

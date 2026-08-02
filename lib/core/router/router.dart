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
import '../../features/discover/presentation/screens/advanced_discover_results_screen.dart';
import '../../features/discover/presentation/screens/advanced_discover_search_screen.dart';
import '../../features/discover/presentation/screens/discover_catalog_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/events/presentation/screens/event_swipe_screen.dart';
import '../../features/events/presentation/screens/tonight_screen.dart';
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
              builder: (context, state) => AdvancedDiscoverSearchScreen(
                initialQuery: state.uri.queryParameters['q'] ?? '',
              ),
            ),
            GoRoute(
              path: 'catalog',
              builder: (context, state) => const DiscoverCatalogScreen(),
            ),
            GoRoute(
              path: 'results',
              builder: (context, state) {
                final query = state.uri.queryParameters['query'];
                final citySlug = state.uri.queryParameters['citySlug'];
                final categoryId = state.uri.queryParameters['categoryId'];
                final subcategoryId =
                    state.uri.queryParameters['subcategoryId'];
                final activityId = state.uri.queryParameters['activityId'];
                final categorySlug = state.uri.queryParameters['categorySlug'];
                final subcategorySlug =
                    state.uri.queryParameters['subcategorySlug'];
                final activitySlug = state.uri.queryParameters['activitySlug'];
                final activityCategorySlug =
                    state.uri.queryParameters['activityCategorySlug'];
                final activitySubCategorySlug =
                    state.uri.queryParameters['activitySubCategorySlug'];
                final scope = state.uri.queryParameters['scope'];
                final type = state.uri.queryParameters['type'] ?? 'venues';
                final currentVenueId =
                    state.uri.queryParameters['currentVenueId'];
                final hasCoordinates =
                    state.uri.queryParameters['hasCoordinates'] == 'true'
                    ? true
                    : null;
                final isVerified =
                    state.uri.queryParameters['isVerified'] == 'true'
                    ? true
                    : null;
                final title = state.uri.queryParameters['title'];

                return AdvancedDiscoverResultsScreen(
                  type: type,
                  scope: scope,
                  query: query,
                  citySlug: citySlug,
                  categoryId: categoryId,
                  subcategoryId: subcategoryId,
                  activityId: activityId,
                  categorySlug: categorySlug,
                  subcategorySlug: subcategorySlug,
                  activitySlug: activitySlug,
                  activityCategorySlug: activityCategorySlug,
                  activitySubCategorySlug: activitySubCategorySlug,
                  hasCoordinates: hasCoordinates,
                  isVerified: isVerified,
                  currentVenueId: currentVenueId,
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
              builder: (context, state) => const TonightScreen(),
            ),
            GoRoute(
              path: 'swipe',
              builder: (context, state) => const EventSwipeScreen(),
            ),
          ],
        ),
        GoRoute(
          path: '/map',
          builder: (context, state) {
            final query = state.uri.queryParameters;
            return MapScreen(
              citySlug: query['citySlug'] ?? query['city_slug'],
              districtSlug: query['districtSlug'] ?? query['district_slug'],
              neighborhoodSlug:
                  query['neighborhoodSlug'] ?? query['neighborhood_slug'],
              activityCategorySlug:
                  query['activityCategorySlug'] ??
                  query['activity_category_slug'],
              activitySubCategorySlug:
                  query['activitySubCategorySlug'] ??
                  query['activity_sub_category_slug'],
              activitySlug: query['activitySlug'] ?? query['activity_slug'],
              tagSlug: query['tagSlug'] ?? query['tag_slug'],
              q: query['q'] ?? query['query'],
              isVerified: query['isVerified'] == 'true'
                  ? true
                  : query['is_verified'] == 'true'
                  ? true
                  : null,
            );
          },
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

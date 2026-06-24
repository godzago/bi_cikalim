import 'package:go_router/go_router.dart';

import '../../features/discover/presentation/screens/discover_catalog_screen.dart';
import '../../features/discover/presentation/screens/discover_results_screen.dart';
import '../../features/discover/presentation/screens/discover_screen.dart';
import '../../features/discover/presentation/screens/discover_search_screen.dart';
import '../../features/events/presentation/screens/events_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/main/presentation/screens/city_select_screen.dart';
import '../../features/main/presentation/screens/navigation_shell.dart';
import '../../features/main/presentation/screens/splash_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/venues/presentation/screens/venue_detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
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
                final title = state.uri.queryParameters['title'];

                return DiscoverResultsScreen(
                  query: query,
                  categoryId: categoryId,
                  subcategoryId: subcategoryId,
                  activityId: activityId,
                  title: title,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: '/events',
          builder: (context, state) => const EventsScreen(),
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
    GoRoute(
      path: '/venues/:venueId',
      builder: (context, state) {
        final venueId = state.pathParameters['venueId']!;
        return VenueDetailScreen(venueId: venueId);
      },
    ),
  ],
);

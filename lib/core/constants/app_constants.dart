/// Uygulama genelinde kullanılan sabitler.
class AppConstants {
  AppConstants._();

  // Firestore Collection İsimleri
  static const String usersCollection = 'users';
  static const String venuesCollection = 'venues';
  static const String eventsCollection = 'events';
  static const String reviewsCollection = 'reviews';

  // Route Paths
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String signInRoute = '/sign-in';
  static const String signUpRoute = '/sign-up';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String citySelectRoute = '/city-select';
  static const String discoverRoute = '/discover';
  static const String eventsRoute = '/events';
  static const String mapRoute = '/map';
  static const String favoritesRoute = '/favorites';
  static const String profileRoute = '/profile';
  static const String venueDetailRoute = '/venues/:venueId';

  // Kullanıcı Rolleri
  static const String roleUser = 'user';
  static const String roleVenueOwner = 'venue_owner';
  static const String roleEditor = 'editor';
  static const String roleAdmin = 'admin';

  // MVP Pilot Şehir
  static const String pilotCity = 'Eskişehir';

  // Şehirler (MVP)
  static const List<String> activeCities = ['Eskişehir'];
  static const List<String> comingSoonCities = ['İstanbul', 'Ankara', 'İzmir'];
}

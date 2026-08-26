import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VenueActivity canlı OpenAPI alanlarını okur', () {
    final model = ApiVenueActivitySummary.fromJson({
      'id': 'inventory-id',
      'activity_id': 'activity-id',
      'activity_name': 'Bilardo',
      'activity_slug': 'bilardo',
      'availability': 'available',
      'is_paid': true,
      'price': '250.00',
      'price_unit': 'hour',
      'short_description': 'Masa başına',
      'last_verified_at': '2026-07-23T12:00:00Z',
    });

    expect(model.availability, 'available');
    expect(model.isPaid, isTrue);
    expect(model.price, 250);
    expect(model.priceUnit, 'hour');
    expect(model.lastVerifiedAt, isNotNull);
  });

  test('Venue detail kullanıcı ve rating alanlarını okur', () {
    final venue = ApiVenue.fromJson({
      'id': 'venue-id',
      'name': 'Test Mekan',
      'slug': 'test-mekan',
      'venue_type': 'cafe',
      'city': {'id': 'city-id', 'name': 'Eskişehir', 'slug': 'eskisehir'},
      'is_verified': true,
      'is_favorite': true,
      'activities_summary': <Map<String, dynamic>>[],
      'rating_average': 4.5,
      'rating_count': 12,
      'latitude': '39.77',
      'longitude': '30.52',
    });

    expect(venue.isFavorite, isTrue);
    expect(venue.ratingAverage, 4.5);
    expect(venue.ratingCount, 12);
    expect(venue.latitude, 39.77);
  });

  test('Paginated response ortak sözleşmeyi okur', () {
    final response = ApiPaginatedResponse<ApiCity>.fromJson({
      'items': [
        {
          'id': 'city-id',
          'name': 'Eskişehir',
          'slug': 'eskisehir',
          'country_code': 'TR',
          'has_content': true,
          'launch_status': 'active',
        },
      ],
      'total': 1,
      'page': 1,
      'page_size': 20,
      'pages': 1,
    }, ApiCity.fromJson);

    expect(response.items.single.slug, 'eskisehir');
    expect(response.total, 1);
    expect(response.pages, 1);
  });

  test('yalnızca canonical analytics event adları kabul listesinde', () {
    expect(AnalyticsEventName.values, contains('venue_view'));
    expect(AnalyticsEventName.values, isNot(contains('venue_viewed')));
  });

  test('reservation price type kullanıcıya gösterilecek fiyat üretmez', () {
    final event = ApiEvent(
      id: 'event-id',
      title: 'Test Etkinlik',
      slug: 'test-etkinlik',
      startAt: DateTime(2026, 8, 12, 20),
      timezone: 'Europe/Istanbul',
      status: 'published',
      priceType: 'reservation_required',
      currency: 'TRY',
      city: const ApiLocationSummary(
        id: 'city-id',
        name: 'Eskişehir',
        slug: 'eskisehir',
      ),
      activities: const [],
      isFavorite: false,
    );

    expect(event.hasPublicPriceInfo, isFalse);
    expect(event.priceInfo.toLowerCase(), isNot(contains('rezervasyon')));
    expect(event.priceInfo.toLowerCase(), isNot(contains('reservation')));
  });
}

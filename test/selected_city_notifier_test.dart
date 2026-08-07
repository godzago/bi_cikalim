import 'dart:convert';

import 'package:bi_cikalim/core/services/api_providers.dart';
import 'package:bi_cikalim/core/services/api_services.dart';
import 'package:bi_cikalim/shared/models/api_models.dart';
import 'package:bi_cikalim/shared/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const previousCity = ApiCity(
    id: '34',
    name: 'Istanbul',
    slug: 'istanbul',
    plateCode: '34',
    countryCode: 'TR',
    hasContent: true,
    launchStatus: 'active',
  );
  const nextCity = ApiCity(
    id: '6',
    name: 'Ankara',
    slug: 'ankara',
    plateCode: '06',
    countryCode: 'TR',
    hasContent: true,
    launchStatus: 'active',
  );

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test(
    'backend error restores optimistic state and both storage keys',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_session': jsonEncode({
          'access_token': 'access-token',
          'refresh_token': 'refresh-token',
        }),
      });
      final storage = _FakeSelectedCityStorage(previousCity);
      final service = _FakeUserApiService(
        onUpdate: (_) async => throw StateError('backend failed'),
      );
      final container = _container(storage, service);
      addTearDown(container.dispose);
      await container.read(selectedCityProvider.future);

      final notifier = container.read(selectedCityProvider.notifier);
      final selection = notifier.select(nextCity);

      expect(container.read(selectedCityProvider).value, same(nextCity));
      await expectLater(selection, throwsStateError);
      expect(service.updatedCityIds, ['6']);
      expect(storage.persistCalls, isEmpty);
      expect(storage.restoreCalls, [previousCity]);
      expect(storage.slug, previousCity.slug);
      expect(storage.cachedCity, same(previousCity));
      expect(container.read(selectedCityProvider).value, same(previousCity));
    },
  );

  test(
    'partial persistence error rolls both keys back after backend sync',
    () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_session': jsonEncode({
          'access_token': 'access-token',
          'refresh_token': 'refresh-token',
        }),
      });
      final storage = _FakeSelectedCityStorage(previousCity)
        ..failNextPersistAfterCacheWrite = true;
      final service = _FakeUserApiService(onUpdate: _successfulUpdate);
      final container = _container(storage, service);
      addTearDown(container.dispose);
      await container.read(selectedCityProvider.future);

      final notifier = container.read(selectedCityProvider.notifier);
      await expectLater(notifier.select(nextCity), throwsStateError);

      expect(service.updatedCityIds, ['6']);
      expect(storage.persistCalls, [nextCity]);
      expect(storage.restoreCalls, [previousCity]);
      expect(storage.slug, previousCity.slug);
      expect(storage.cachedCity, same(previousCity));
      expect(container.read(selectedCityProvider).value, same(previousCity));
    },
  );

  test('failed first selection clears both storage keys on rollback', () async {
    final storage = _FakeSelectedCityStorage(null)
      ..failNextPersistAfterCacheWrite = true;
    final service = _FakeUserApiService(onUpdate: _successfulUpdate);
    final container = _container(storage, service);
    addTearDown(container.dispose);
    await container.read(selectedCityProvider.future);

    await expectLater(
      container.read(selectedCityProvider.notifier).select(nextCity),
      throwsStateError,
    );

    expect(service.updatedCityIds, isEmpty);
    expect(storage.restoreCalls, [null]);
    expect(storage.slug, isNull);
    expect(storage.cachedCity, isNull);
    expect(container.read(selectedCityProvider).value, isNull);
  });
}

ProviderContainer _container(
  SelectedCityStorage storage,
  UserApiService service,
) {
  return ProviderContainer(
    overrides: [
      selectedCityProvider.overrideWith(() => SelectedCityNotifier(storage)),
      userApiServiceProvider.overrideWithValue(service),
    ],
  );
}

Future<AppUser> _successfulUpdate(String cityId) async {
  final now = DateTime(2026);
  return AppUser(
    id: 'user',
    displayName: 'Test User',
    email: 'test@example.com',
    selectedCityId: cityId,
    roles: const ['user'],
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeSelectedCityStorage extends SelectedCityStorage {
  String? slug;
  ApiCity? cachedCity;
  bool failNextPersistAfterCacheWrite = false;
  final List<ApiCity> persistCalls = [];
  final List<ApiCity?> restoreCalls = [];

  _FakeSelectedCityStorage(ApiCity? city)
    : slug = city?.slug,
      cachedCity = city;

  @override
  Future<String?> readSlug() async => null;

  @override
  Future<ApiCity?> readCachedCity() async => cachedCity;

  @override
  Future<void> persist(ApiCity city) async {
    persistCalls.add(city);
    cachedCity = city;
    if (failNextPersistAfterCacheWrite) {
      failNextPersistAfterCacheWrite = false;
      throw StateError('cache written, slug write failed');
    }
    slug = city.slug;
  }

  @override
  Future<void> restore(ApiCity? city) async {
    restoreCalls.add(city);
    cachedCity = city;
    slug = city?.slug;
  }
}

class _FakeUserApiService extends UserApiService {
  final Future<AppUser> Function(String cityId) onUpdate;
  final List<String> updatedCityIds = [];

  _FakeUserApiService({required this.onUpdate});

  @override
  Future<AppUser> updateSelectedCity(String cityId) {
    updatedCityIds.add(cityId);
    return onUpdate(cityId);
  }
}

import 'package:bi_cikalim/core/network/api_client.dart';
import 'package:bi_cikalim/core/errors/app_exception.dart';
import 'package:bi_cikalim/core/services/api_services.dart';
import 'package:bi_cikalim/shared/widgets/app_error_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('apiServiceException', () {
    test('FastAPI 422 validation listesini güvenle mesaja dönüştürür', () {
      final detail = [
        {
          'type': 'missing',
          'loc': ['body', 'email'],
          'msg': 'Field required',
        },
        {
          'type': 'value_error',
          'loc': ['body', 'name'],
          'msg': 'Invalid value',
        },
      ];

      final exception = apiServiceException(
        _dioException(statusCode: 422, data: {'detail': detail}),
      );

      expect(exception.statusCode, 422);
      expect(exception.message, 'Field required\nInvalid value');
      expect(exception.details, same(detail));
    });

    test(
      'string olmayan error message ve code alanlarında cast hatası vermez',
      () {
        final exception = apiServiceException(
          _dioException(
            statusCode: 409,
            data: {
              'error': {'message': 123, 'code': 409},
            },
          ),
        );

        expect(exception.message, '123');
        expect(exception.code, '409');
      },
    );

    const statusMessages = <int, String>{
      401: 'Oturumunuz sona erdi. Lütfen tekrar giriş yapın.',
      403: 'Bu işlem için yetkiniz bulunmuyor.',
      404: 'İstenen kayıt bulunamadı.',
      409: 'Bu işlem mevcut kayıtla çakışıyor.',
      422: 'Gönderilen bilgileri kontrol edin.',
      429: 'Çok fazla istek gönderildi. Lütfen biraz bekleyin.',
      500: 'Sunucuda bir hata oluştu. Lütfen daha sonra tekrar deneyin.',
    };

    for (final entry in statusMessages.entries) {
      test('${entry.key} için kullanıcı dostu fallback döndürür', () {
        final exception = apiServiceException(
          _dioException(statusCode: entry.key, data: const {}),
        );

        expect(exception.message, entry.value);
        expect(exception.statusCode, entry.key);
      });
    }

    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      test('$type için zaman aşımı fallback döndürür', () {
        final exception = apiServiceException(_dioException(type: type));

        expect(exception.message, 'API bağlantısı zaman aşımına uğradı.');
      });
    }

    test('connection error için offline fallback döndürür', () {
      final exception = apiServiceException(
        _dioException(type: DioExceptionType.connectionError),
      );

      expect(exception.message, 'İnternet bağlantınızı kontrol edin.');
    });
  });

  group('friendlyErrorMessage', () {
    test('422 servis doğrulama mesajını korur', () {
      const error = ServiceException(
        message: 'Kullanıcı adı zaten kullanılıyor.',
        statusCode: 422,
      );

      expect(friendlyErrorMessage(error), 'Kullanıcı adı zaten kullanılıyor.');
    });

    test('ham mutation hatası yerine verilen fallback mesajını kullanır', () {
      expect(
        friendlyErrorMessage(
          StateError('internal implementation detail'),
          fallback: 'İşlem tamamlanamadı.',
        ),
        'İşlem tamamlanamadı.',
      );
    });
  });

  group('ApiClient.getSession', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    for (final malformedSession in [
      '["token"]',
      'null',
      '{"access_token":42,"refresh_token":true}',
      'not-json',
    ]) {
      test('bozuk oturumu temizler: $malformedSession', () async {
        FlutterSecureStorage.setMockInitialValues({
          'auth_session': malformedSession,
        });

        final session = await ApiClient.instance.getSession();

        expect(session, isNull);
        expect(
          await const FlutterSecureStorage().read(key: 'auth_session'),
          isNull,
        );
      });
    }
  });
}

DioException _dioException({
  int? statusCode,
  Object? data,
  DioExceptionType type = DioExceptionType.badResponse,
}) {
  final requestOptions = RequestOptions(path: '/test');
  return DioException(
    requestOptions: requestOptions,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: statusCode,
            data: data,
          ),
    type: type,
  );
}

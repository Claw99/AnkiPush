import 'package:dio/dio.dart';
import '../error/exceptions.dart';

class NetworkClient {
  final Dio dio;

  NetworkClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                sendTimeout: const Duration(seconds: 10),
                headers: {
                  'Accept': 'application/json',
                },
              ),
            );

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException('Ошибка подключения. Проверьте интернет-соединение.');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 404) {
          return const NotFoundException('Запрашиваемый ресурс не найден.');
        }
        return ServerException(
          error.response?.statusMessage ?? 'Ошибка сервера',
          statusCode,
        );
      case DioExceptionType.cancel:
        return const AppException('Запрос был отменен');
      default:
        return ServerException(error.message ?? 'Неизвестная сетевая ошибка');
    }
  }
}

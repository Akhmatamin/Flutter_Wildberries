import 'package:dio/dio.dart';

import 'constants.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final TokenStorage tokenStorage;

  void Function()? onUnauthorized;

  late final Dio dio;

  ApiClient(this.tokenStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (tokenStorage.hasToken) {
            options.headers['Authorization'] =
                'Bearer ${tokenStorage.accessToken}';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final hadToken = error.requestOptions.headers.containsKey(
            'Authorization',
          );
          if (error.response?.statusCode == 401 && hadToken) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<T> run<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException(_messageFrom(e));
    }
  }

  String _messageFrom(DioException e) {
    if (e.response == null) {
      return 'Нет соединения с сервером';
    }
    final data = e.response!.data;

    if (data is Map) {
      if (data['detail'] != null) return data['detail'].toString();
      final parts = data.entries.map((entry) {
        final value = entry.value;
        final text = value is List ? value.join(', ') : value.toString();
        return '${entry.key}: $text';
      });
      if (parts.isNotEmpty) return parts.join('\n');
    }
    return 'Ошибка сервера (${e.response!.statusCode})';
  }
}

List<dynamic> resultsOf(dynamic data) {
  if (data is Map && data['results'] is List) return data['results'] as List;
  if (data is List) return data;
  return [];
}

import 'package:dio/dio.dart';
import '../storage/local_storage.dart';

class DioClient {
  final Dio _dio;
  final LocalStorage _localStorage;

  DioClient(this._dio, this._localStorage) {
    _dio
      ..options.connectTimeout = const Duration(seconds: 30)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.responseType = ResponseType.json
      ..interceptors.addAll([
        HeaderInterceptor(_localStorage),
        SessionInterceptor(_localStorage),
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      ]);
  }

  Dio get dio => _dio;
}

class HeaderInterceptor extends Interceptor {
  final LocalStorage _localStorage;

  HeaderInterceptor(this._localStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final tenant = _localStorage.getTenant();
    if (tenant != null && tenant.isNotEmpty) {
      options.headers['tenant'] = tenant;
    }

    final token = _localStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }
}

class SessionInterceptor extends Interceptor {
  final LocalStorage _localStorage;

  SessionInterceptor(this._localStorage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _localStorage.clear();
      // Token expired, clear session
    }
    super.onError(err, handler);
  }
}

import 'package:dio/dio.dart';

class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server Error']);

  static Exception handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.cancel:
        return ServerException("Request to API server was cancelled");
      case DioExceptionType.connectionTimeout:
        return ServerException("Connection timeout with API server");
      case DioExceptionType.connectionError:
        return NetworkException("There is no internet connection");
      case DioExceptionType.receiveTimeout:
        return ServerException("Receive timeout in connection with API server");
      case DioExceptionType.sendTimeout:
        return ServerException("Send timeout in connection with API server");
      case DioExceptionType.badCertificate:
        return ServerException("Bad certificate");
      case DioExceptionType.unknown:
        return NetworkException("There is no internet connection");
      case DioExceptionType.badResponse:
        return _parseDioErrorResponse(e);
    }
  }

  static Exception _parseDioErrorResponse(DioException e) {
    final statusCode = e.response?.statusCode ?? -1;
    String? serverMessage;
    Map<String, dynamic>? errors;

    try {
      final data = e.response?.data;
      if (data is Map) {
        serverMessage = data['message']?.toString();
        if (data.containsKey('errors') && data['errors'] is Map) {
          errors = Map<String, dynamic>.from(data['errors'] as Map);
        }
      }
    } catch (_) {}

    if (statusCode == 422 && errors != null) {
      return ValidationException(serverMessage ?? "Validation failed", errors);
    }

    switch (statusCode) {
      case 503:
        return ServerException("Service Temporarily Unavailable");
      case 404:
        return ServerException(serverMessage ?? "Not Found");
      default:
        return ServerException(serverMessage ?? e.message ?? "Server Error");
    }
  }
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache Error']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Network Error']);
}

class ValidationException implements Exception {
  final String message;
  final Map<String, dynamic> errors;
  ValidationException(this.message, this.errors);
}

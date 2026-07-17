import 'package:dio/dio.dart';
import '../error/exceptions.dart';

abstract class BaseRemoteDataSource {
  Future<Response<T>> callApiWithErrorParser<T>(Future<Response<T>> api) async {
    try {
      final response = await api;
      return response;
    } on DioException catch (dioException) {
      throw ServerException.handleDioError(dioException);
    } catch (error) {
      if (error is ServerException || error is NetworkException || error is CacheException) {
        rethrow;
      }
      throw ServerException(error.toString());
    }
  }
}

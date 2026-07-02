import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String emailOrPhone, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<UserModel> signIn(String emailOrPhone, String password) async {
    try {
      final response = await dioClient.dio.post(
        'login',
        data: {
          'identifier': emailOrPhone,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Server error';
      throw ServerException(errorMessage);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
